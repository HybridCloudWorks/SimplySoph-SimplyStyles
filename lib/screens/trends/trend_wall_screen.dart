import 'package:flutter/material.dart';

class TrendWallScreen extends StatelessWidget {
  const TrendWallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trends = [
      {
        'name': 'Gorpcore',
        'description': 'Outdoor-inspired urban fashion',
        'matchCount': 3,
        'color': const Color(0xFF4CAF50),
      },
      {
        'name': 'Balletcore',
        'description': 'Ballet-inspired feminine aesthetics',
        'matchCount': 0,
        'color': const Color(0xFFE91E63),
      },
      {
        'name': 'Quiet Luxury',
        'description': 'Understated elegance and quality',
        'matchCount': 5,
        'color': const Color(0xFF795548),
      },
      {
        'name': 'Y2K Revival',
        'description': 'Early 2000s nostalgia',
        'matchCount': 2,
        'color': const Color(0xFF9C27B0),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trend Wall'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trends.length,
        itemBuilder: (context, index) {
          final trend = trends[index];
          return TrendCard(
            name: trend['name'] as String,
            description: trend['description'] as String,
            matchCount: trend['matchCount'] as int,
            color: trend['color'] as Color,
          );
        },
      ),
    );
  }
}

class TrendCard extends StatelessWidget {
  final String name;
  final String description;
  final int matchCount;
  final Color color;

  const TrendCard({
    super.key,
    required this.name,
    required this.description,
    required this.matchCount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Show trend details
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (matchCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B9D).withAlpha(26),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.checkroom,
                            size: 16,
                            color: Color(0xFFFF6B9D),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$matchCount items in your closet',
                            style: const TextStyle(
                              color: Color(0xFFFF6B9D),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // View matching items
                      },
                      child: const Text('View Items'),
                    ),
                  ] else ...[
                    Text(
                      'No matching items yet',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        // Create persona from trend
                      },
                      child: const Text('Create Persona'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
