class Smartphone {
  final int? id;
  final String model;
  final String brand;
  final int ram;
  final int storage;
  final double price;
  final String? imageUrl;
  final String? websiteUrl;

  Smartphone({
    this.id,
    required this.model,
    required this.brand,
    required this.ram,
    required this.storage,
    required this.price,
    this.imageUrl,
    this.websiteUrl,
  });

  factory Smartphone.fromJson(Map<String, dynamic> json) {
    return Smartphone(
      id: json['id'],
      model: json['model'],
      brand: json['brand'],
      ram: json['ram'] ?? 0,
      storage: json['storage'] ?? 0,
      price: json['price']?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'],
      websiteUrl: json['websiteUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'brand': brand,
      'ram': ram,
      'storage': storage,
      'price': price,
      'imageUrl' : imageUrl,
    };
  }
} 