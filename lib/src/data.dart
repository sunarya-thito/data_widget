import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

const _kDataWidgetLibrary = 'package:data_widget/data_widget.dart';

/// A mixin that provides a [shouldNotify] method to determine if the data has
/// changed and should notify the listeners.
mixin DistinctData {
  /// Returns true if the data has changed and should notify the listeners.
  bool shouldNotify(covariant DistinctData oldData);
}

/// A mixin that always returns true for [shouldNotify].
/// Which means the data will always notify the listeners regardless of the
/// changes.
mixin AlwaysUpdateData implements DistinctData {
  /// Always returns true.
  @override
  bool shouldNotify(covariant DistinctData oldData) => true;
}

/// An interface that holds forwardable data.
abstract class DataHolder<T> {
  /// Registers a [receiver] that provides the data.
  void register(ForwardableDataState<T> receiver);

  /// Unregisters a [receiver] that provides the data.
  void unregister(ForwardableDataState<T> receiver);

  /// Finds the data of the [type] from the [context].
  T? findData(BuildContext context, Type type);
}

/// An abstract InheritedWidget that passes the DataHolder to its descendants.
abstract class InheritedDataHolderWidget<T> extends InheritedWidget {
  /// Creates an InheritedDataHolderWidget.
  const InheritedDataHolderWidget({required super.child, super.key});

  /// The DataHolder that holds the data.
  DataHolder<T> get holder;
}

/// An InheritedWidget that passes the DataHolder to its descendants.
class InheritedDataHolder<T> extends InheritedDataHolderWidget<T> {
  @override
  final DataHolder<T> holder;

  const InheritedDataHolder({
    super.key,
    required this.holder,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant InheritedDataHolder<T> oldWidget) {
    return oldWidget.holder != holder;
  }
}

/// An InheritedWidget that passes the root DataHolder to its descendants.
class InheritedRootDataHolder extends InheritedDataHolderWidget<dynamic> {
  @override
  final DataHolder<dynamic> holder;

  const InheritedRootDataHolder({
    super.key,
    required this.holder,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant InheritedRootDataHolder oldWidget) {
    return oldWidget.holder != holder;
  }
}

/// DataMessengerRoot is the root of the data messenger tree.
/// The root stores all kinds of forwardable data and provides them to the
/// descendants.
class DataMessengerRoot extends StatefulWidget {
  /// The child widget.
  final Widget child;

  /// Creates a DataMessengerRoot.
  const DataMessengerRoot({
    super.key,
    required this.child,
  });

