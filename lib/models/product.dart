class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imagePath;
  final String category;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    required this.category,
  });

  /// Cria um Product a partir de um documento do Firestore.
  factory Product.fromMap(String id, Map<String, dynamic> m) {
    return Product(
      id: id,
      name: m['name'] as String? ?? '',
      description: m['description'] as String? ?? '',
      price: (m['price'] as num?)?.toDouble() ?? 0.0,
      imagePath: m['imagePath'] as String? ?? 'assets/images/acai.jpg',
      category: m['category'] as String? ?? '',
    );
  }

  /// Converte o Product para Map (usado no script de importação e nos pedidos).
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imagePath': imagePath,
      'category': category,
    };
  }
}