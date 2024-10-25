import 'package:data_widget/data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  testWidgets('Data.inherit test', (tester) async {
    await tester.pumpWidget(
      const RootWidget(
        child: ChildWidget(),
      ),
    );
    expect(find.text('Counter: 0'), findsOneWidget);
    expect(find.text('Flag: false'), findsOneWidget);

    await tester.tap(find.text('Increment'));
    await tester.pump();
    expect(find.text('Counter: 1'), findsOneWidget);
    expect(find.text('Flag: false'), findsOneWidget);

    await tester.tap(find.text('Toggle'));
    await tester.pump();
    expect(find.text('Counter: 1'), findsOneWidget);
    expect(find.text('Flag: true'), findsOneWidget);
  });

  testWidgets('Data.boundary test', (tester) async {
    await tester.pumpWidget(
      const RootWidget(
        child: BoundaryChildWidget(
          boundaryCounter: true,
          boundaryFlag: true,
          child: ChildWidget(),
        ),
      ),
    );
    expect(find.text('Counter: null'), findsOneWidget);
    expect(find.text('Flag: null'), findsOneWidget);

    await tester.tap(find.text('Increment'));
    await tester.pump();
    expect(find.text('Counter: null'), findsOneWidget);
    expect(find.text('Flag: null'), findsOneWidget);

    await tester.tap(find.text('Toggle'));
    await tester.pump();
    expect(find.text('Counter: null'), findsOneWidget);
    expect(find.text('Flag: null'), findsOneWidget);
  });

  testWidgets('DataBuilder test', (tester) async {
    await tester.pumpWidget(
      const RootWidget(
        child: ChildBuilderWidget(),
      ),
    );
    expect(find.text('Counter: 0'), findsOneWidget);
    expect(find.text('Flag: false'), findsOneWidget);

    await tester.tap(find.text('Increment'));
    await tester.pump();
    expect(find.text('Counter: 1'), findsOneWidget);
    expect(find.text('Flag: false'), findsOneWidget);

    await tester.tap(find.text('Toggle'));
    await tester.pump();
    expect(find.text('Counter: 1'), findsOneWidget);
    expect(find.text('Flag: true'), findsOneWidget);
  });
}

class ShadcnTester extends StatelessWidget {
  final Widget child;

  const ShadcnTester({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }
}

class RootWidget extends StatefulWidget {
  final Widget child;

  const RootWidget({super.key, required this.child});

  @override
  State<RootWidget> createState() => RootWidgetState();
}

class RootWidgetState extends State<RootWidget> {
  int _counter = 0;
  bool _flag = false;

  void increment() {
    setState(() {
      _counter++;
    });
  }

  void toggle() {
    setState(() {
      _flag = !_flag;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShadcnTester(
      child: Data.inherit(
        data: _counter,
        child: Data.inherit(
          data: _flag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.child,
              ElevatedButton(
                onPressed: increment,
                child: const Text('Increment'),
              ),
              ElevatedButton(
                onPressed: toggle,
                child: const Text('Toggle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BoundaryChildWidget extends StatelessWidget {
  final bool boundaryCounter;
  final bool boundaryFlag;
  final Widget child;

  const BoundaryChildWidget({
    super.key,
    required this.boundaryCounter,
    required this.boundaryFlag,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = this.child;
    if (boundaryCounter) {
      child = Data<int>.boundary(
        child: child,
      );
    }
    if (boundaryFlag) {
      child = Data<bool>.boundary(
        child: child,
      );
    }
    return child;
  }
}

class ChildWidget extends StatelessWidget {
  const ChildWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final counter = Data.maybeOf<int>(context);
    final flag = Data.maybeOf<bool>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Counter: $counter'),
        Text('Flag: $flag'),
      ],
    );
  }
}

class ChildBuilderWidget extends StatelessWidget {
  const ChildBuilderWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return DataBuilder<int>(
      builder: (context, counter, _) {
        return DataBuilder<bool>(
          builder: (context, flag, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Counter: $counter'),
                Text('Flag: $flag'),
              ],
            );
          },
        );
      },
    );
  }
}
