import 'package:data_widget/extension.dart';
import 'package:flutter/material.dart';

import '../cart.dart';
import '../product.dart';
import 'loading_overlay.dart';

class ProductTile extends StatefulWidget {
  final Product product;

  const ProductTile({super.key, required this.product});

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  void _addToCardDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.product.name),
          content: Text(widget.product.description),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addToCardConfirm();
              },
              child: const Text('Add to Cart'),
            ),
          ],
        );
      },
    );
  }

  void _addToCardConfirm() {
    OverlayEntry overlay = OverlayEntry(
      builder: (context) {
        return const LoadingOverlay();
      },
    );
    Overlay.of(context).insert(overlay);
    final cartManager = context.of<CartManager>();
    cartManager.addToCart(widget.product).onError(
      (error, stackTrace) {
        _onAddToCardError(error, stackTrace);
      },
    ).then((value) {
      _onAddToCardSuccess();
    }).whenComplete(() {
      overlay.remove();
    });
  }

  void _onAddToCardError(Object? error, StackTrace stackTrace) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _onAddToCardSuccess() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Added to cart'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.product.name),
      subtitle: Text(widget.product.description),
      trailing: Text(widget.product.price.toString()),
      onTap: _addToCardDialog,
    );
  }
}
