import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/integration_models.dart';
import '../../services/cloud_functions_service.dart';
import '../../services/image_service.dart';

class VisionScannerWidget extends StatefulWidget {
  const VisionScannerWidget({super.key});

  @override
  State<VisionScannerWidget> createState() => _VisionScannerWidgetState();
}

class _VisionScannerWidgetState extends State<VisionScannerWidget> {
  final ImagePicker _picker = ImagePicker();
  final CloudFunctionsService _functionsService = CloudFunctionsService();
  final ImageService _imageService = ImageService();

  Uint8List? _imageBytes;
  bool _isLoading = false;
  VisionAnalysisResult? _result;
  String? _error;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _result = null;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'Error picking image: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageBytes == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      // 1. Upload Image
      final uploadResult = await _imageService.uploadClothingImage(
        userId: userId,
        imageBytes: _imageBytes!,
      );
      final imageUrl = uploadResult['original']!;

      // 2. Call Vision API
      final data = await _functionsService.scanItemWithVision(imageUrl);

      setState(() {
        _result = VisionAnalysisResult.fromJson(data);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Preview
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _imageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                  )
                : const Center(
                    child: Icon(Icons.image, size: 64, color: Colors.grey),
                  ),
          ),
          const SizedBox(height: 16),

          // Controls
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      _isLoading ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      _isLoading ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_imageBytes != null)
            ElevatedButton(
              onPressed: _isLoading ? null : _analyzeImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Analyze with Google Vision AI'),
            ),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),

          // Results
          if (_result != null) ...[
            const SizedBox(height: 24),
            _buildResultSection('Labels', _result!.labels),
            _buildResultSection('Logos', _result!.logos),
            const SizedBox(height: 16),
            const Text('Dominant Colors',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _result!.dominantColors.map((colorStr) {
                // Parse "rgb(r, g, b)"
                final rgb = colorStr
                    .replaceAll('rgb(', '')
                    .replaceAll(')', '')
                    .split(',');
                final color = Color.fromRGBO(
                  int.parse(rgb[0].trim()),
                  int.parse(rgb[1].trim()),
                  int.parse(rgb[2].trim()),
                  1,
                );
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultSection(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => Chip(label: Text(item))).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
