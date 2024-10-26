import 'package:data_widget/data_widget.dart';
import 'package:data_widget/extension.dart';
import 'package:flutter/material.dart';

import '../cart.dart';
import '../components/cart_tile.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final DebounceController _debounceController = DebounceController();

  @override
  Widget build(BuildContext context) {
    final cartManager = context.of<CartManager>();
    return MultiModel(
      data: [
        // Every CartTile shares the same DebounceController
        Model(#cartItemDebouncer, _debounceController),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cart Page'),
        ),
        body: ValueListenableBuilder(
          valueListenable: cartManager.cartItemsListenable,
          builder: (context, value, child) {
            return ListView(
              children: value.entries.map((entry) {
                final key = entry.key;
                final value = entry.value;
                return CartTile(
                  product: key,
                  value: value,
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
