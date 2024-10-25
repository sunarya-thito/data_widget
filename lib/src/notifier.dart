import 'package:flutter/foundation.dart';

import '../data_widget.dart';

/// A notifier class that allows mutable updates and notifies listeners of changes.
class MutableNotifier<T> implements ValueListenable<T> {
  final EventNotifier _notifier = EventNotifier();

  @override
  final T value;

  /// Constructs a [MutableNotifier] with an initial value.
  MutableNotifier(this.value);

  /// Updates the value using the provided [updater] function.
  /// If the [updater] returns `null` or `true`, listeners are notified.
  void setValue(bool? Function(T) updater) {
    var result = updater(value);
    if (result == null || result) {
      _notifier.notify();
    }
  }

  @override
  void addListener(VoidCallback listener) {
    _notifier.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _notifier.removeListener(listener);
  }
}

/// A notifier class that extends [ChangeNotifier] to provide custom notification logic.
class EventNotifier extends ChangeNotifier {
  /// Notifies all registered listeners.
  void notify() {
    notifyListeners();
  }

  /// Creates a [ValueListenable] that hooks into the current notifier and provides a value.
  ValueListenable<T> hookWithValue<T>(T Function() getValue) {
    return _ValueHookListenable(getValue, this);
  }
}

/// Extension on [ValueNotifier] to provide a read-only view.
extension ValueNotifierExtension<T> on ValueNotifier<T> {
  /// Returns a read-only view of the [ValueNotifier].
  ValueListenable<T> readOnly() {
    return ValueNotifierUnmodifiableView(this);
  }
}

extension ValueChangeNotifierExtension<T> on ValueChangeNotifier<T> {
  ValueListenable<T> readOnly() {
    return ValueNotifierUnmodifiableView(this);
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

/// A [ValueListenable] that hooks into an [EventNotifier] and provides a value.
class _ValueHookListenable<T> extends ValueListenable<T> {
  final T Function() _getValue;
  final EventNotifier _notifier;

  /// Constructs a [_ValueHookListenable] with the given value getter and notifier.
  _ValueHookListenable(this._getValue, this._notifier);

  @override
  T get value => _getValue();

  @override
  void addListener(VoidCallback listener) {
    _notifier.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _notifier.removeListener(listener);
  }
}
