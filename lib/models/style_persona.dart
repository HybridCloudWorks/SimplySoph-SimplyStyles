import 'package:cloud_firestore/cloud_firestore.dart';

class StylePersona {
  final String id;
  final String userId;
  final String name;
  final String description;
  final List<String> keyPieces;
  final List<String> colorPalette;
  final DateTime createdAt;
  final DateTime updatedAt;

  StylePersona({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.keyPieces,
    required this.colorPalette,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StylePersona.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StylePersona(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      keyPieces: List<String>.from(data['keyPieces'] ?? []),
      colorPalette: List<String>.from(data['colorPalette'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'keyPieces': keyPieces,
      'colorPalette': colorPalette,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
