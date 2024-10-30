import 'package:data_widget/data_widget.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  test('Uni directional value binding test', () {
    ValueChangeNotifier<int> valueChangeNotifier = ValueChangeNotifier<int>(0);
    ValueChangeNotifier<int> boundedChangeNotifier =
        ValueChangeNotifier<int>(1);
    expect(boundedChangeNotifier.value, 1);
    boundedChangeNotifier.uniDirectionalBind(valueChangeNotifier);
    expect(boundedChangeNotifier.value, 0);
    valueChangeNotifier.value = 2;
    expect(boundedChangeNotifier.value, 2);
  });
  test('Uni directional value binding assertion test', () {
    ValueChangeNotifier<int> valueChangeNotifier = ValueChangeNotifier<int>(0);
    ValueChangeNotifier<int> boundedChangeNotifier =
        ValueChangeNotifier<int>(1);
    expect(boundedChangeNotifier.value, 1);
    boundedChangeNotifier.uniDirectionalBind(valueChangeNotifier);
    expect(boundedChangeNotifier.value, 0);
    expect(() => boundedChangeNotifier.value = 2, throwsAssertionError);
  });

  test('Bi directional value binding test', () {
    ValueChangeNotifier<int> a = ValueChangeNotifier<int>(0);
    ValueChangeNotifier<int> b = ValueChangeNotifier<int>(1);
    expect(a.value, 0);
    expect(b.value, 1);
    a.biDirectionalBind(b);
    expect(a.value, 1);
    expect(b.value, 1);
    a.value = 2;
    expect(a.value, 2);
    expect(b.value, 2);
    b.value = 3;
    expect(a.value, 3);
    expect(b.value, 3);
  });
}
