import 'package:algoliasearch/algoliasearch.dart';

class AlgoliaService {
  static const String _appId = '9VDH7LERG8'; // Replace with your App ID
  static const String _apiKey = '7a666ca88c2ea28df1088f85b92303d6'; // Replace with Search-Only API Key
  static const String _indexName = 'wardrobe_items';

  late final SearchClient _client;

  AlgoliaService() {
    _client = SearchClient(appId: _appId, apiKey: _apiKey);
  }

  Future<List<Map<String, dynamic>>> search(String query) async {
    final response = await _client.searchSingleIndex(
      indexName: _indexName,
      searchParams: SearchParamsObject(query: query),
    );
    return response.hits.map((hit) => hit.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> searchByCategory(String category) async {
    final response = await _client.searchSingleIndex(
      indexName: _indexName,
      searchParams: SearchParamsObject(query: '', filters: 'category:$category'),
    );
    return response.hits.map((hit) => hit.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> searchByColor(String color) async {
    final response = await _client.searchSingleIndex(
      indexName: _indexName,
      searchParams: SearchParamsObject(query: '', filters: 'color:$color'),
    );
    return response.hits.map((hit) => hit.toJson()).toList();
  }

  void dispose() {
    _client.dispose();
  }
}