  @override
  State<DataMessengerRoot> createState() => _DataMessengerRootState();
}

class _DataMessengerRootState extends State<DataMessengerRoot>
    implements DataHolder {
  final Map<Type, LinkedHashSet<ForwardableDataState>> _senders = {};

  @override
  void register(ForwardableDataState receiver) {
    final type = receiver.dataType;
    _senders.putIfAbsent(type, () => LinkedHashSet());
    _senders[type]!.add(receiver);
  }

  @override
  void unregister(ForwardableDataState receiver) {
    final type = receiver.dataType;
    _senders[type]?.remove(receiver);
  }

  @override
  dynamic findData(BuildContext context, Type type) {
    LinkedHashSet<ForwardableDataState>? receivers = _senders[type];
    if (receivers == null) {
      return null;
    }
    for (ForwardableDataState receiver in receivers) {
      var didFindData = false;
      receiver.context.visitAncestorElements((element) {
        if (element == context) {
          didFindData = true;
          return false;
        }
        return true;
      });
      if (didFindData) {
        return receiver.widget.data;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return InheritedRootDataHolder(
      holder: this,
      child: widget.child,
    );
  }
}

/// DataMessenger is a widget that holds the forwardable data.
/// The data is attached/received from the ForwardableData widget
/// and then passed to the descendants. DataMessenger<[T]> can only
/// store ForwardableData<[T]>.
class DataMessenger<T> extends StatefulWidget {
  /// The child widget.
  final Widget child;

  /// Creates a DataMessenger.
  const DataMessenger({
    super.key,
    required this.child,
  });

  @override
  State<DataMessenger<T>> createState() => _DataMessengerState<T>();
}

class _DataMessengerState<T> extends State<DataMessenger<T>>
    implements DataHolder<T> {
  final LinkedHashSet<ForwardableDataState<T>> _receivers = LinkedHashSet();

  @override
  void register(ForwardableDataState<T> receiver) {
    _receivers.add(receiver);
  }

  @override
  void unregister(ForwardableDataState<T> receiver) {
    _receivers.remove(receiver);
  }

  @override
  T? findData(BuildContext context, Type type) {
    for (final receiver in _receivers) {
      var didFindData = false;
      receiver.context.visitAncestorElements((element) {
        if (element == context) {
          didFindData = true;
          return false;
        }
        return true;
      });
      if (didFindData) {
        return receiver.widget.data;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return InheritedDataHolder<T>(
      holder: this,
      child: widget.child,
    );
  }
}

/// A widget that holds the data that can be attached to ancestor holders.
class ForwardableData<T> extends StatefulWidget {
  /// The data that will be forwarded.
  final T data;

  /// The child widget.
  final Widget child;

  /// Creates a ForwardableData.
  const ForwardableData({
    super.key,
    required this.data,
    required this.child,
  });

  @override
  State<ForwardableData<T>> createState() => ForwardableDataState<T>();
}

class ForwardableDataState<T> extends State<ForwardableData<T>> {
  DataHolder? _messenger;

  Type get dataType => T;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    InheritedDataHolderWidget? inheritedDataHolder =
        context.dependOnInheritedWidgetOfExactType<InheritedDataHolder<T>>();
    // if not found, try to find
    inheritedDataHolder ??=
        context.dependOnInheritedWidgetOfExactType<InheritedRootDataHolder>();
    final messenger = inheritedDataHolder?.holder;
    if (messenger != _messenger) {
      _messenger?.unregister(this);
      _messenger = messenger;
      _messenger?.register(this);
    }
  }

  @override
  void dispose() {
    _messenger?.unregister(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Data<T>.inherit(
      data: widget.data,
      child: DataMessenger<T>(
        child: widget.child,
      ),
    );
  }
}

/// An internal interface that provides dataType and wrap method.
abstract class MultiDataItem {
  /// The compile-time type of the data.
  Type get dataType;

  /// Wraps the [child] widget with the data.
  Widget wrapWidget(Widget child);
}

/// A widget that passes value from a ValueListenable to its descendants.
/// The data is refreshed when the ValueListenable changes.
class DataNotifier<T> extends StatelessWidget implements MultiDataItem {
  /// The ValueListenable that holds the data.
  final ValueListenable<T> notifier;
  final Widget? _child;

  /// Creates a DataNotifier for MultiData.
  const DataNotifier(this.notifier, {super.key}) : _child = null;

  /// Creates a single DataNotifier widget.
  const DataNotifier.inherit({
    super.key,
    required this.notifier,
    required Widget child,
  }) : _child = child;

  @override
  Widget wrapWidget(Widget child) {
    return DataNotifier<T>.inherit(
      notifier: notifier,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, value, child) {
        return Data<T>.inherit(
          data: value,
          child: child!,
        );
      },
      child: _child,
    );
  }

  @override
  Type get dataType => T;
}

/// A widget builder that receives the data from the ancestor Data widget.
typedef DataWidgetBuilder<T> = Widget Function(
    BuildContext context, T data, Widget? child);

/// A widget builder that receives the data (that may be null) from the ancestor
typedef OptionalDataWidgetBuilder<T> = Widget Function(
    BuildContext context, T? data, Widget? child);

/// A widget that receives the data from the ancestor Data widget.
class DataBuilder<T> extends StatelessWidget {
  final DataWidgetBuilder<T>? _builder;
  final OptionalDataWidgetBuilder<T>? _optionalBuilder;

  /// The child widget.
  final Widget? child;

  /// Creates a DataBuilder that optionally receives the data.
  const DataBuilder.optionally({
    super.key,
    required OptionalDataWidgetBuilder<T> builder,
    this.child,
  })  : _builder = null,
        _optionalBuilder = builder;

  /// Creates a DataBuilder that must receive the data.
  const DataBuilder({
    super.key,
    required DataWidgetBuilder<T> builder,
    this.child,
  })  : _builder = builder,
        _optionalBuilder = null;

  @override
  Widget build(BuildContext context) {
    final data = Data.maybeOf<T>(context);
    if (_builder != null) {
      assert(data != null, 'No Data<$T> found in context');
      return _builder(context, data as T, child);
    }
    return _optionalBuilder!(context, data, child);
  }
}

/// A widget that provides multiple data to its descendants.
class MultiData extends StatefulWidget {
  /// The list of data that will be provided to the descendants.
  final List<MultiDataItem> data;

  /// The child widget.
  final Widget child;

  /// Creates a MultiData.
  const MultiData({
    super.key,
    required this.data,
    required this.child,
  });

  @override
  State<MultiData> createState() => _MultiDataState();
}

class _MultiDataState extends State<MultiData> {
  final GlobalKey _key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    Widget result = KeyedSubtree(
      key: _key,
      child: widget.child,
    );
    for (final data in widget.data) {
      // make sure dataType is not dynamic
      final Type dataType = data.dataType;
      assert(dataType != dynamic, 'Data must have a type');
      result = data.wrapWidget(result);
    }
    return result;
  }
}

/// A widget that provides the data to its descendants.
class Data<T> extends StatelessWidget implements MultiDataItem {
  final T? _data;

  /// The child widget.
  final Widget? child;

  /// Creates a Data for MultiData.
  const Data(T data, {super.key})
      : _data = data,
        child = null,
        super();

  /// Creates a single Data widget.
  const Data.inherit({
    super.key,
    required T data,
    this.child,
  }) : _data = data;

  /// Creates a boundary Data widget that stops the data from being passed to its descendants.
  const Data.boundary({
    super.key,
    this.child,
  }) : _data = null;

  /// The data that will be provided to the descendants.
  T get data {
    assert(_data != null, 'No Data<$T> found in context');
    return _data!;
  }

  @override
  Widget wrapWidget(Widget child) {
    return _InheritedData<T>._internal(
      key: key,
      data: _data,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(dataType != dynamic, 'Data must have a type');
    return _InheritedData<T>._internal(
      data: _data,
      child: child ?? const SizedBox(),
    );
  }

  /// Find and collect all the data of the given type from the context.
  ///
  /// * [T] The type of the data.
  /// * [context] The build context.
  static List<T> collect<T>(BuildContext context) {
    final List<T> data = [];
    context.visitAncestorElements((element) {
      if (element.widget is Data<T>) {
        var currentData = (element.widget as Data<T>)._data;
        if (currentData != null) {
          data.add(currentData);
        } else {
          return false;
        }
      }
      return true;
    });
    return data;
  }

  /// Visit all Data ancestors of the given type from the context.
  ///
  /// * [T] The type of the data.
  /// * [context] The build context.
  /// * [visitor] The visitor function that returns false to stop the visiting.
  static void visitAncestors<T>(
      BuildContext context, bool Function(T data) visitor) {
    context.visitAncestorElements((element) {
      if (element.widget is Data<T>) {
        var currentData = (element.widget as Data<T>)._data;
        if (currentData != null) {
          if (!visitor(currentData)) {
            return false;
          }
        } else {
          return false;
        }
      }
      return true;
    });
  }

  /// {@template Data.of}
  /// Find and listen to data changes of the data with the given type from the context.
  ///
  /// * [T] The type of the data.
  /// * [context] The build context.
  /// {@endtemplate}
  static T of<T>(BuildContext context) {
    final data = maybeOf<T>(context);
    assert(data != null, 'No Data<$T> found in context');
    return data!;
  }

  /// {@template Data.maybeFind}
  /// Optionally find the data of the given type from the context.
  ///
  /// * [T] The type of the data.
  /// * [context] The build context.
  /// {@endtemplate}
  static T? maybeFind<T>(BuildContext context) {
    assert(context.mounted, 'The context must be mounted');
    final widget = context.findAncestorWidgetOfExactType<Data<T>>();
    if (widget == null) {
      return null;
    }
    return widget.data;
  }

  /// {@template Data.maybeFindMessenger}
  /// Find the DataMessenger that holds all of the data with the given type from the context.
  ///
  /// * [T] The type of the data.
  /// * [context] The build context.
  /// {@endtemplate}
  static T? maybeFindMessenger<T>(BuildContext context) {
    assert(context.mounted, 'The context must be mounted');
    InheritedDataHolderWidget? holder =
        context.findAncestorWidgetOfExactType<InheritedDataHolder<T>>();
    holder ??= context.findAncestorWidgetOfExactType<InheritedRootDataHolder>();
    if (holder != null) {
      return holder.holder.findData(context, T);
    }
    return null;
  }

  /// {@template Data.findMessenger}
  /// Find the stored data somewhere in the ancestor DataMessenger descendants.
  /// Throws an assertion error if the data is not found.
  /// - [T] The type of the data.
  /// - [context] The build context.
  /// {@endtemplate}
  static T findMessenger<T>(BuildContext context) {
    final data = maybeFindMessenger<T>(context);
    assert(data != null, 'No Data<$T> found in context');
    return data!;
  }

  /// {@template Data.find}
  /// Find the data of the given type from the context. Does not listen
  /// to the data changes.
  ///
  /// * [T] The type of the data.
  /// * [context] The build context.
  /// {@endtemplate}
  static T find<T>(BuildContext context) {
    final data = maybeFind<T>(context);
    assert(data != null, 'No Data<$T> found in context');
    return data!;
  }

  /// {@template Data.maybeFindRoot}
  /// Optionally find the root data of the given type from the context.
  ///
  /// * [T] The type of the data.
  /// * [context] The build context.
  /// {@endtemplate}
  static T? maybeFindRoot<T>(BuildContext context) {
    assert(context.mounted, 'The context must be mounted');
    T? found;
    context.visitAncestorElements((element) {
      if (element.widget is Data<T>) {
        var data = (element.widget as Data<T>)._data;
        if (data != null) {
          found = data;
        }
      }
      return true;
    });
    return found;
  }

  /// {@template Data.findRoot}
  /// Find the root data of the given type from the context.
  /// Throws an assertion error if the data is not found.
  ///
  /// * [T] The type of the data.
  /// * [context] The build context.
  /// {@endtemplate}
  static T findRoot<T>(BuildContext context) {
    final data = maybeFindRoot<T>(context);
    assert(data != null, 'No Data<$T> found in context');
    return data!;
  }

  /// {@template Data.maybeOf}
  /// Optionally find and listen to data changes of the data with the given type from the context.
  ///
  /// * [T] The type of the data.
  /// * [context] The build context.
  /// {@endtemplate}
  static T? maybeOf<T>(BuildContext context) {
    assert(context.mounted, 'The context must be mounted');
    final widget =
        context.dependOnInheritedWidgetOfExactType<_InheritedData<T>>();
    if (widget == null) {
      return null;
    }
    return widget.data;
  }

  /// Capture all the data from another context and wrap the child that can
  /// receive the data.
  ///
  /// * [context] The context to capture the data.
  /// * [child] The child widget that can receive the data.
  static Widget captureAll(BuildContext context, Widget child,
      {BuildContext? to}) {
    return capture(from: context, to: to).wrap(child);
  }

  /// Capture all the data from another context.
  ///
  /// * [context] The context to capture the data.
  /// * [to] The context to stop capturing the data.
  static CapturedData capture(
      {required BuildContext from, required BuildContext? to}) {
    if (from == to) {
      return CapturedData._([]);
    }
    final data = <_InheritedData>[];
    final Set<Type> dataTypes = <Type>{};
    late bool debugDidFindAncestor;
    assert(() {
      debugDidFindAncestor = to == null;
      return true;
    }());

    from.visitAncestorElements(
      (ancestor) {
        if (ancestor == to) {
          assert(() {
            debugDidFindAncestor = true;
            return true;
          }());
          return false;
        }
        if (ancestor is InheritedElement && ancestor.widget is _InheritedData) {
          final _InheritedData dataWidget = ancestor.widget as _InheritedData;
          final Type dataType = dataWidget.dataType;
          if (!dataTypes.contains(dataType)) {
            dataTypes.add(dataType);
            data.add(dataWidget);
          }
        }
        return true;
      },
    );

    assert(debugDidFindAncestor,
        'The provided `to` context must be an ancestor of the `from` context.');

    return CapturedData._(data);
  }

  @override
  Type get dataType => T;
}

class _InheritedData<T> extends InheritedWidget {
  final T? data;

  Type get dataType => T;

  const _InheritedData._internal({
    super.key,
    required this.data,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant _InheritedData<T> oldWidget) {
    if (data is DistinctData && oldWidget.data is DistinctData) {
      return (data as DistinctData)
          .shouldNotify(oldWidget.data as DistinctData);
    }
    return oldWidget.data != data;
  }

  Widget? wrap(Widget child, BuildContext context) {
    _InheritedData<T>? ancestor =
        context.dependOnInheritedWidgetOfExactType<_InheritedData<T>>();
    // if it's the same type, we don't need to wrap it
    if (identical(this, ancestor)) {
      return null;
    }
    final data = this.data;
    if (data == null) {
      return Data<T>.boundary(child: child);
    }
    return Data<T>.inherit(
      data: data,
      child: child,
    );
  }
}

/// CapturedData holds all the data captured from another context.
class CapturedData {
  CapturedData._(this._data);

  final List<_InheritedData> _data;

  /// Wraps the child widget with the captured data.
  Widget wrap(Widget child) {
    return _CaptureAllData(data: _data, child: child);
  }
}

class _CaptureAllData extends StatelessWidget {
  const _CaptureAllData({
    required this.data,
    required this.child,
  });

  final List<_InheritedData> data;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget result = child;
    for (final data in data) {
      var wrap = data.wrap(result, context);
      if (wrap == null) {
        continue;
      }
      result = wrap;
    }
    return result;
  }
}

mixin MultiModelItem {
  Model<Object?> get normalized;
}

/// A mixin for all kinds of Model properties.
mixin ModelProperty<T> implements MultiModelItem {
  /// The data key of the model.
  Symbol get dataKey;

  /// The data value of the model.
  T get value;

  /// Sets the data value of the model.
  set value(T data);

  /// The model key of the model.
  ModelKey<T> get modelKey => ModelKey<T>(dataKey);

  /// The data type of the model.
  Type get dataType => T;

  /// The normalized model of the model.
  Model<T> get normalized;

  /// Whether the model is read-only.
  bool get isReadOnly;
}

/// A widget that provides the model to its descendants.
class Model<T> extends StatelessWidget with ModelProperty<T> {
  @override
  final Symbol dataKey;
  @override
  final T value;

  /// The child widget.
  final Widget? child;

  /// The callback when the data changes.
  final ValueChanged<T>? onChanged;

  /// Creates a Model for MultiModel.
  const Model(this.dataKey, this.value, {this.onChanged}) : child = null;

  /// Creates a single Model widget.
  const Model.inherit(this.dataKey, this.value,
      {super.key, this.onChanged, required this.child});

  @override
  set value(T data) {
    assert(onChanged != null, 'Model<$T>($dataKey) is read-only');
    onChanged?.call(data);
  }

  @override
  bool get isReadOnly => onChanged == null;

  /// {@template Model.maybeOf}
  /// Optionally find and listen to data changes of the data with the given type from the context.
  ///
  /// * [T] The type of the data.
  /// * [context] The build context.
  /// * [key] The data key.
  /// {@endtemplate}
  static T? maybeOf<T>(BuildContext context, Symbol key) {
    return MultiModel.maybeOf(context, key);
  }

  /// {@template Model.of}
  /// Find and listen to data changes of the data with the given type from the context.
  ///
  /// * [T] The type of the data.
  /// * [context] The build context.
  /// * [key] The data key.
  /// {@endtemplate}
  static T of<T>(BuildContext context, Symbol key) {
    return MultiModel.of(context, key);
  }

  /// {@template Model.maybeFind}
  /// Optionally find the data of the given type from the context.
  /// Returns null if the data is not found.
  ///
  /// * [T] The type of the data.
  /// * [context] The build context.
  /// * [key] The data key.
  /// {@endtemplate}
  static T? maybeFind<T>(BuildContext context, Symbol key) {
    return MultiModel.maybeFind(context, key);
  }

  /// {@template Model.find}
  /// Find the data of the given type from the context.
  /// Throws an assertion error if the data is not found.
  ///
  /// * [T] The type of the data.
  /// * [context] The build context.
  /// * [key] The data key.
  /// {@endtemplate}
  static T find<T>(BuildContext context, Symbol key) {
    return MultiModel.find(context, key);
  }

  /// {@template Model.change}
  /// Change the data of the model with the given key.
  /// Throws an assertion error if the model is read-only.
  ///
  /// * [T] The type of the data.
  /// * [context] The build context.
  /// * [key] The data key.
  /// * [data] The new data.
  /// {@endtemplate}
  static void change<T>(BuildContext context, Symbol key, T data) {
    MultiModel.change(context, key, data);
  }

  /// {@template Model.maybeFindProperty}
  /// Optionally find the property of the given type from the context.
  /// Returns null if the data is not found.
  ///
  /// * [T] The type of the data.
  /// * [context] The build context.
  /// * [key] The data key.
  /// {@endtemplate}
  static ModelProperty<T>? maybeFindProperty<T>(
      BuildContext context, Symbol key) {
    return MultiModel.maybeFindProperty(context, key);
  }

  /// {@template Model.findProperty}
  /// Find the property of the given type from the context.
  /// Throws an assertion error if the data is not found.
  ///
  /// * [T] The type of the data.
  /// * [context] The build context.
  /// * [key] The data key.
  /// {@endtemplate}
  static ModelProperty<T> findProperty<T>(BuildContext context, Symbol key) {
    return MultiModel.findProperty(context, key);
  }

  /// {@template Model.maybeChange}
  /// Optionally change the data of the model with the given key.
  /// Ignores if the model is read-only.
  ///
  /// * [T] The type of the data.
  /// * [context] The build context.
  /// * [key] The data key.
  /// * [data] The new data.
  /// {@endtemplate}
  static bool maybeChange<T>(BuildContext context, Symbol key, T data) {
    return MultiModel.maybeChange(context, key, data);
  }

  /// {@template Model.ofProperty}
  /// Find and listen to property changes of the data with the given type from the context.
  /// Throws an assertion error if the data is not found.
  ///
  /// * [T] The type of the data.
  /// * [context] The build context.
  /// * [key] The data key.
  /// {@endtemplate}
  static ModelProperty<T> ofProperty<T>(BuildContext context, Symbol key) {
    return MultiModel.ofProperty(context, key);
  }

  /// {@template Model.maybeOfProperty}
  /// Optionally find and listen to property changes of the data with the given type from the context.
  /// Returns null if the data is not found.
  ///
  /// * [T] The type of the data.
  /// * [context] The build context.
  /// * [key] The data key.
  /// {@endtemplate}
  static ModelProperty<T>? maybeOfProperty<T>(
      BuildContext context, Symbol key) {
    return MultiModel.maybeOfProperty(context, key);
  }

  @override
  Widget build(BuildContext context) {
    return MultiModel(
      data: [this],
      child: child ?? const SizedBox(),
    );
  }

  @override
  Model<T> get normalized => this;

  @override
  String toStringShort() {
    return 'Model<$T>($dataKey: $value)';
  }
}

/// A widget that stops the property of the given type from being passed to its descendants.
class ModelBoundary<T> extends StatelessWidget implements Model<T> {
  @override
  final Symbol dataKey;
  @override
  final Widget? child;

  /// Creates a ModelBoundary for MultiModel.
  const ModelBoundary(this.dataKey, {super.key, this.child});

  @override
  T get value {
    assert(false, 'No Model<$T>($dataKey) found in context');
    throw Exception('ModelBoundary<$T>($dataKey)');
  }

  @override
  Widget build(BuildContext context) {
    return Model<T>.inherit(dataKey, value, child: child!);
  }

  @override
  Type get dataType => T;

  @override
  bool get isReadOnly => true;

  @override
  ModelKey<T> get modelKey => ModelKey<T>(dataKey);

  @override
  Model<T> get normalized => this;

  @override
  final ValueChanged<T>? onChanged = null;

  @override
  set value(T data) {
    assert(false, 'No Model<$T>($dataKey) found in context');
  }
}

/// A widget that provides the model to its descendants and listens to the data changes.
/// The data is refreshed when the ValueNotifier changes.
class ModelNotifier<T> extends StatelessWidget
    with ModelProperty<T>
    implements Listenable {
  @override
  final Symbol dataKey;
  final ValueNotifier<T> notifier;
  final Widget? child;

  const ModelNotifier(this.dataKey, this.notifier) : child = null;

  const ModelNotifier.inherit(this.dataKey, this.notifier,
      {super.key, required this.child});

  @override
  T get value => notifier.value;

  @override
  set value(T data) {
    notifier.value = data;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, value, child) {
        return Model.inherit(dataKey, value, onChanged: (value) {
          notifier.value = value;
        }, child: child);
      },
      child: child,
    );
  }

  void _handleDataChanged(T data) {
    this.value = data;
  }

  @override
  Model<T> get normalized =>
      Model(dataKey, value, onChanged: _handleDataChanged);

  @override
  String toStringShort() {
    return 'ModelNotifier<$T>($dataKey: $notifier)';
  }

  @override
  bool get isReadOnly => false;

  @override
  void addListener(VoidCallback listener) {
    notifier.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    notifier.removeListener(listener);
  }
}

/// A widget that provides the model to its descendants and listens to the data changes.
/// The data is refreshed when the ValueListenable changes.
/// The model is read-only.
class ModelListenable<T> extends StatelessWidget
    with ModelProperty<T>
    implements Listenable {
  @override
  final Symbol dataKey;
  final ValueListenable<T> listenable;
  final Widget? child;

  /// Creates a ModelListenable for MultiModel.
  const ModelListenable(this.dataKey, this.listenable) : child = null;

  /// Creates a single ModelListenable widget.
  const ModelListenable.inherit(this.dataKey, this.listenable,
      {super.key, required this.child});

  @override
  T get value => listenable.value;

  @override
  set value(T data) {
    assert(false, 'ModelListenable<$T>($dataKey) is read-only');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: listenable,
      builder: (context, value, child) {
        return Model.inherit(dataKey, value, child: child);
      },
      child: child,
    );
  }

  @override
  Model<T> get normalized => Model(dataKey, value);

  @override
  String toStringShort() {
    return 'ModelListenable<$T>($dataKey: $listenable)';
  }

  @override
  bool get isReadOnly => true;

  @override
  void addListener(VoidCallback listener) {
    listenable.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    listenable.removeListener(listener);
  }
}

/// A ModelKey that holds the data key and provides
/// methods to find and change the data.
class ModelKey<T> {
  final Symbol key;

