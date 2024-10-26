import 'package:data_widget/data_widget.dart';
import 'package:example/pages/home_page.dart';
import 'package:example/product.dart';
import 'package:flutter/material.dart';

import 'cart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ProductManager productManager = ProductManager();
  final CartManager cartManager = CartManager();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiData(
      data: [
        Data(productManager),
        Data(cartManager),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      ),
    );
  }
}
