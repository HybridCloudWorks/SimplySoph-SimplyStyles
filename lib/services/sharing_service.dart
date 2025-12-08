import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';

class SharingService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> createShareLink(String itemId) async {
    try {
      final result = await _functions.httpsCallable('createShareLink').call({
        'itemId': itemId,
        'url': 'https://simplysoph-66c78.web.app/item/$itemId',
      });
      
      return result.data['shortUrl'] as String;
    } catch (e) {
      throw Exception('Failed to create share link: $e');
    }
  }

  Future<void> shareItem(String itemId, String imageUrl) async {
    try {
      final shortUrl = await createShareLink(itemId);
      
      await Clipboard.setData(ClipboardData(
        text: 'Check out this outfit! $shortUrl',
      ));
    } catch (e) {
      throw Exception('Failed to share item: $e');
    }
  }
}