  const ModelKey(this.key);

  T? maybeOf(BuildContext context) {
    return MultiModel.maybeOf<T>(context, key);
  }

  T of(BuildContext context) {
    return MultiModel.of<T>(context, key);
  }

  T? maybeFind(BuildContext context) {
    return MultiModel.maybeFind<T>(context, key);
  }

  T find(BuildContext context) {
    return MultiModel.find<T>(context, key);
  }

  void maybeChange(BuildContext context, T data) {
    MultiModel.maybeChange(context, key, data);
  }

  void change(BuildContext context, T data) {
    MultiModel.change(context, key, data);
  }

  ModelProperty<T>? maybeFindProperty(BuildContext context) {
    return MultiModel.maybeFindProperty<T>(context, key);
  }

  ModelProperty<T> findProperty(BuildContext context) {
    return MultiModel.findProperty<T>(context, key);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModelKey && other.key == key && other.dataType == T;
  }

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'ModelKey<$T>($key)';

  /// The compile-time type of the data.
  Type get dataType => T;
}

/// A widget that provides multiple models to its descendants.
class MultiModel extends StatelessWidget {
  /// The list of models that will be provided to the descendants.
  final List<MultiModelItem> data;

  /// The child widget.
  final Widget child;

  /// Creates a MultiModel.
  const MultiModel({required this.data, required this.child});

