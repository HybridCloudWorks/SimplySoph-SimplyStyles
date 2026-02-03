import 'package:flutter/material.dart';

import 'shopping_search_widget.dart';
import 'trends_widget.dart';
import 'vision_scanner_widget.dart';

class IntegrationsScreen extends StatelessWidget {
  const IntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('External Integrations'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.camera_alt), text: 'Vision AI'),
              Tab(icon: Icon(Icons.trending_up), text: 'Trends'),
              Tab(icon: Icon(Icons.shopping_bag), text: 'Shop'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            VisionScannerWidget(),
            TrendsWidget(),
            ShoppingSearchWidget(),
          ],
        ),
      ),
    );
  }
}
