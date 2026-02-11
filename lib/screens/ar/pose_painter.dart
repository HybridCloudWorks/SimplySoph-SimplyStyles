import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;

  PosePainter({required this.poses, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5.0
      ..style = PaintingStyle.fill;

    for (final pose in poses) {
      for (final landmark in pose.landmarks.values) {
        // Adjust landmark position to fit the screen
        final screenX = landmark.x * size.width / imageSize.width;
        final screenY = landmark.y * size.height / imageSize.height;

        canvas.drawCircle(Offset(screenX, screenY), 5.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