  @override
  Widget build(BuildContext context) {
    Listenable mergedListenable = Listenable.merge(
      data.whereType<Listenable>(),
    );
    return ListenableBuilder(
      listenable: mergedListenable,
      builder: (context, child) {
        return _InheritedModel(
          data.map((e) => e.normalized).toList(),
          child: this.child,
        );
      },
    );
  }

  static T? maybeOf<T>(BuildContext context, Symbol key) {
    return maybeOfProperty<T>(context, key)?.value;
  }

  static T of<T>(BuildContext context, Symbol key) {
    return ofProperty<T>(context, key).value;
  }

  static T? maybeFind<T>(BuildContext context, Symbol key) {
    return maybeOfProperty<T>(context, key)?.value;
  }

  static T find<T>(BuildContext context, Symbol key) {
    return findProperty<T>(context, key).value;
  }

  static void change<T>(BuildContext context, Symbol key, T data) {
    final widget = context.findAncestorWidgetOfExactType<_InheritedModel>();
    assert(widget != null, 'No Model<$T>($key) found in context');
    for (final model in widget!.data) {
      if (model.dataKey == key) {
        model.value = data;
        return;
      }
    }
    assert(false, 'No Model<$T>($key) found in context');
  }

  static bool maybeChange<T>(BuildContext context, Symbol key, T data) {
    final widget = context.findAncestorWidgetOfExactType<_InheritedModel>();
    if (widget == null) {
      return false;
    }
    for (final model in widget.data) {
      if (model.dataKey == key) {
        model.value = data;
        return true;
      }
    }
    return false;
  }

