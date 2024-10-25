import 'package:data_widget/data_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'ValueNotifier change listener test',
    () {
      ValueChangeNotifier<int> notifier = ValueChangeNotifier(0);
      int? value;
      int? previous;
      notifier.addChangeListener((v, p) {
        value = v;
        previous = p;
      });
      notifier.value = 1;
      expect(value, 1);
      expect(previous, 0);
    },
  );
  test('ValueNotifier listener test', () {
    ValueChangeNotifier<int> notifier = ValueChangeNotifier(0);
    int? value;
    notifier.addListener(() {
      value = notifier.value;
    });
    notifier.value = 1;
    expect(value, 1);
  });
}
