import 'package:flutter/foundation.dart';

import '../data_widget.dart';

/// A callback that receives a value and the previous value.
typedef ValueChangeListener<T> = void Function(T value, T previous);

class _ValueChangeListener<T> extends ChangeListener {
  final ValueChangeListener<T> listener;

  _ValueChangeListener(this.listener);

  @override
  void dispatch(Object? event) {
    var change = event as (T, T);
    listener(change.$1, change.$2);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ValueChangeListener<T> && other.listener == listener;
  }

  @override
  int get hashCode => listener.hashCode;
}

/// A value notifier class that notifies listeners of changes.
class ValueChangeNotifier<T>
    with ChangesNotifierHelperMixin
    implements ValueListenable<T> {
  T _value;

  /// Constructs a [ValueChangeNotifier] with an initial value.
  ValueChangeNotifier(this._value);

  /// Adds a [listener] to be notified of changes.
  void addChangeListener(ValueChangeListener<T> listener) {
    defaultAddListener(_ValueChangeListener(listener));
  }

  /// Removes a [listener] from being notified of changes.
  void removeChangeListener(ValueChangeListener<T> listener) {
    defaultRemoveListener(_ValueChangeListener(listener));
  }

  @override
  T get value => _value;

  set value(T newValue) {
    if (_value == newValue) return;
    var previous = _value;
    _value = newValue;
    defaultNotifyListeners((newValue, previous));
  }

  @override
  void addListener(VoidCallback listener) {
    defaultAddListener(VoidChangeListener(listener));
  }

  @override
  void removeListener(VoidCallback listener) {
    defaultRemoveListener(VoidChangeListener(listener));
  }

  @override
  String toString() {
    return 'ValueChangeNotifier(value: $_value)';
  }
}
