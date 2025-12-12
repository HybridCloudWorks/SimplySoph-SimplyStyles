import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_service.dart';
import '../../models/style_persona.dart';
import '../../services/persona_service.dart';
import '../../services/recommendation_service.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final RecommendationService _recommendationService = RecommendationService();
  final PersonaService _personaService = PersonaService();

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final userId = authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'For You'),
                Tab(text: 'By Persona'),
                Tab(text: 'Trending'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildForYouTab(userId),
                  _buildByPersonaTab(userId),
                  _buildTrendingTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForYouTab(String? userId) {
    if (userId == null) {
      return const Center(child: Text('Please log in to see recommendations'));
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _recommendationService.getPersonalizedRecommendations(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final recommendations = snapshot.data ?? [];

        if (recommendations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'No recommendations yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add items to your closet to get personalized recommendations',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: recommendations.length,
          itemBuilder: (context, index) {
            final item = recommendations[index];
            return RecommendationCard(
              name: item['name'] as String,
              brand: item['brand'] as String,
              price: item['price'] as double,
              matchScore: item['matchScore'] as int,
              description: item['description'] as String? ?? '',
            );
          },
        );
      },
    );
  }

  Widget _buildByPersonaTab(String? userId) {
    if (userId == null) {
      return const Center(
          child: Text('Please log in to see persona recommendations'));
    }

    return StreamBuilder<List<StylePersona>>(
      stream: _personaService.getPersonas(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final personas = snapshot.data ?? [];

        if (personas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'No personas created yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Build your wardrobe to discover your style personas',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: personas.length,
          itemBuilder: (context, index) {
            final persona = personas[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                title: Text(
                  persona.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(persona.description),
                children: [
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _recommendationService.getRecommendationsByPersona(
                        userId, persona.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError || snapshot.data == null) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Unable to load recommendations'),
                        );
                      }

                      final recommendations = snapshot.data!;
                      return Column(
                        children: recommendations.map((item) {
                          return RecommendationCard(
                            name: item['name'] as String,
                            brand: item['brand'] as String,
                            price: item['price'] as double,
                            matchScore: item['matchScore'] as int,
                            description: item['description'] as String? ?? '',
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTrendingTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _recommendationService.getTrendingRecommendations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final recommendations = snapshot.data ?? [];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: recommendations.length,
          itemBuilder: (context, index) {
            final item = recommendations[index];
            return RecommendationCard(
              name: item['name'] as String,
              brand: item['brand'] as String,
              price: item['price'] as double,
              matchScore: item['matchScore'] as int,
              description: item['description'] as String? ?? '',
            );
          },
        );
      },
    );
  }
}

class RecommendationCard extends StatelessWidget {
  final String name;
  final String brand;
  final double price;
  final int matchScore;
  final String description;

  const RecommendationCard({
    super.key,
    required this.name,
    required this.brand,
    required this.price,
    required this.matchScore,
    this.description = '',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Show item details
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Item Image Placeholder
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.checkroom, size: 40),
              ),
              const SizedBox(width: 16),

              // Item Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brand,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B9D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF4CAF50).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 14,
                                color: Color(0xFF4CAF50),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$matchScore% Match',
                                style: const TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Button
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // Add to favorites
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
