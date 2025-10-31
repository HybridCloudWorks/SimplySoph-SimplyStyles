import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiCortexAPI {
  // Replace with your actual Gemini Cortex AI endpoint
  static const String _baseUrl = 'https://your-gemini-cortex-endpoint.com/api';
  static const String _apiKey = 'YOUR_API_KEY_HERE';

  /// Analyzes a clothing item image and returns attributes
  Future<Map<String, dynamic>> analyzeClothingImage(String imageUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analyze-clothing'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'imageUrl': imageUrl,
          'task': 'clothing_analysis',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to analyze image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling Gemini Cortex API: $e');
    }
  }

  /// Generates style personas based on wardrobe items
  Future<List<Map<String, dynamic>>> generateStylePersonas(
      List<Map<String, dynamic>> wardrobeItems) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/generate-personas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'wardrobeItems': wardrobeItems,
          'task': 'persona_generation',
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(result['personas'] ?? []);
      } else {
        throw Exception('Failed to generate personas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling Gemini Cortex API: $e');
    }
  }

  /// Calculates how well an item fits with user's style personas
  Future<Map<String, dynamic>> calculatePersonaFit(
      Map<String, dynamic> itemAttributes,
      List<Map<String, dynamic>> personas) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/calculate-fit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'itemAttributes': itemAttributes,
          'personas': personas,
          'task': 'persona_fit',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to calculate fit: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling Gemini Cortex API: $e');
    }
  }

  /// Analyzes trends and matches with user's wardrobe
  Future<List<Map<String, dynamic>>> analyzeTrends(
      List<Map<String, dynamic>> wardrobeItems) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analyze-trends'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'wardrobeItems': wardrobeItems,
          'task': 'trend_analysis',
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(result['trends'] ?? []);
      } else {
        throw Exception('Failed to analyze trends: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling Gemini Cortex API: $e');
    }
  }
}
