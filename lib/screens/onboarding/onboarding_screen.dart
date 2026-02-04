import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplystyles/auth/auth_service.dart';
import 'package:simplystyles/services/firestore_service.dart';
import 'package:simplystyles/state/onboarding_state.dart';
import 'package:simplystyles/screens/onboarding/style_page.dart';
import 'package:simplystyles/screens/onboarding/color_page.dart';
import 'package:simplystyles/screens/onboarding/pages/finish_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _saveAndFinish() async {
    // Set loading state
    setState(() => _isLoading = true);

    try {
      // 1. READ from all our Providers
      final auth = context.read<AuthService>();
      final db = context.read<FirestoreService>();
      final state = context.read<OnboardingState>();

      final uid = auth.currentUser?.uid;

      if (uid == null) {
        throw Exception('No user logged in. This should not happen.');
      }

      // 2. CALL the DatabaseService
      await db.saveAndCompleteOnboarding(
        uid: uid,
        style: state.stylePreference,
        colors: state.favoriteColors,
      );

    } catch (e) {
      // 3. HANDLE errors
      setState(() => _isLoading = false);
      
      if (!mounted) return;

      // Show a snackbar error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    // No need to set _isLoading = false on success,
    // because the widget will be unmounted by the navigation.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Style Profile'),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  StylePage(),
                  ColorPage(),
                  FinishPage(),
                ],
              ),                              
            ),

            // --- "SMART" NAVIGATION BAR ---
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Show "Back" button if NOT on the first page
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                      child: const Text('Back'),
                    )
                  else
                    // Use an empty, invisible widget to keep spacing
                    const SizedBox(width: 48), // Adjust as needed

                  if (_currentPage == 2) // 3 pages total (0, 1, 2)
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveAndFinish, // ⬅️ Call our new method
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save & Finish'),
                    )
                  else
                    // Otherwise, show "Next" button
                    ElevatedButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                      child: const Text('Next'),
                    ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}
