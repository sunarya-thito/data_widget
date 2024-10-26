import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data_widget.dart';

/// A callback that receives a [ListChangeDetails] object.
typedef ListChangeListener<T> = void Function(ListChangeDetails<T> details);

/// A list that can be listened to for changes.
abstract class ListListenable<T> extends ValueListenable<List<T>> {
  @override
  List<T> get value;

  /// Adds a [listener] to be notified of changes.
  void addChangeListener(ListChangeListener<T> listener);

  /// Removes a [listener] from being notified of changes.
  void removeChangeListener(ListChangeListener<T> listener);
}

/// A list change details containing the added, removed, and index of the changes.
class ListChangeDetails<T> {
  /// The added elements.
  final Iterable<T> added;

  /// The removed elements.
  final Iterable<T> removed;

  /// The index of the changes.
  final int index;

  /// Creates a list change details.
  const ListChangeDetails(this.added, this.removed, this.index);
}

class _ListChangeListener<T> extends ChangeListener {
  final ListChangeListener<T> listener;

  _ListChangeListener(this.listener);

  @override
  void dispatch(Object? event) {
    listener(event as ListChangeDetails<T>);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ListChangeListener<T> && other.listener == listener;
  }

  @override
  int get hashCode => listener.hashCode;
}

/// A list that can be listened to for changes and notifies listeners when the list changes.
class ListNotifier<T> extends ListListenable<T>
    with ChangesNotifierHelperMixin, Iterable<T>
    implements List<T> {
  final List<T> _list;

  /// Creates a list notifier.
  ListNotifier([List<T> list = const []]) : _list = List<T>.from(list);

  @override
  List<T> get value => UnmodifiableListView<T>(_list);

  /// Notifies listeners of the changes.
  @protected
  @visibleForOverriding
  @pragma('vm:notify-debugger-on-exception')
  void notifyListeners(ListChangeDetails<T> details) {
    super.defaultNotifyListeners(details);
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
  List<R> cast<R>() {
    return _list.cast<R>();
  }

  @override
  void add(T value) {
    assert(ChangesNotifierHelperMixin.debugAssertNotDisposed(this));
    _list.add(value);
    notifyListeners(ListChangeDetails<T>([value], const [], _list.length - 1));
  }

  @override
  void addAll(Iterable<T> values) {
    assert(ChangesNotifierHelperMixin.debugAssertNotDisposed(this));
    final int index = _list.length;
    _list.addAll(values);
    notifyListeners(ListChangeDetails<T>(values.toList(), const [], index));
  }

  @override
  void insert(int index, T value) {
    assert(ChangesNotifierHelperMixin.debugAssertNotDisposed(this));
    _list.insert(index, value);
    notifyListeners(ListChangeDetails<T>([value], const [], index));
  }

  @override
  void insertAll(int index, Iterable<T> values) {
    assert(ChangesNotifierHelperMixin.debugAssertNotDisposed(this));
    _list.insertAll(index, values);
    notifyListeners(ListChangeDetails<T>(values.toList(), const [], index));
  }

  @override
  void removeRange(int start, int end) {
    assert(ChangesNotifierHelperMixin.debugAssertNotDisposed(this));
    final List<T> removed = _list.sublist(start, end);
    _list.removeRange(start, end);
    notifyListeners(ListChangeDetails<T>(const [], removed, start));
  }

  @override
  void removeWhere(bool Function(T element) test) {
    assert(ChangesNotifierHelperMixin.debugAssertNotDisposed(this));
    final List<T> removed = _list.where(test).toList();
    for (final value in removed) {
      _list.remove(value);
    }
    notifyListeners(ListChangeDetails<T>(const [], removed, 0));
  }

  @override
  void retainWhere(bool Function(T element) test) {
    assert(ChangesNotifierHelperMixin.debugAssertNotDisposed(this));
    final List<T> removed = _list.where((element) => !test(element)).toList();
    for (final value in removed) {
      _list.remove(value);
    }
    notifyListeners(ListChangeDetails<T>(const [], removed, 0));
  }

  @override
  void clear() {
    assert(ChangesNotifierHelperMixin.debugAssertNotDisposed(this));
    if (_list.isNotEmpty) {
      final List<T> removed = List<T>.from(_list);
      _list.clear();
      notifyListeners(ListChangeDetails<T>(const [], removed, 0));
    }
  }

  @override
  void sort([int Function(T a, T b)? compare]) {
    assert(ChangesNotifierHelperMixin.debugAssertNotDisposed(this));
    _list.sort(compare);
    notifyListeners(
        ListChangeDetails<T>(List<T>.from(_list), List<T>.from(_list), 0));
  }

  @override
  void shuffle([Random? random]) {
    assert(ChangesNotifierHelperMixin.debugAssertNotDisposed(this));
    _list.shuffle(random);
    notifyListeners(
        ListChangeDetails<T>(List<T>.from(_list), List<T>.from(_list), 0));
  }

  @override
  void fillRange(int start, int end, [T? fillValue]) {
    assert(ChangesNotifierHelperMixin.debugAssertNotDisposed(this));
    final List<T> removed = _list.sublist(start, end);
    _list.fillRange(start, end, fillValue);
    notifyListeners(ListChangeDetails<T>(List<T>.from(_list), removed, start));
  }

  @override
  void setAll(int index, Iterable<T> values) {
    assert(ChangesNotifierHelperMixin.debugAssertNotDisposed(this));
    final List<T> removed = _list.sublist(index, index + values.length);
    _list.setAll(index, values);
    notifyListeners(ListChangeDetails<T>(List<T>.from(_list), removed, index));
  }

  @override
  void setRange(int start, int end, Iterable<T> newContents,
      [int skipCount = 0]) {
    assert(ChangesNotifierHelperMixin.debugAssertNotDisposed(this));
    final List<T> removed = _list.sublist(start, end);
    _list.setRange(start, end, newContents, skipCount);
    notifyListeners(ListChangeDetails<T>(List<T>.from(_list), removed, start));
  }

  @override
  void replaceRange(int start, int end, Iterable<T> newContents) {
    assert(ChangesNotifierHelperMixin.debugAssertNotDisposed(this));
    final List<T> removed = _list.sublist(start, end);
    _list.replaceRange(start, end, newContents);
    notifyListeners(ListChangeDetails<T>(List<T>.from(_list), removed, start));
  }

  @override
  T operator [](int index) => _list[index];

  @override
  void operator []=(int index, T value) {
    final T removed = _list[index];
    _list[index] = value;
    notifyListeners(ListChangeDetails<T>([value], [removed], index));
  }

  @override
  void addChangeListener(ListChangeListener<T> listener) {
    defaultAddListener(_ListChangeListener<T>(listener));
  }

  @override
  void removeChangeListener(ListChangeListener<T> listener) {
    defaultRemoveListener(_ListChangeListener<T>(listener));
  }

  @override
  Iterator<T> get iterator => _list.iterator;

  @override
  int get length => _list.length;

  @override
  List<T> operator +(List<T> other) {
    return _list + other;
  }

  @override
  Map<int, T> asMap() {
    return _list.asMap();
  }

  @override
  set first(T value) {
    final T removed = _list.first;
    _list.first = value;
    notifyListeners(ListChangeDetails<T>([value], [removed], 0));
  }

  @override
  Iterable<T> getRange(int start, int end) {
    return _list.getRange(start, end);
  }

  @override
  int indexOf(T element, [int start = 0]) {
    return _list.indexOf(element, start);
  }

  @override
  int indexWhere(bool Function(T element) test, [int start = 0]) {
    return _list.indexWhere(test, start);
  }

  @override
  set last(T value) {
    final T removed = _list.last;
    _list.last = value;
    notifyListeners(ListChangeDetails<T>([value], [removed], _list.length - 1));
  }

  @override
  int lastIndexOf(T element, [int? start]) {
    return _list.lastIndexOf(element, start);
  }

  @override
  int lastIndexWhere(bool Function(T element) test, [int? start]) {
    return _list.lastIndexWhere(test, start);
  }

  @override
  set length(int newLength) {
    final List<T> removed = _list.sublist(newLength);
    _list.length = newLength;
    notifyListeners(ListChangeDetails<T>(const [], removed, newLength));
  }

  @override
  Iterable<T> get reversed => _list.reversed;

  @override
  List<T> sublist(int start, [int? end]) {
    return _list.sublist(start, end);
  }

  @override
  bool remove(Object? value) {
    final int index = _list.indexOf(value as T);
    if (index == -1) {
      return false;
    }
    _list.removeAt(index);
    notifyListeners(ListChangeDetails<T>(const [], [value], index));
    return true;
  }

  @override
  T removeAt(int index) {
    final T removed = _list.removeAt(index);
    notifyListeners(ListChangeDetails<T>(const [], [removed], index));
    return removed;
  }

  @override
  T removeLast() {
    final T removed = _list.removeLast();
    notifyListeners(ListChangeDetails<T>(const [], [removed], _list.length));
    return removed;
  }

  @override
  String toString() {
    return 'ListNotifier(value: $_list)';
  }
}
