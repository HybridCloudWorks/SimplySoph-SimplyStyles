import 'package:cached_network_image/cached_network_image.dart';
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
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.imageUrl;
  }

  @override
  void didUpdateWidget(NetworkImageWithRetry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      setState(() {
        _currentUrl = widget.imageUrl;
        _hasError = false;
      });
    }
  }

  Future<void> _refreshUrl() async {
    if (!mounted) return;

    if (_currentUrl == null) return;

    try {
      final imageService = context.read<ImageService>();
      final userId = context.read<AuthService>().currentUser?.uid;

      if (userId != null) {
        final relativePath = imageService.extractRelativePathFromUrl(_currentUrl!, userId);

        if (relativePath != null) {
           final freshUrl = await imageService.getFreshDownloadUrl(userId, relativePath);

           if (freshUrl != null && mounted) {
             setState(() {
               _currentUrl = freshUrl;
               _hasError = false;
             });
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

    // Optimization: Use CachedNetworkImage instead of Image.network for better performance
    return CachedNetworkImage(
      imageUrl: _currentUrl!,
      fit: widget.fit,
      placeholder: (context, url) => widget.placeholder ?? const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) {
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
