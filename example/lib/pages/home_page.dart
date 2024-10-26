import 'package:data_widget/data_widget.dart';
import 'package:data_widget/extension.dart';
import 'package:flutter/material.dart';

import '../cart.dart';
import '../components/product_tile.dart';
import '../product.dart';
import 'cart_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _goToCartPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const CartPage();
    }));
  }

  late Future<List<Product>> _fetchedProductList;
  late ProductManager _productManager;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productManager = context.of<ProductManager>();
    _fetchedProductList = _productManager.fetchProductList();
  }

  @override
  Widget build(BuildContext context) {
    final cartManager = context.of<CartManager>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          ValueListenableBuilder<int>(
            // combine the quantity of all products in the cart
            valueListenable: cartManager.cartItemsListenable.map((value) =>
                value.values.fold(0, (prev, element) => prev + element)),
            builder: (context, value, child) {
              return Badge(
                label: Text(value.toString()),
                isLabelVisible: value > 0,
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: _goToCartPage,
                ),
              );
            },
          ),
        ],
      ),
      body: FutureWidgetBuilder(
        future: _fetchedProductList,
        builder: (context, value) {
          return ListView.builder(
            itemCount: value.length,
            itemBuilder: (context, index) {
              final product = value[index];
              return ProductTile(product: product);
            },
          );
        },
        loadingBuilder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $error'),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _fetchedProductList = _productManager.fetchProductList();
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
