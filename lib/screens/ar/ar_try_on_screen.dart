import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'pose_painter.dart';
import 'wardrobe_item_selector.dart';

class ARTryOnScreen extends StatefulWidget {
  const ARTryOnScreen({super.key});

  @override
  State<ARTryOnScreen> createState() => _ARTryOnScreenState();
}

class _ARTryOnScreenState extends State<ARTryOnScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  String? _selectedItemImage;

  late final PoseDetector _poseDetector;
  List<Pose> _poses = [];
  bool _isProcessingImage = false;

  @override
  void initState() {
    super.initState();
    _poseDetector = PoseDetector(options: PoseDetectorOptions());
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      // Handle case where no cameras are available
      return;
    }
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _cameraController!.initialize().then((_) {
      _cameraController!.startImageStream(_processCameraImage);
    });

    if (mounted) {
      setState(() {});
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isProcessingImage) return;
    _isProcessingImage = true;

    final inputImage = InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation90deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );

    try {
      final poses = await _poseDetector.processImage(inputImage);
      if (mounted) {
        setState(() {
          _poses = poses;
        });
      }
    } catch (e) {
      // handle error
    } finally {
      _isProcessingImage = false;
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Try-On'),
        actions: [
          IconButton(
            icon: const Icon(Icons.checkroom),
            onPressed: _showItemSelection,
            tooltip: 'Select Item',
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Feed
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_cameraController!);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),

          // Pose Painter
          if (_cameraController != null && _cameraController!.value.isInitialized)
            CustomPaint(
              painter: PosePainter(
                poses: _poses,
                imageSize: _cameraController!.value.previewSize!,
              ),
            ),

          // Overlayed Clothing Item
          if (_selectedItemImage != null && _poses.isNotEmpty)
            ..._buildClothingOverlays(),
        ],
      ),
    );
  }

  List<Widget> _buildClothingOverlays() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return [];
    }

    final imageSize = _cameraController!.value.previewSize!;
    final screenSize = MediaQuery.of(context).size;

    final widgets = <Widget>[];

    for (final pose in _poses) {
      final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
      final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
      final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

      if (leftShoulder != null &&
          rightShoulder != null &&
          leftHip != null &&
          rightHip != null) {
        // Calculate position and size for the clothing item
        final shoulderWidth = (rightShoulder.x - leftShoulder.x).abs() *
            screenSize.width /
            imageSize.width;
        final torsoHeight = (leftHip.y - leftShoulder.y).abs() *
            screenSize.height /
            imageSize.height;

        final top = (leftShoulder.y + rightShoulder.y) /
            2 *
            screenSize.height /
            imageSize.height;
        final left = (leftShoulder.x) * screenSize.width / imageSize.width;

        widgets.add(
          Positioned(
            top: top,
            left: left,
            width: shoulderWidth,
            height: torsoHeight,
            child: Image.network(
              _selectedItemImage!,
              fit: BoxFit.fill,
            ),
          ),
        );
      }
    }
    return widgets;
  }

  void _showItemSelection() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return WardrobeItemSelector(
          onItemSelected: (imageUrl) {
            setState(() {
              _selectedItemImage = imageUrl;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
