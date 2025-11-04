import 'package:flutter/material.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  _buildForYouTab(),
                  _buildByPersonaTab(),
                  _buildTrendingTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForYouTab() {
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

  Widget _buildByPersonaTab() {
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

  Widget _buildTrendingTab() {
    final trendingItems = [
      {
        'name': 'Coastal Comfort Hoodie',
        'brand': 'Aviator Nation',
        'price': 158.0,
        'matchScore': 92,
      },
      {
        'name': 'Preppy Matching Set',
        'brand': 'Roller Rabbit',
        'price': 124.0,
        'matchScore': 88,
      },
      {
        'name': 'Luxury Lounge Pants',
        'brand': 'Pink Palm Puff',
        'price': 98.0,
        'matchScore': 85,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trendingItems.length,
      itemBuilder: (context, index) {
        final item = trendingItems[index];
        return RecommendationCard(
          name: item['name'] as String,
          brand: item['brand'] as String,
          price: item['price'] as double,
          matchScore: item['matchScore'] as int,
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

  const RecommendationCard({
    super.key,
    required this.name,
    required this.brand,
    required this.price,
    required this.matchScore,
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
                            color: const Color(0xFF4CAF50).withAlpha(26),
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
