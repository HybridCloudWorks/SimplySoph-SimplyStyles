import 'package:flutter/material.dart';

class FinishPage extends StatelessWidget {
  const FinishPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
          SizedBox(height: 24),
          Text(
            "You're all set!",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            "We're excited to help you discover a wardrobe that truly represents you.",
            style: TextStyle(fontSize: 18, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
