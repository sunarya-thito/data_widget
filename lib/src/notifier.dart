import 'package:flutter/foundation.dart';

import '../data_widget.dart';

/// A notifier class that allows mutable updates and notifies listeners of changes.
class MutableNotifier<T> extends ValueNotifier<T> {
  /// Constructs a [MutableNotifier] with an initial value.
  MutableNotifier(super.value);

  /// Updates the value using the provided [updater] function.
  /// If the [updater] returns `null` or `true`, listeners are notified.
  void mutate(Function(T value) updater) {
    var result = updater(value);
    if (result is T && result != value) {
      value = result;
    } else if (result == null || result == true) {
      notifyListeners();
    }
  }
}

/// Extension on [ValueNotifier] to provide a read-only view.
extension ValueNotifierExtension<T> on ValueNotifier<T> {
  /// Returns a read-only view of the [ValueNotifier].
  ValueListenable<T> readOnly() {
    return ValueNotifierUnmodifiableView(this);
  }

  ValueListenable<R> map<R>(R Function(T value) mapper) {
    return MappedValueNotifier(this, mapper);
  }
}

extension ValueListenableExtension<T> on ValueListenable<T> {
  ValueListenable<R> map<R>(R Function(T value) mapper) {
    return MappedValueNotifier(this, mapper);
  }
}

extension ValueChangeNotifierExtension<T> on ValueChangeNotifier<T> {
  ValueListenable<T> readOnly() {
    return ValueNotifierUnmodifiableView(this);
  }

  ValueListenable<R> map<R>(R Function(T value) mapper) {
    return MappedValueNotifier(this, mapper);
  }
}

/// A read-only view of a [ValueListenable].
class ValueNotifierUnmodifiableView<T> extends ValueListenable<T> {
  final ValueListenable<T> _notifier;

  /// Constructs a [ValueNotifierUnmodifiableView] with the given [ValueListenable].
  ValueNotifierUnmodifiableView(this._notifier);

  @override
  T get value => _notifier.value;

  @override
  void addListener(VoidCallback listener) {
    _notifier.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _notifier.removeListener(listener);
  }
}

class MappedValueNotifier<T, R> extends ValueListenable<R> {
  final ValueListenable<T> _notifier;
  final R Function(T value) _mapper;

  MappedValueNotifier(this._notifier, this._mapper);

  @override
  R get value => _mapper(_notifier.value);

  @override
  void addListener(VoidCallback listener) {
    _notifier.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _notifier.removeListener(listener);
  }
}
