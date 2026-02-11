import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_service.dart';
import '../../services/gamification_service.dart';
import '../../services/social_service.dart';
import '../../services/wardrobe_service.dart';
import '../closet/outfit_builder_screen.dart';
import '../closet/smart_closet_screen.dart';
import '../integrations/integrations_screen.dart';
import '../scanner/add_item_screen.dart';
import '../scanner/persona_fit_scanner_screen.dart';
import '../shop/recommendations_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  void _navigateToCloset() {
    setState(() => _selectedIndex = 1);
  }

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardTab(onNavigateToCloset: _navigateToCloset),
      const SmartClosetScreen(),
      const PersonaFitScannerScreen(),
      const OutfitBuilderScreen(),
      const RecommendationsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.checkroom_outlined),
            selectedIcon: Icon(Icons.checkroom),
            label: 'Closet',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Outfits',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatefulWidget {
  final VoidCallback? onNavigateToCloset;

  const DashboardTab({super.key, this.onNavigateToCloset});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  int _itemCount = 0;
  int _pointsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      if (Firebase.apps.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final authService = Provider.of<AuthService>(context, listen: false);
      final wardrobeService = Provider.of<WardrobeService>(context, listen: false);
      final gamificationService = Provider.of<GamificationService>(context, listen: false);
      final userId = authService.currentUser?.uid;

      if (userId != null) {
        final count = await wardrobeService.getItemCount(userId);
        final points = await gamificationService.getPoints(userId);
        if (mounted) {
          setState(() {
            _itemCount = count;
            _pointsCount = points;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final socialService = Provider.of<SocialService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SimplyStyles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _ShareDialog(
                  itemCount: _itemCount,
                  pointsCount: _pointsCount,
                  socialService: socialService,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${user?.displayName ?? 'Fashionista'}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your style journey continues',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onNavigateToCloset,
                    child: _StatCard(
                      icon: Icons.checkroom,
                      label: 'Items',
                      value: _isLoading ? '...' : _itemCount.toString(),
                      color: Colors.pink,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.star_border,
                    label: 'Points',
                    value: _isLoading ? '...' : _pointsCount.toString(),
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Your Style Personas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add items to discover your style personas',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _QuickActionCard(
              icon: Icons.camera_alt,
              title: 'Scan New Item',
              subtitle: 'Add to your wardrobe',
              color: const Color(0xFFFF6B9D),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddItemScreen()),
                ).then((_) => _loadData());
              },
            ),
            const SizedBox(height: 12),
            _QuickActionCard(
              icon: Icons.trending_up,
              title: 'Explore Trends',
              subtitle: 'See what\'s trending',
              color: const Color(0xFF9C27B0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IntegrationsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1), // Ensure alpha is 0.0-1.0
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareDialog extends StatelessWidget {
  final int itemCount;
  final int pointsCount;
  final SocialService socialService;

  const _ShareDialog({
    required this.itemCount,
    required this.pointsCount,
    required this.socialService,
  });

  @override
  Widget build(BuildContext context) {
    final shareText = 'Check out my progress on SimplyStyles! I have $itemCount items and $pointsCount points!';

    return AlertDialog(
      title: const Text('Share Your Progress'),
      content: Text(shareText),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('Share'),
          onPressed: () {
            socialService.share(shareText);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
