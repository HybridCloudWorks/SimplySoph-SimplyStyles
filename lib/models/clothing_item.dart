import 'package:cloud_firestore/cloud_firestore.dart';

class ClothingItem {
  final String id;
  final String userId;
  final String imageUrl;
  final String thumbnailUrl;
  final String category;
  final String color;
  final List<String> colors;
  final String brand;
  final double msrp;
  final String styleTag;
  final List<String> styleTags;
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
    required this.colors,
    required this.brand,
    required this.msrp,
    required this.styleTag,
    required this.styleTags,
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
      colors: List<String>.from(data['colors'] ?? data['dominantColors'] ?? []),
      brand: data['brand'] ?? '',
      msrp: (data['msrp'] ?? 0).toDouble(),
      styleTag: data['styleTag'] ?? '',
      styleTags: List<String>.from(data['styleTags'] ?? data['tags'] ?? []),
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
      'colors': colors,
      'dominantColors': colors, // Backward compatibility
      'brand': brand,
      'msrp': msrp,
      'styleTag': styleTag,
      'styleTags': styleTags,
      'tags': styleTags, // Backward compatibility
      'personaIds': personaIds,
      'scanMethod': scanMethod,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ClothingItem copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? thumbnailUrl,
    String? category,
    String? color,
    List<String>? colors,
    String? brand,
    double? msrp,
    String? styleTag,
    List<String>? styleTags,
    List<String>? personaIds,
    String? scanMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      category: category ?? this.category,
      color: color ?? this.color,
      colors: colors ?? this.colors,
      brand: brand ?? this.brand,
      msrp: msrp ?? this.msrp,
      styleTag: styleTag ?? this.styleTag,
      styleTags: styleTags ?? this.styleTags,
      personaIds: personaIds ?? this.personaIds,
      scanMethod: scanMethod ?? this.scanMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
