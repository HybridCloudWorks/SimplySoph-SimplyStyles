import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/onboarding_state.dart'; // Import the "brain"

class ColorPage extends StatelessWidget {
  const ColorPage({super.key});

  // Define our color palette
  final Map<String, Color> _colorOptions = const {
    'Black': Colors.black,
    'White': Colors.white,
    'Grey': Colors.grey,
    'Red': Color(0xFFC62828), // Colors.red.shade700
    'Blue': Color(0xFF1565C0), // Colors.blue.shade700
    'Green': Color(0xFF2E7D32), // Colors.green.shade700
    'Yellow': Color(0xFFF9A825), // Colors.yellow.shade700
    'Orange': Color(0xFFEF6C00), // Colors.orange.shade700
    'Purple': Color(0xFF6A1B9A), // Colors.purple.shade700
    'Pink': Color(0xFFEC407A), // Colors.pink.shade300
    'Brown': Colors.brown,
    'Beige': Color(0xFFF5F5DC),
  };

  @override
  Widget build(BuildContext context) {
    // Listen to the "brain"
    return Consumer<OnboardingState>(
      builder: (context, state, child) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "What colors do you love?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Pick all that apply. This helps us match outfits!",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Use a GridView to display color swatches
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // 4 columns
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                  ),
                  itemCount: _colorOptions.length,
                  itemBuilder: (context, index) {
                    final colorName = _colorOptions.keys.elementAt(index);
                    final colorValue = _colorOptions.values.elementAt(index);
                    final bool isSelected = state.favoriteColors.contains(colorName);

                    return InkWell(
                      onTap: () {
                        // Tell the "brain" to toggle this color
                        context.read<OnboardingState>().toggleColor(colorName);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorValue,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: colorValue == Colors.white ? Colors.grey.shade300 : Colors.transparent,
                          ),
                          // Show a visible "check" mark
                          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 5, spreadRadius: 1)] : [],
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                color: colorValue == Colors.white || colorValue == const Color(0xFFF5F5DC) ? Colors.black : Colors.white,
                                size: 30,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
