import 'package:flutter/foundation.dart';

/// This class is the "brain" of the onboarding process.
///
/// It uses ChangeNotifier to hold the user's temporary selections
/// in one central place. Any widget in the onboarding flow can
/// read or write to this state.
class OnboardingState with ChangeNotifier {
  
  // --- Property 1: Style Preference ---
  String? _stylePreference;
  String? get stylePreference => _stylePreference;

  /// Updates the style preference and notifies all listeners.
  void setStyle(String style) {
    _stylePreference = style;
    
    // This is the magic line. It tells any widget
    // listening to this object to rebuild.
    notifyListeners(); 
    print('Onboarding state updated: Style set to $_stylePreference');
  }

  // --- Property 2: Favorite Colors ---
  final List<String> _favoriteColors = [];
  
  // A "getter" so other widgets can read the list, but not change it.
  List<String> get favoriteColors => _favoriteColors;

  /// Adds or removes a color from the selection.
  void toggleColor(String color) {
    if (_favoriteColors.contains(color)) {
      _favoriteColors.remove(color);
    } else {
      _favoriteColors.add(color);
    }
    notifyListeners(); // Tell listeners to rebuild
    print('Onboarding state updated: Colors are now $_favoriteColors');
  }

  // --- Property 3: Goals ---
  // We'll add this later, e.g.: String? _primaryGoal;
}
