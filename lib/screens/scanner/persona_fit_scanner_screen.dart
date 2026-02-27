import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simplystyles/services/image_service.dart';

import 'package:simplystyles/api/gemini_cortex_api.dart';

class PersonaFitScannerScreen extends StatefulWidget {
  const PersonaFitScannerScreen({super.key});

  @override
  State<PersonaFitScannerScreen> createState() =>
      _PersonaFitScannerScreenState();
}

class _PersonaFitScannerScreenState extends State<PersonaFitScannerScreen> {
  final GeminiCortexAPI _geminiAPI = GeminiCortexAPI();
  final ImageService _imageService = ImageService();
  final ImagePicker _picker = ImagePicker();

  bool _isScanning = false;
  Map<String, dynamic>? _scanResult;
  File? _image;

  Future<void> _startScanning() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _isScanning = true;
        _scanResult = null;
        _image = File(image.path);
      });

      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) throw Exception('User not logged in');

        // 1. Upload image to Firebase Storage
        final imageBytes = await image.readAsBytes();
        final uploadResult = await _imageService.uploadClothingImage(
          userId: userId,
          imageBytes: imageBytes,
        );

        // 2. Extract relative path for secure API call
        // The uploadResult returns the full download URL, so we need to extract the path
        // OR we can reconstruct it since we know the structure: users/$userId/wardrobe/original/$itemId.jpg
        final itemId = uploadResult['itemId'];
        final storagePath = 'users/$userId/wardrobe/original/$itemId.jpg';

        // 3. Analyze the image using the secure storage path
        final itemAttributes = await _geminiAPI.analyzeClothingImage(storagePath);

        // 4. Calculate the persona fit
        final result = await _geminiAPI.calculatePersonaFit(itemAttributes);

        if (mounted) {
          setState(() {
            _isScanning = false;
            _scanResult = result;
          });
        }

        // Cleanup: Optionally delete the temp image from storage if it's not meant to be permanent
        // await _imageService.deleteClothingImage(userId, itemId!);

      } catch (e) {
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Will It Fit?'),
      ),
      body: Stack(
        children: [
          // Camera Preview
          if (_image != null)
            Image.file(
              _image!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
          else
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 80,
                      color: Colors.white.withAlpha(128),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Camera Preview',
                      style: TextStyle(
                        color: Colors.white.withAlpha(128),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Scanning Overlay
          if (_isScanning)
            Container(
              color: Colors.black.withAlpha(179),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Analyzing item...',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),

          // Results Overlay
          if (_scanResult != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(51),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Match Score
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF6B9D).withAlpha(26),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${_scanResult!['matchScore']}%',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6B9D),
                              ),
                            ),
                            const Text(
                              'Match',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Verdict
                    Text(
                      _scanResult!['verdict'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Top Persona
                    Text(
                      'Best fit for: ${_scanResult!['topPersona']}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Reasoning
                    Text(
                      _scanResult!['reasoning'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _scanResult = null;
                                _image = null;
                              });
                            },
                            child: const Text('Scan Again'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Add to wishlist or cart
                            },
                            child: const Text('Save Item'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Scan Button
          if (!_isScanning && _scanResult == null)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton.large(
                  onPressed: _startScanning,
                  child: const Icon(Icons.camera_alt, size: 32),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
