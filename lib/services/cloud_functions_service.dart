import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctionsService {
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');

  // 1. Google Vision AI
  Future<Map<String, dynamic>> scanItemWithVision(String imageUrl) async {
    try {
      final result = await _functions.httpsCallable('scanItemWithVision').call({
        'imageUrl': imageUrl,
      });
      return Map<String, dynamic>.from(result.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // 2. Google Trends
  Future<Map<String, dynamic>> getFashionTrends(
      {String keyword = 'fashion trends', String geo = 'US'}) async {
    try {
      final result = await _functions.httpsCallable('getFashionTrends').call({
        'keyword': keyword,
        'geo': geo,
      });
      return Map<String, dynamic>.from(result.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  // 3. Shein Search
  Future<List<dynamic>> searchShein(String query, {int limit = 20}) async {
    try {
      final result = await _functions.httpsCallable('searchShein').call({
        'query': query,
        'limit': limit,
      });
      // Adjust parsing based on actual API response structure
      // Assuming data.info.products or similar, but for now returning raw data wrapper
      // The function returns { success: true, data: response.data }
      final data = result.data['data'];
      if (data != null &&
          data['info'] != null &&
          data['info']['products'] != null) {
        return List<dynamic>.from(data['info']['products']);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // 4. Zappos Search
  Future<List<dynamic>> searchZappos(String query, {int limit = 20}) async {
    try {
      final result = await _functions.httpsCallable('searchZappos').call({
        'query': query,
        'limit': limit,
      });
      // The function returns { success: true, data: response.data }
      // Zappos usually returns { results: [...] }
      final data = result.data['data'];
      if (data != null && data['results'] != null) {
        return List<dynamic>.from(data['results']);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
