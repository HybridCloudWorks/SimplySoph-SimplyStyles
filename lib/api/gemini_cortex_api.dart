import 'package:cloud_functions/cloud_functions.dart';

class GeminiCortexAPI {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Analyzes a clothing item image and returns attributes
  /// [storagePath] The relative path in Firebase Storage (e.g., users/uid/wardrobe/original/item.jpg)
  Future<Map<String, dynamic>> analyzeClothingImage(String storagePath) async {
    try {
      final callable = _functions.httpsCallable('vortex_analyzeItem');
      final result = await callable.call({'storagePath': storagePath});
      return result.data;
    } catch (e) {
      throw Exception('Error analyzing image: $e');
    }
  }



  /// Generates style personas based on wardrobe items
  Future<void> generateStylePersonas() async {
    try {
      final callable = _functions.httpsCallable('vortex_generatePersonas');
      await callable.call();
    } catch (e) {
      throw Exception('Error generating personas: $e');
    }
  }

  /// Calculates how well an item fits with user's style personas
  Future<Map<String, dynamic>> calculatePersonaFit(
      Map<String, dynamic> itemAttributes) async {
    try {
      final callable = _functions.httpsCallable('vortex_calculateFit');
      final result = await callable.call({'itemAttributes': itemAttributes});
      return result.data;
    } catch (e) {
      throw Exception('Error calculating fit: $e');
    }
  }


}
