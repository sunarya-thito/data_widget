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

abstract class ValueBound<T> {
  ValueListenable<T> get source;
  ValueChangeNotifier<T> get target;

  void assertDebugTargetChange();

  void bind();
  void unbind();
}

class UniDirectionalValueBound<T> extends ValueBound<T> {
  final ValueListenable<T> source;
  final ValueChangeNotifier<T> target;

  UniDirectionalValueBound(this.source, this.target);

  @override
  void bind() {
    target.value = source.value;
    source.addListener(_listener);
  }

  void _listener() {
    // This is to skip the target value change assertion
    target._internalSetValue(source.value);
  }

  @override
  void unbind() {
    source.removeListener(_listener);
  }

  @override
  void assertDebugTargetChange() {
    throw AssertionError(
        'Changing the target value of a unidirectional bound is prohibited');
  }
}

class BiDirectionalValueBound<T> extends ValueBound<T> {
  static const int _changeDirectionSource = 1;
  static const int _changeDirectionTarget = 2;
  final ValueNotifier<T> source;
  final ValueChangeNotifier<T> target;

  BiDirectionalValueBound(this.source, this.target);

  int? _changeDirection;

  @override
  void bind() {
    target.value = source.value;
    source.addListener(_sourceListener);
    target.addListener(_targetListener);
  }

  void _sourceListener() {
    if (_changeDirection == _changeDirectionTarget) return;
    _changeDirection = _changeDirectionSource;
    target.value = source.value;
    _changeDirection = null;
  }

  void _targetListener() {
    if (_changeDirection == _changeDirectionSource) return;
    _changeDirection = _changeDirectionTarget;
    source.value = target.value;
    _changeDirection = null;
  }

  @override
  void unbind() {
    source.removeListener(_sourceListener);
    target.removeListener(_targetListener);
  }

  @override
  void assertDebugTargetChange() {
    // Do nothing
  }
}

/// A value notifier class that notifies listeners of changes.
class ValueChangeNotifier<T>
    with ChangesNotifierHelperMixin
    implements ValueNotifier<T> {
  T _value;
  ValueBound<T>? _bound;

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

  bool get isBound => _bound != null;

  ValueBound<T>? get bound => _bound;

  void unbind() {
    if (_bound == null) return;
    _bound!.unbind();
    _bound = null;
  }

  void uniDirectionalBind(ValueListenable<T> source) {
    unbind();
    var binding = UniDirectionalValueBound(source, this);
    binding.bind();
    _bound = binding;
  }

  void biDirectionalBind(ValueNotifier<T> source) {
    unbind();
    var binding = BiDirectionalValueBound(source, this);
    binding.bind();
    _bound = binding;
  }

  @override
  T get value => _value;

  @override
  set value(T newValue) {
    assert(() {
      if (_bound != null) {
        _bound!.assertDebugTargetChange();
      }
      return true;
    }());
    _internalSetValue(newValue);
  }

  void _internalSetValue(T newValue) {
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

  @override
  @protected
  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  void notifyListeners() {
    throw UnsupportedError('Use defaultNotifyListeners instead');
  }
}
