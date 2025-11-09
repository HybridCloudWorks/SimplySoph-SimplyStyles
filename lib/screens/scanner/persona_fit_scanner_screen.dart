import 'package:flutter/material.dart';

class PersonaFitScannerScreen extends StatefulWidget {
  const PersonaFitScannerScreen({super.key});

  @override
  State<PersonaFitScannerScreen> createState() =>
      _PersonaFitScannerScreenState();
}

class _PersonaFitScannerScreenState extends State<PersonaFitScannerScreen> {
  bool _isScanning = false;
  Map<String, dynamic>? _scanResult;

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _scanResult = null;
    });

    // Simulate scanning delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _scanResult = {
            'matchScore': 85,
            'verdict': 'Great Match!',
            'topPersona': 'Coastal Comfort',
            'reasoning':
                'This item perfectly matches your Coastal Comfort persona with its relaxed fit and beach-inspired colors.',
          };
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Will It Fit?'),
      ),
      body: Stack(
        children: [
          // Camera Preview Placeholder
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
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Camera Preview',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
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
              color: Colors.black.withValues(alpha: 0.7),
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
                      color: Colors.black.withValues(alpha: 0.2),
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
                        color: const Color(0xFFFF6B9D).withValues(alpha: 0.1),
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
                              setState(() => _scanResult = null);
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
