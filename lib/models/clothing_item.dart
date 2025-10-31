import 'package:cloud_firestore/cloud_firestore.dart';

class ClothingItem {
  final String id;
  final String userId;
  final String imageUrl;
  final String thumbnailUrl;
  final String category;
  final String color;
  final List<String> dominantColors;
  final String brand;
  final double msrp;
  final String styleTag;
  final List<String> tags;
  final List<String> personaIds;
  final String scanMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClothingItem({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.category,
    required this.color,
    required this.dominantColors,
    required this.brand,
    required this.msrp,
    required this.styleTag,
    required this.tags,
    required this.personaIds,
    required this.scanMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClothingItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ClothingItem(
      id: doc.id,
      userId: data['userId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      category: data['category'] ?? '',
      color: data['color'] ?? '',
      dominantColors: List<String>.from(data['dominantColors'] ?? []),
      brand: data['brand'] ?? '',
      msrp: (data['msrp'] ?? 0).toDouble(),
      styleTag: data['styleTag'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      personaIds: List<String>.from(data['personaIds'] ?? []),
      scanMethod: data['scanMethod'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'category': category,
      'color': color,
      'dominantColors': dominantColors,
      'brand': brand,
      'msrp': msrp,
      'styleTag': styleTag,
      'tags': tags,
      'personaIds': personaIds,
      'scanMethod': scanMethod,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
