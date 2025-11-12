import 'package:cloud_firestore/cloud_firestore.dart';

class BitlyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createShortLink(String longUrl) async {
    final docRef = await _firestore.collection('urls').add({
      'url': longUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await Future.delayed(const Duration(seconds: 2));

    final doc = await docRef.get();
    return doc.data()?['shortUrl'] ?? longUrl;
  }

  Future<String> shareOutfit(String outfitId) async {
    final longUrl = 'https://simplysoph-66c78.web.app/outfit/$outfitId';
    return await createShortLink(longUrl);
  }
}
