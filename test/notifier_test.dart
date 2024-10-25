import 'package:data_widget/data_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MutableNotifier<T> listener test', () {
    MutableNotifier<List<int>> list = MutableNotifier([1, 2, 3]);
    bool listenerCalled = false;
    list.addListener(() {
      listenerCalled = true;
    });
    list.mutate((value) => value.add(12));
    list.mutate((value) {
      value.add(4);
      return true;
    });
    expect(listenerCalled, true);
  });

  test('MutableNotifier<T> cancel listener test', () {
    MutableNotifier<List<int>> list = MutableNotifier([1, 2, 3]);
    bool listenerCalled = false;
    list.addListener(() {
      listenerCalled = true;
    });
    list.mutate((value) {
      value.add(4);
      return false;
    });
    expect(listenerCalled, false);
  });

  test('ValueNotifierExtension test', () {
    ValueChangeNotifier<int> valueNotifier = ValueChangeNotifier(1);
    ValueListenable<int> readOnly = valueNotifier.readOnly();
    expect(readOnly.value, 1);
    bool listenerCalled = false;
    readOnly.addListener(() {
      listenerCalled = true;
    });
    valueNotifier.value = 2;
    expect(listenerCalled, true);
  });
}
