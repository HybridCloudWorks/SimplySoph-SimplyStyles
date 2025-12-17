import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service.dart';
import '../../services/image_service.dart';

class NetworkImageWithRetry extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const NetworkImageWithRetry({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<NetworkImageWithRetry> createState() => _NetworkImageWithRetryState();
}

class _NetworkImageWithRetryState extends State<NetworkImageWithRetry> {
  String? _currentUrl;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.imageUrl;
    _validateUrl();
  }

  @override
  void didUpdateWidget(NetworkImageWithRetry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      setState(() {
        _currentUrl = widget.imageUrl;
        _isLoading = true;
        _hasError = false;
      });
      _validateUrl();
    }
  }

  Future<void> _validateUrl() async {
    if (_currentUrl == null || _currentUrl!.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // If it's not a storage URL, just try loading it
    if (!_currentUrl!.contains('firebasestorage')) {
       if (mounted) setState(() => _isLoading = false);
       return;
    }

    // It's a storage URL, proceed to load.
    // We don't pre-fetch fresh URL unless loading fails.
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _refreshUrl() async {
    if (!mounted) return;

    // Only try to refresh if it looks like a firebase storage URL
    if (_currentUrl == null || !_currentUrl!.contains('firebasestorage')) return;

    try {
      final imageService = context.read<ImageService>();
      final userId = context.read<AuthService>().currentUser?.uid;

      if (userId != null) {
        // Parse path from URL
        final uri = Uri.parse(_currentUrl!);
        final pathSegments = uri.pathSegments;

        // Typical structure: .../o/users%2F{userId}%2Fwardrobe%2Fthumbnails%2F{itemId}_thumb.jpg
        // The path segments in download URL are weirdly encoded in segment last.
        // Actually, better to rely on decoding the path component.
        // /v0/b/{bucket}/o/{path}

        final oIndex = pathSegments.indexOf('o');
        if (oIndex >= 0 && oIndex < pathSegments.length - 1) {
          final encodedPath = pathSegments[oIndex + 1];
          final path = Uri.decodeComponent(encodedPath);

          // Ensure path starts with users/{userId} to be safe
          if (path.startsWith('users/$userId/')) {
             // Remove users/{userId}/ prefix for getFreshDownloadUrl if it expects relative?
             // Checking ImageService... getFreshDownloadUrl expects "wardrobe/thumbnails/..."
             // It prepends "users/$userId/".

             final relativePath = path.replaceFirst('users/$userId/', '');
             final freshUrl = await imageService.getFreshDownloadUrl(userId, relativePath);

             if (freshUrl != null && mounted) {
               setState(() {
                 _currentUrl = freshUrl;
                 _hasError = false;
               });
             }
          }
        }
      }
    } catch (e) {
      debugPrint('Error refreshing URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUrl == null || _currentUrl!.isEmpty) {
      return widget.errorWidget ?? const Center(child: Icon(Icons.image_not_supported, color: Colors.grey));
    }

    return Image.network(
      _currentUrl!,
      fit: widget.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return widget.placeholder ?? const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        if (!_hasError) {
          // Attempt refresh once
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_hasError) {
              setState(() => _hasError = true); // Mark as error so we don't loop infinite
              _refreshUrl();
            }
          });
          // Show loading while we try to refresh
          return widget.placeholder ?? const Center(child: CircularProgressIndicator());
        }

        return widget.errorWidget ?? Container(
          color: Colors.grey[200],
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.broken_image, size: 24, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }
}
