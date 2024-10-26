class Product {
  final String name;
  final String description;
  final double price;

  const Product({
    required this.name,
    required this.description,
    required this.price,
  });

  @override
  String toString() {
    return 'Product(name: $name, description: $description, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product &&
        other.name == name &&
        other.description == description &&
        other.price == price;
  }

  @override
  int get hashCode {
    return Object.hash(name, description, price);
  }
}

class ProductManager {
  final List<Product> _products = [
    // courses for beginners
    const Product(
      name: 'Dart for Beginners',
      description: 'Learn Dart Programming from scratch',
      price: 19.99,
    ),
    const Product(
      name: 'Flutter for Beginners',
      description: 'Learn Flutter Development from scratch',
      price: 29.99,
    ),
    const Product(
      name: 'React for Beginners',
      description: 'Learn React Development from scratch',
      price: 39.99,
    ),
    const Product(
      name: 'Angular for Beginners',
      description: 'Learn Angular Development from scratch',
      price: 49.99,
    ),
    const Product(
      name: 'Vue for Beginners',
      description: 'Learn Vue Development from scratch',
      price: 59.99,
    ),
    const Product(
      name: 'Svelte for Beginners',
      description: 'Learn Svelte Development from scratch',
      price: 69.99,
    ),
    const Product(
      name: 'Ember for Beginners',
      description: 'Learn Ember Development from scratch',
      price: 79.99,
    ),
    const Product(
      name: 'Backbone for Beginners',
      description: 'Learn Backbone Development from scratch',
      price: 89.99,
    ),
  ];

  Future<List<Product>> fetchProductList() async {
    // simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    return _products;
  }

  Future<List<Product>> searchProduct(String query) async {
    // simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    return _products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
