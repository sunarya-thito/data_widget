import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../data_widget.dart';

class _SetChangeListener<T> extends ChangeListener {
  final SetChangeListener<T> listener;

  _SetChangeListener(this.listener);

  @override
  void dispatch(Object? event) {
    listener(event as SetChangeDetails<T>);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _SetChangeListener<T> && other.listener == listener;
  }

  @override
  int get hashCode => listener.hashCode;
}

/// A set change details containing the added and removed elements.
class SetChangeDetails<T> {
  /// The added elements.
  final Iterable<T> added;

  /// The removed elements.
  final Iterable<T> removed;

  /// Creates a set change details.
  const SetChangeDetails(this.added, this.removed);
}

/// A set that can be listened to for changes.
abstract class SetListenable<T> extends ValueListenable<Set<T>> {
  @override
  Set<T> get value;

  /// Adds a [listener] to be notified of changes.
  void addChangeListener(SetChangeListener<T> listener);

  /// Removes a [listener] from being notified of changes.
  void removeChangeListener(SetChangeListener<T> listener);
}

/// A set that can be listened to for changes and notifies listeners when the set changes.
typedef SetChangeListener<T> = void Function(SetChangeDetails<T> details);

/// A set notifier class that allows mutable updates and notifies listeners of changes.
class SetNotifier<T> extends SetListenable<T>
    with ChangesNotifierHelperMixin, Iterable<T>
    implements Set<T> {
  final Set<T> _set;

  /// Constructs a [SetNotifier] with an initial set.
  SetNotifier([Set<T> set = const {}]) : _set = Set<T>.from(set);

  @override
  Set<T> get value => UnmodifiableSetView<T>(_set);

  Set<T> _helperToSet(Iterable<T> iterable) {
    return iterable is Set<T> ? iterable : iterable.toSet();
  }

  @override
  Set<R> cast<R>() {
    return _set.cast<R>();
  }

  @override
  void addAll(Iterable<T> values) {
    assert(ChangesNotifierHelperMixin.debugAssertNotDisposed(this));
    final Set<T> added = _helperToSet(values).difference(_set);
    if (added.isNotEmpty) {
      _set.addAll(added);
      notifyListeners(SetChangeDetails<T>(added, const []));
    }
  }

  @override
  void clear() {
    assert(ChangesNotifierHelperMixin.debugAssertNotDisposed(this));
    if (_set.isNotEmpty) {
      final Set<T> removed = Set<T>.from(_set);
      _set.clear();
      notifyListeners(SetChangeDetails<T>(const [], removed));
    }
  }

  @override
  void addChangeListener(SetChangeListener<T> listener) {
    defaultAddListener(_SetChangeListener<T>(listener));
  }

  @override
  void removeChangeListener(SetChangeListener<T> listener) {
    defaultRemoveListener(_SetChangeListener<T>(listener));
  }

  @override
  void addListener(VoidCallback listener) {
    defaultAddListener(VoidChangeListener(listener));
  }

  @override
  void removeListener(VoidCallback listener) {
    defaultRemoveListener(VoidChangeListener(listener));
  }

  /// Notifies listeners of changes.
  @protected
  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  void notifyListeners(SetChangeDetails<T> details) {
    super.defaultNotifyListeners(details);
  }

  @override
  Iterator<T> get iterator => _set.iterator;

  @override
  int get length => _set.length;

  @override
  bool containsAll(Iterable<Object?> other) {
    return _set.containsAll(other);
  }

  @override
  Set<T> difference(Set<Object?> other) {
    return _set.difference(other);
  }

  @override
  Set<T> intersection(Set<Object?> other) {
    return _set.intersection(other);
  }

  @override
  T? lookup(Object? object) {
    return _set.lookup(object);
  }

  @override
  void removeWhere(bool Function(T element) test) {
    final Set<T> removed = _set.where(test).toSet();
    _set.removeAll(removed);
    notifyListeners(SetChangeDetails<T>(const [], removed));
  }

  @override
  void retainAll(Iterable<Object?> elements) {
    final Set<T> removed =
        _set.where((element) => !elements.contains(element)).toSet();
    _set.retainAll(elements);
    notifyListeners(SetChangeDetails<T>(const [], removed));
  }

  @override
  void retainWhere(bool Function(T element) test) {
    final Set<T> removed = _set.where((element) => !test(element)).toSet();
    _set.retainWhere(test);
    notifyListeners(SetChangeDetails<T>(const [], removed));
  }

  @override
  Set<T> union(Set<T> other) {
    return _set.union(other);
  }

  @override
  bool add(T value) {
    assert(ChangesNotifierHelperMixin.debugAssertNotDisposed(this));
    if (_set.add(value)) {
      notifyListeners(SetChangeDetails<T>([value], const []));
      return true;
    }
    return false;
  }

  @override
  bool remove(Object? value) {
    assert(ChangesNotifierHelperMixin.debugAssertNotDisposed(this));
    if (_set.remove(value)) {
      notifyListeners(SetChangeDetails<T>(const [], [value as T]));
      return true;
    }
    return false;
  }

  @override
  void removeAll(Iterable<Object?> elements) {
    assert(ChangesNotifierHelperMixin.debugAssertNotDisposed(this));
    List<T> removed = [];
    for (final element in elements) {
      if (_set.remove(element)) {
        removed.add(element as T);
      }
    }
    if (removed.isNotEmpty) {
      notifyListeners(SetChangeDetails<T>(const [], removed));
    }
  }

  @override
  String toString() {
    return 'SetNotifier(value: $_set)';
  }
}
