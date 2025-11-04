import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplystyles/state/onboarding_state.dart';

class ColorPage extends StatelessWidget {
  const ColorPage({Key? key}) : super(key: key);

  // A map of color names to their actual Color values
  static const Map<String, Color> _colorMap = {
    'Red': Colors.red,
    'Orange': Colors.orange,
    'Yellow': Colors.yellow,
    'Green': Colors.green,
    'Blue': Colors.blue,
    'Indigo': Colors.indigo,
    'Purple': Colors.purple,
    'Pink': Colors.pink,
    'Black': Colors.black,
    'White': Colors.white,
    'Grey': Colors.grey,
    'Brown': Colors.brown,
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingState>(
      builder: (context, state, child) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Which colors do you love?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Select up to ${OnboardingState.maxColorChoices} of your favorites.',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // The responsive grid of color swatches
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // 4 colors per row
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _colorMap.length,
                  itemBuilder: (context, index) {
                    final colorName = _colorMap.keys.elementAt(index);
                    final colorValue = _colorMap.values.elementAt(index);
                    final isSelected = state.favoriteColors.contains(colorName);

                    return GestureDetector(
                      onTap: () {
                        context.read<OnboardingState>().toggleColor(colorName);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorValue,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.black.withOpacity(0.1),
                            width: isSelected ? 3.0 : 1.0,
                          ),
                        ),
                        // Show a checkmark overlay if selected
                        child: isSelected
                            ? Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 36),
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
