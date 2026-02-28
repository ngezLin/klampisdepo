class ItemModel {
  final int id;
  final String name;
  final String? description;
  final int stock;
  final bool isStockManaged;
  final double buyPrice;
  final double price;
  final String? imageUrl;

  ItemModel({
    required this.id,
    required this.name,
    this.description,
    required this.stock,
    required this.isStockManaged,
    required this.buyPrice,
    required this.price,
    this.imageUrl,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      stock: json['stock'] as int,
      isStockManaged: json['is_stock_managed'] as bool? ?? true,
      buyPrice: (json['buy_price'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'stock': stock,
      'is_stock_managed': isStockManaged,
      'buy_price': buyPrice,
      'price': price,
      'image_url': imageUrl,
    };
  }
}
