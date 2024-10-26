import 'package:data_widget/src/async.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  test('debounce test', () {
    DebounceController controller = DebounceController();

    int count = 0;
    controller.debounce(() {
      count = 1;
    }, duration: const Duration(milliseconds: 100));
    expect(count, 0);
  });
  test('debounce test wait', () async {
    DebounceController controller = DebounceController();

    int count = 0;
    controller.debounce(() {
      count = 1;
    }, duration: const Duration(milliseconds: 100));
    await Future.delayed(const Duration(milliseconds: 100));
    expect(count, 1);
  });
  test('debounce test multiple', () async {
    DebounceController controller = DebounceController();

    int count = 0;
    controller.debounce(() {
      count = 1;
    }, duration: const Duration(milliseconds: 100));
    controller.debounce(() {
      count = 2;
    }, duration: const Duration(milliseconds: 100));
    await Future.delayed(const Duration(milliseconds: 200));
    expect(count, 2);
  });
  test('throttle test', () async {
    DebounceController controller = DebounceController();

    int count = 0;
    controller.throttle(() {
      count = 1;
    }, duration: const Duration(milliseconds: 100));
    controller.throttle(() {
      count = 2;
    }, duration: const Duration(milliseconds: 100));
    expect(count, 1);
  });
  test('throttle test multiple', () async {
    DebounceController controller = DebounceController();

    int count = 0;
    controller.throttle(() {
      count = 1;
    }, duration: const Duration(milliseconds: 100));
    expect(count, 1);
    await Future.delayed(const Duration(milliseconds: 100));
    controller.throttle(() {
      count = 2;
    }, duration: const Duration(milliseconds: 100));
    expect(count, 2);
  });
  test('throttle future test', () async {
    DebounceController controller = DebounceController();

    int count = 0;
    controller.throttleFuture(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      count = 1;
      return count;
    });
    expect(count, 0);
    await Future.delayed(const Duration(milliseconds: 100));
    expect(count, 1);
  });
  test('throttle future test multiple', () async {
    DebounceController controller = DebounceController();

    int count = 0;
    controller.throttleFuture(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      count = 1;
      return count;
    });
    controller.throttleFuture(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      count = 2;
      return count;
    });
    expect(count, 0);
    await Future.delayed(const Duration(milliseconds: 100));
    expect(count, 1);
  });
  test('throttle future test multiple wait', () async {
    DebounceController controller = DebounceController();

    int count = 0;
    controller.throttleFuture(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      count = 1;
      return count;
    });
    await Future.delayed(const Duration(milliseconds: 100));
    controller.throttleFuture(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      count = 2;
      return count;
    });
    await Future.delayed(const Duration(milliseconds: 100));
    expect(count, 2);
  });
}
