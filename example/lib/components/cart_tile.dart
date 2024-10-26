import 'package:data_widget/data_widget.dart';
import 'package:data_widget/extension.dart';
import 'package:example/components/loading_overlay.dart';
import 'package:example/product.dart';
import 'package:flutter/material.dart';

import '../cart.dart';

class CartTile extends StatefulWidget {
  final Product product;
  final int value;

  const CartTile({Key? key, required this.product, required this.value})
      : super(key: key);

  @override
  State<CartTile> createState() => _CartTileState();
}

class _CartTileState extends State<CartTile> {
  late int _value;
  late DebounceController _debounceController;
  late CartManager _cartManager;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _debounceController = context.model<DebounceController>(#cartItemDebouncer);
    _cartManager = context.of<CartManager>();
  }

  void _increase(int amount) {
    setState(() {
      _value += amount;
      if (_value == 0) {
        _remove();
        return;
      }
      _debounceController.debounce(() {
        _cartManager.changeQuantity(widget.product, _value);
      });
    });
  }

  void _remove() {
    _debounceController.cancel();
    OverlayEntry entry = OverlayEntry(
      builder: (context) {
        return const LoadingOverlay();
      },
    );
    Overlay.of(context).insert(entry);
    _cartManager.removeFromCart(widget.product).whenComplete(() {
      entry.remove();
    }).onError((error, stackTrace) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to remove item: $error'),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return ListTile(
      title: Text(product.name),
      subtitle: Text('Quantity: $_value'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              _increase(-1);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _increase(1);
            },
          ),
        ],
      ),
    );
  }
}
