import 'package:cloud_firestore/cloud_firestore.dart';

class StylePersona {
  final String id;
  final String userId;
  final String name;
  final String dominantStyle;
  final List<String> colorPalette;
  final Map<String, double> priceRange;
  final int itemCount;
  final List<String> itemIds;
  final Map<String, dynamic> characteristics;
  final DateTime createdAt;
  final DateTime updatedAt;

  StylePersona({
    required this.id,
    required this.userId,
    required this.name,
    required this.dominantStyle,
    required this.colorPalette,
    required this.priceRange,
    required this.itemCount,
    required this.itemIds,
    required this.characteristics,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StylePersona.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StylePersona(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      dominantStyle: data['dominantStyle'] ?? '',
      colorPalette: List<String>.from(data['colorPalette'] ?? []),
      priceRange: {
        'min': (data['priceRange']?['min'] ?? 0).toDouble(),
        'max': (data['priceRange']?['max'] ?? 0).toDouble(),
      },
      itemCount: data['itemCount'] ?? 0,
      itemIds: List<String>.from(data['itemIds'] ?? []),
      characteristics: data['characteristics'] ?? {},
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'dominantStyle': dominantStyle,
      'colorPalette': colorPalette,
      'priceRange': priceRange,
      'itemCount': itemCount,
      'itemIds': itemIds,
      'characteristics': characteristics,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  String getStyleDescription() {
    switch (dominantStyle) {
      case 'luxury_loungewear':
        return 'Luxury Loungewear';
      case 'new_preppy':
        return 'New Preppy';
      case 'coastal_comfort':
        return 'Coastal Comfort';
      default:
        return dominantStyle;
    }
  }
}