  static ModelProperty<T>? maybeFindProperty<T>(
      BuildContext context, Symbol key) {
    final widget = context.findAncestorWidgetOfExactType<_InheritedModel>();
    if (widget == null) {
      return null;
    }
    for (final model in widget.data) {
      if (model.dataKey == key && model.dataType == T) {
        if (model is ModelBoundary<T>) {
          return null;
        }
        return model as ModelProperty<T>;
      }
    }
    return null;
  }

  static ModelProperty<T> findProperty<T>(BuildContext context, Symbol key) {
    final model = maybeFindProperty<T>(context, key);
    assert(model != null, 'No Model<$T>($key) found in context');
    return model!;
  }

  static ModelProperty<T>? maybeOfProperty<T>(
      BuildContext context, Symbol key) {
    var model = InheritedModel.inheritFrom<_InheritedModel>(context,
        aspect: ModelKey<T>(key));
    if (model == null) {
      return null;
    }
    for (final model in model.data) {
      if (model.dataKey == key && model.dataType == T) {
        if (model is ModelBoundary<T>) {
          return null;
        }
        return model as ModelProperty<T>;
      }
    }
    return null;
  }

  static ModelProperty<T> ofProperty<T>(BuildContext context, Symbol key) {
    final model = maybeOfProperty<T>(context, key);
    assert(model != null, 'No Model<$T>($key) found in context');
    return model!;
  }
}

class _InheritedModel extends InheritedModel<ModelKey> {
  final Iterable<Model> data;

