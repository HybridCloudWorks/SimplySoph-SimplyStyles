class VisionAnalysisResult {
  final List<String> labels;
  final List<String> logos;
  final List<String> dominantColors;

  VisionAnalysisResult({
    required this.labels,
    required this.logos,
    required this.dominantColors,
  });

  factory VisionAnalysisResult.fromJson(Map<String, dynamic> json) {
    return VisionAnalysisResult(
      labels: List<String>.from(json['labels'] ?? []),
      logos: List<String>.from(json['logos'] ?? []),
      dominantColors: List<String>.from(json['dominantColors'] ?? []),
    );
  }
}

class TrendData {
  final List<dynamic> interestOverTime;
  final List<dynamic> relatedQueries;

  TrendData({
    required this.interestOverTime,
    required this.relatedQueries,
  });

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      interestOverTime: List<dynamic>.from(json['interestOverTime'] ?? []),
      relatedQueries: List<dynamic>.from(json['relatedQueries'] ?? []),
    );
  }
}

class ProductResult {
  final String name;
  final String price;
  final String imageUrl;
  final String? productUrl;
  final String? brand;
  final String source; // 'Shein' or 'Zappos'

  ProductResult({
    required this.name,
    required this.price,
    required this.imageUrl,
    this.productUrl,
    this.brand,
    required this.source,
  });

  factory ProductResult.fromShein(Map<String, dynamic> json) {
    return ProductResult(
      name: json['goods_name'] ?? 'Unknown Item',
      price: json['sale_price'] != null ? '\$${json['sale_price']['amount']}' : 'N/A',
      imageUrl: json['goods_img'] ?? '',
      productUrl: null, // Shein API might not return direct URL easily without detail call
      brand: 'Shein',
      source: 'Shein',
    );
  }

  factory ProductResult.fromZappos(Map<String, dynamic> json) {
    return ProductResult(
      name: json['productName'] ?? 'Unknown Item',
      price: json['price'] ?? 'N/A',
      imageUrl: json['thumbnailImageUrl'] ?? '',
      productUrl: json['productUrl'],
      brand: json['brandName'],
      source: 'Zappos',
    );
  }
}
