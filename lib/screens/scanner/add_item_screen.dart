import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service.dart';
import '../../services/wardrobe_service.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image == null) return;

      setState(() => _isUploading = true);

      if (!mounted) return;
      
      final authService = context.read<AuthService>();
      final wardrobeService = context.read<WardrobeService>();
      final userId = authService.currentUser?.uid;

      if (userId == null) throw Exception('User not authenticated');

      // Use bytes for web compatibility
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        await wardrobeService.addItemFromBytes(
          userId: userId,
          imageBytes: bytes,
          category: 'top',
        );
      } else {
        await wardrobeService.addItem(
          userId: userId,
          imagePath: image.path,
          category: 'top',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item added to wardrobe!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } on ArgumentError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid input: ${e.message}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Upload failed';
        
        // Parse common Firebase errors
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('unauthorized') || errorStr.contains('permission')) {
          errorMessage = 'Authorization error. Please log out and log back in.';
        } else if (errorStr.contains('network')) {
          errorMessage = 'Network error. Check your connection.';
        } else if (errorStr.contains('size') || errorStr.contains('10mb')) {
          errorMessage = 'File too large. Max size is 10MB.';
        } else if (errorStr.contains('authenticated')) {
          errorMessage = 'Session expired. Please log in again.';
        } else {
          errorMessage = 'Upload failed: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: Center(
        child: _isUploading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Uploading item...'),
                  SizedBox(height: 8),
                  Text(
                    'This may take a moment',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt, size: 80, color: Colors.grey),
                    const SizedBox(height: 24),
                    const Text(
                      'Add a clothing item',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Max file size: 10MB',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 48),
                    if (!kIsWeb)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Take Photo'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    if (!kIsWeb) const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Choose from Gallery'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