  const _InheritedModel(this.data, {required super.child});

  @override
  bool updateShouldNotify(covariant _InheritedModel oldWidget) {
    for (final model in data) {
      bool found = false;
      for (final oldModel in oldWidget.data) {
        if (model.modelKey == oldModel.modelKey) {
          found = true;

          if (model.value != oldModel.value) {
            // the existing model has changed
            return true;
          }
        }
      }
      if (!found) {
        // a new model has been added
        return true;
      }
    }
    for (final oldModel in oldWidget.data) {
      bool found = false;
      for (final model in data) {
        if (model.modelKey == oldModel.modelKey) {
          found = true;
        }
      }
      if (!found) {
        // a model has been removed
        return true;
      }
    }
    return false;
  }

  @override
  bool isSupportedAspect(Object aspect) {
    if (aspect is ModelKey) {
      return data.any((model) =>
          model.dataKey == aspect.key && model.dataType == aspect.dataType);
    }
    return false;
  }

  @override
  bool updateShouldNotifyDependent(
      covariant _InheritedModel oldWidget, Set<ModelKey> dependencies) {
    for (final model in data) {
      bool found = false;
      for (final oldModel in oldWidget.data) {
        if (model.modelKey == oldModel.modelKey) {
          found = true;
          if (model.value != oldModel.value) {
            // the existing model has changed
            return dependencies.contains(model.modelKey);
          }
        }
      }
      if (!found) {
        // a new model has been added
        return dependencies.contains(model.modelKey);
      }
    }
    for (final oldModel in oldWidget.data) {
      bool found = false;
      for (final model in data) {
        if (model.modelKey == oldModel.modelKey) {
          found = true;
        }
      }
      if (!found) {
        // a model has been removed
        return dependencies.contains(oldModel.modelKey);
      }
    }
    return false;
  }
}

typedef ModelWidgetBuilder<T> = Widget Function(
    BuildContext context, ModelProperty<T> model, Widget? child);

class ModelBuilder<T> extends StatelessWidget {
  final Symbol dataKey;
  final ModelWidgetBuilder<T> builder;
  final Widget? child;

