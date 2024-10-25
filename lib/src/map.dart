import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../data_widget.dart';

class MapChangeDetails<K, V> {
  final Iterable<MapEntry<K, V>> added;
  final Iterable<MapEntry<K, V>> removed;

  const MapChangeDetails(this.added, this.removed);
}

typedef MapChangeListener<K, V> = void Function(MapChangeDetails<K, V> details);

abstract class MapListenable<K, V> extends ValueListenable<Map<K, V>> {
  @override
  Map<K, V> get value;
  void addChangeListener(MapChangeListener<K, V> listener);
  void removeChangeListener(MapChangeListener<K, V> listener);
}

class _MapChangeListener<K, V> extends ChangeListener {
  final MapChangeListener<K, V> listener;

  _MapChangeListener(this.listener);

  @override
  void dispatch(Object? event) {
    listener(event as MapChangeDetails<K, V>);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _MapChangeListener<K, V> && other.listener == listener;
  }

  @override
  int get hashCode => listener.hashCode;
}

class MapNotifier<K, V> extends MapListenable<K, V>
    with ChangesNotifierHelperMixin
    implements Map<K, V> {
  final Map<K, V> _map;

  MapNotifier([Map<K, V> map = const {}]) : _map = Map<K, V>.from(map);

  @override
  Map<K, V> get value => UnmodifiableMapView<K, V>(_map);

  @protected
  void notifyListeners(MapChangeDetails<K, V> details) {
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
  V? operator [](Object? key) {
    return _map[key];
  }

  @override
  void operator []=(K key, V value) {
    bool containsKey = _map.containsKey(key);
    V? removed = containsKey ? _map[key] : null;
    _map[key] = value;
    notifyListeners(MapChangeDetails<K, V>([MapEntry(key, value)],
        [if (containsKey) MapEntry(key, removed as V)]));
  }

  @override
  void addAll(Map<K, V> other) {
    final List<MapEntry<K, V>> added = [];
    final List<MapEntry<K, V>> removed = [];
    for (final entry in other.entries) {
      if (_map.containsKey(entry.key)) {
        removed.add(MapEntry(entry.key, _map[entry.key] as V));
      }
      added.add(entry);
    }
    _map.addAll(other);
    notifyListeners(MapChangeDetails<K, V>(added, removed));
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> newEntries) {
    final List<MapEntry<K, V>> added = [];
    final List<MapEntry<K, V>> removed = [];
    for (final entry in newEntries) {
      if (_map.containsKey(entry.key)) {
        removed.add(MapEntry(entry.key, _map[entry.key] as V));
      }
      added.add(entry);
    }
    _map.addEntries(newEntries);
    notifyListeners(MapChangeDetails<K, V>(added, removed));
  }

  @override
  void addChangeListener(MapChangeListener<K, V> listener) {
    defaultAddListener(_MapChangeListener<K, V>(listener));
  }

  @override
  Map<RK, RV> cast<RK, RV>() {
    return _map.cast<RK, RV>();
  }

  @override
  void clear() {
    final List<MapEntry<K, V>> removed = _map.entries.toList();
    _map.clear();
    notifyListeners(MapChangeDetails<K, V>(const [], removed));
  }

  @override
  bool containsKey(Object? key) {
    return _map.containsKey(key);
  }

  @override
  bool containsValue(Object? value) {
    return _map.containsValue(value);
  }

  @override
  Iterable<MapEntry<K, V>> get entries => _map.entries;

  @override
  void forEach(void Function(K key, V value) action) {
    _map.forEach(action);
  }

  @override
  bool get isEmpty => _map.isEmpty;

  @override
  bool get isNotEmpty => _map.isNotEmpty;

  @override
  Iterable<K> get keys => _map.keys;

  @override
  int get length => _map.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) convert) {
    return _map.map(convert);
  }

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    final bool containsKey = _map.containsKey(key);
    V? removed = containsKey ? _map[key] : null;
    V value = _map.putIfAbsent(key, ifAbsent);
    if (containsKey) {
      notifyListeners(MapChangeDetails<K, V>(
          [MapEntry(key, value)], [MapEntry(key, removed as V)]));
    } else {
      notifyListeners(MapChangeDetails<K, V>([MapEntry(key, value)], []));
    }
    return value;
  }

  @override
  V? remove(Object? key) {
    if (!_map.containsKey(key)) {
      return null;
    }
    V removed = _map.remove(key) as V;
    notifyListeners(MapChangeDetails<K, V>([], [MapEntry(key as K, removed)]));
    return removed;
  }

  @override
  void removeChangeListener(MapChangeListener<K, V> listener) {
    defaultRemoveListener(_MapChangeListener<K, V>(listener));
  }

  @override
  void removeWhere(bool Function(K key, V value) test) {
    final List<MapEntry<K, V>> removed = [];
    for (final entry in _map.entries) {
      if (test(entry.key, entry.value)) {
        removed.add(entry);
      }
    }
    for (final entry in removed) {
      _map.remove(entry.key);
    }
    notifyListeners(MapChangeDetails<K, V>([], removed));
  }

  @override
  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) {
    final bool containsKey = _map.containsKey(key);
    V? removed = containsKey ? _map[key] : null;
    V value = _map.update(key, update, ifAbsent: ifAbsent);
    if (containsKey) {
      notifyListeners(MapChangeDetails<K, V>(
          [MapEntry(key, value)], [MapEntry(key, removed as V)]));
    } else {
      notifyListeners(MapChangeDetails<K, V>([MapEntry(key, value)], []));
    }
    return value;
  }

  @override
  void updateAll(V Function(K key, V value) update) {
    final List<MapEntry<K, V>> added = [];
    final List<MapEntry<K, V>> removed = [];
    for (final entry in _map.entries) {
      V newValue = update(entry.key, entry.value);
      if (_map.containsKey(entry.key)) {
        removed.add(MapEntry(entry.key, _map[entry.key] as V));
      }
      added.add(MapEntry(entry.key, newValue));
    }
    _map.updateAll(update);
    notifyListeners(MapChangeDetails<K, V>(added, removed));
  }

  @override
  Iterable<V> get values => _map.values;

  @override
  String toString() {
    return 'MapNotifier(value: $_map)';
  }
}
