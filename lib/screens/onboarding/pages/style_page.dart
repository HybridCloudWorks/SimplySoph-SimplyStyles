import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplystyles/state/onboarding_state.dart';

class StylePage extends StatelessWidget {
  const StylePage({Key? key}) : super(key: key);

  // A list of style options the AI can learn from
  final List<String> _styleOptions = [
    'Casual', 'Chic', 'Sporty', 'Vintage',
    'Bohemian', 'Minimalist', 'Goth', 'Preppy',
  ];

  @override
  Widget build(BuildContext context) {
    // We use Consumer to listen for changes to the "brain"
    return Consumer<OnboardingState>(
      builder: (context, state, child) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "What's your go-to style?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Select the one that feels most like you.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // This is a great widget for selectable chips
              Expanded(
                child: Wrap(
                  spacing: 12.0, // Horizontal space
                  runSpacing: 12.0, // Vertical space
                  alignment: WrapAlignment.center,
                  children: _styleOptions.map((style) {
                    final bool isSelected = state.stylePreference == style;
                    
                    return ChoiceChip(
                      label: Text(style),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          // This is how we "tell" the brain our choice
                          context.read<OnboardingState>().setStyle(style);
                        }
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                      selectedColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.grey[100],
                      shape: StadiumBorder(),
                    );
                  }).toList(),
                ),
              ),

              // The "Next" button is now in the parent OnboardingScreen
            ],
          ),
        );
      },
    );
  }
}