  const ModelBuilder(
    this.dataKey, {
    super.key,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final model = MultiModel.maybeOfProperty<T>(context, dataKey);
    assert(model != null, 'No Model<$T>($dataKey) found in context');
    return builder(context, model!, child);
  }
}

abstract class ChangeListener {
  void dispatch(Object? event);
}

class VoidChangeListener extends ChangeListener {
  final VoidCallback listener;

  VoidChangeListener(this.listener);

  @override
  void dispatch(Object? event) {
    listener();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VoidChangeListener && other.listener == listener;
  }

  @override
  int get hashCode => listener.hashCode;
}

mixin ChangesNotifierHelperMixin {
  int _count = 0;
  static final List<ChangeListener?> _emptyListeners =
      List<ChangeListener?>.filled(0, null);

  List<ChangeListener?> _listeners = _emptyListeners;
  int _notificationCallStackDepth = 0;
  int _reentrantlyRemovedListeners = 0;
  bool _debugDisposed = false;

  bool _creationDispatched = false;

  static bool debugAssertNotDisposed(ChangesNotifierHelperMixin notifier) {
    assert(() {
      if (notifier._debugDisposed) {
        throw FlutterError(
          'A ${notifier.runtimeType} was used after being disposed.\n'
          'Once you have called dispose() on a ${notifier.runtimeType}, it '
          'can no longer be used.',
        );
      }
      return true;
    }());
    return true;
  }

  @protected
  bool get hasListeners {
    return _count > 0;
  }

  @protected
  static void maybeDispatchObjectCreation(ChangesNotifierHelperMixin object) {
    // Tree shaker does not include this method and the class MemoryAllocations
    // if kFlutterMemoryAllocationsEnabled is false.
    if (kFlutterMemoryAllocationsEnabled && !object._creationDispatched) {
      FlutterMemoryAllocations.instance.dispatchObjectCreated(
        library: _kDataWidgetLibrary,
        className: '$ChangesNotifierHelperMixin',
        object: object,
      );
      object._creationDispatched = true;
    }
  }

  @protected
  void defaultAddListener(ChangeListener listener) {
    assert(debugAssertNotDisposed(this));

    if (kFlutterMemoryAllocationsEnabled) {
      maybeDispatchObjectCreation(this);
    }

    if (_count == _listeners.length) {
      if (_count == 0) {
        _listeners = List<ChangeListener?>.filled(1, listener);
      } else {
        final List<ChangeListener?> newListeners =
            List<ChangeListener?>.filled(_count * 2, null);
        for (int i = 0; i < _count; i++) {
          newListeners[i] = _listeners[i];
        }
        _listeners = newListeners;
      }
    }
    _listeners[_count++] = listener;
  }

  void _removeAt(int index) {
    // The list holding the listeners is not growable for performances reasons.
    // We still want to shrink this list if a lot of listeners have been added
    // and then removed outside a notifyListeners iteration.
    // We do this only when the real number of listeners is half the length
    // of our list.
    _count -= 1;
    if (_count * 2 <= _listeners.length) {
      final List<ChangeListener?> newListeners =
          List<ChangeListener?>.filled(_count, null);

      // Listeners before the index are at the same place.
      for (int i = 0; i < index; i++) {
        newListeners[i] = _listeners[i];
      }

      // Listeners after the index move towards the start of the list.
      for (int i = index; i < _count; i++) {
        newListeners[i] = _listeners[i + 1];
      }

      _listeners = newListeners;
    } else {
      // When there are more listeners than half the length of the list, we only
      // shift our listeners, so that we avoid to reallocate memory for the
      // whole list.
      for (int i = index; i < _count; i++) {
        _listeners[i] = _listeners[i + 1];
      }
      _listeners[_count] = null;
    }
  }

  @protected
  void defaultRemoveListener(ChangeListener listener) {
    // This method is allowed to be called on disposed instances for usability
    // reasons. Due to how our frame scheduling logic between render objects and
    // overlays, it is common that the owner of this instance would be disposed a
    // frame earlier than the listeners. Allowing calls to this method after it
    // is disposed makes it easier for listeners to properly clean up.
    for (int i = 0; i < _count; i++) {
      final ChangeListener? listenerAtIndex = _listeners[i];
      if (listenerAtIndex == listener) {
        if (_notificationCallStackDepth > 0) {
          // We don't resize the list during notifyListeners iterations
          // but we set to null, the listeners we want to remove. We will
          // effectively resize the list at the end of all notifyListeners
          // iterations.
          _listeners[i] = null;
          _reentrantlyRemovedListeners++;
        } else {
          // When we are outside the notifyListeners iterations we can
          // effectively shrink the list.
          _removeAt(i);
        }
        break;
      }
    }
  }

  @mustCallSuper
  void dispose() {
    assert(debugAssertNotDisposed(this));
    assert(
      _notificationCallStackDepth == 0,
      'The "dispose()" method on $this was called during the call to '
      '"notifyListeners()". This is likely to cause errors since it modifies '
      'the list of listeners while the list is being used.',
    );
    assert(() {
      _debugDisposed = true;
      return true;
    }());
    if (kFlutterMemoryAllocationsEnabled && _creationDispatched) {
      FlutterMemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }
    _listeners = _emptyListeners;
    _count = 0;
  }

  @protected
  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  void defaultNotifyListeners(Object? event) {
    assert(debugAssertNotDisposed(this));
    if (_count == 0) {
      return;
    }

    // To make sure that listeners removed during this iteration are not called,
    // we set them to null, but we don't shrink the list right away.
    // By doing this, we can continue to iterate on our list until it reaches
    // the last listener added before the call to this method.

    // To allow potential listeners to recursively call notifyListener, we track
    // the number of times this method is called in _notificationCallStackDepth.
    // Once every recursive iteration is finished (i.e. when _notificationCallStackDepth == 0),
    // we can safely shrink our list so that it will only contain not null
    // listeners.

    _notificationCallStackDepth++;

    final int end = _count;
    for (int i = 0; i < end; i++) {
      try {
        final ChangeListener? listener = _listeners[i];
        if (listener != null) {
          listener.dispatch(event);
        }
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: _kDataWidgetLibrary,
          context: ErrorDescription(
              'while dispatching notifications for $runtimeType'),
          informationCollector: () => <DiagnosticsNode>[
            DiagnosticsProperty<ChangesNotifierHelperMixin>(
              'The $runtimeType sending notification was',
              this,
              style: DiagnosticsTreeStyle.errorProperty,
            ),
          ],
        ));
      }
    }

    _notificationCallStackDepth--;

    if (_notificationCallStackDepth == 0 && _reentrantlyRemovedListeners > 0) {
      // We really remove the listeners when all notifications are done.
      final int newLength = _count - _reentrantlyRemovedListeners;
      if (newLength * 2 <= _listeners.length) {
        // As in _removeAt, we only shrink the list when the real number of
        // listeners is half the length of our list.
        final List<ChangeListener?> newListeners =
            List<ChangeListener?>.filled(newLength, null);

        int newIndex = 0;
        for (int i = 0; i < _count; i++) {
          final listener = _listeners[i];
          if (listener != null) {
            newListeners[newIndex++] = listener;
          }
        }

        _listeners = newListeners;
      } else {
        // Otherwise we put all the null references at the end.
        for (int i = 0; i < newLength; i += 1) {
          if (_listeners[i] == null) {
            // We swap this item with the next not null item.
            int swapIndex = i + 1;
            while (_listeners[swapIndex] == null) {
              swapIndex += 1;
            }
            _listeners[i] = _listeners[swapIndex];
            _listeners[swapIndex] = null;
          }
        }
      }

      _reentrantlyRemovedListeners = 0;
      _count = newLength;
    }
  }
}
