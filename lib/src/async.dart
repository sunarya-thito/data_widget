import 'dart:async';

import 'package:flutter/widgets.dart';

/// A callback to be debounced or throttled.
typedef DebounceCallback<T> = FutureOr<T> Function();

/// A callback to be called when the debounced or throttled callback is called.
typedef DebounceResultConsumer<T> = void Function(T value);

/// A callback to be called when the debounced or throttled callback throws an error.
typedef DebounceErrorConsumer = void Function(
    Object error, StackTrace stackTrace);

abstract class _DebounceSession {
  void cancel();
}

class _DebounceTimerSession extends _DebounceSession {
  final Timer timer;

  _DebounceTimerSession(this.timer);

  @override
  void cancel() {
    timer.cancel();
  }
}

class _DebounceFutureSession extends _DebounceSession {
  _DebounceFutureSession();

  @override
  void cancel() {}
}

/// A controller to debounce or throttle a callback.
class DebounceController extends ChangeNotifier {
  bool _debugDisposed = false;
  _DebounceSession? _session;

  /// Whether the controller is active.
  bool get isActive => _session != null;

  /// Debounce a callback.
  /// - [callback]: The callback to be debounced.
  /// - [duration]: The duration to wait before calling the callback.
  /// - [consumer]: The consumer to be called when the callback is called.
  /// - [errorConsumer]: The consumer to be called when the callback throws an error.
  void debounce<T>(
    DebounceCallback<T> callback, {
    Duration duration = const Duration(milliseconds: 300),
    DebounceResultConsumer<T>? consumer,
    DebounceErrorConsumer? errorConsumer,
  }) {
    assert(!_debugDisposed, 'DebounceController is disposed');
    _session?.cancel();
    _session = _DebounceTimerSession(Timer(
      duration,
      () {
        try {
          var result = callback();
          if (result is Future<T>) {
            result.then((value) {
              consumer?.call(value);
            }).catchError((error, stackTrace) {
              errorConsumer?.call(error, stackTrace);
            }).whenComplete(() {
              _session = null;
              notifyListeners();
            });
            return;
          } else {
            consumer?.call(result);
          }
        } catch (error, stackTrace) {
          errorConsumer?.call(error, stackTrace);
        }
        _session = null;
        notifyListeners();
      },
    ));
    notifyListeners();
  }

  /// Throttle a callback.
  /// - [callback]: The callback to be throttled.
  /// - [duration]: The duration to wait before calling the callback.
  /// - [consumer]: The consumer to be called when the callback is called.
  /// - [errorConsumer]: The consumer to be called when the callback throws an error.
  void throttle<T>(
    DebounceCallback<T> callback, {
    Duration duration = const Duration(milliseconds: 300),
    DebounceResultConsumer<T>? consumer,
    DebounceErrorConsumer? errorConsumer,
  }) {
    assert(!_debugDisposed, 'DebounceController is disposed');
    if (_session == null) {
      _session = _DebounceTimerSession(Timer(
        duration,
        () {
          _session = null;
          notifyListeners();
        },
      ));
      notifyListeners();
      try {
        var result = callback();
        if (result is Future<T>) {
          result.then((value) {
            consumer?.call(value);
          }).catchError((error, stackTrace) {
            errorConsumer?.call(error, stackTrace);
          });
          return;
        } else {
          consumer?.call(result);
        }
      } catch (error, stackTrace) {
        errorConsumer?.call(error, stackTrace);
      }
    }
  }

  /// Throttle a callback. Instead of waiting for the duration to call the callback,
  /// it will wait if the previous callback is still running.
  void throttleFuture<T>(
    DebounceCallback<T> callback, {
    DebounceResultConsumer<T>? consumer,
    DebounceErrorConsumer? errorConsumer,
  }) {
    assert(!_debugDisposed, 'DebounceController is disposed');
    if (_session == null) {
      _session = _DebounceFutureSession();
      notifyListeners();
      var result = callback();
      if (result is Future<T>) {
        result.then((value) {
          consumer?.call(value);
        }).catchError((error, stackTrace) {
          errorConsumer?.call(error, stackTrace);
        }).whenComplete(() {
          _session = null;
          notifyListeners();
        });
        return;
      } else {
        consumer?.call(result);
        _session = null;
        notifyListeners();
      }
    }
  }

  /// Cancel the debounce or throttle.
  /// The callback will not be called.
  void cancel() {
    assert(!_debugDisposed, 'DebounceController is disposed');
    _session?.cancel();
    _session = null;
    notifyListeners();
  }

  @override
  void dispose() {
    assert(() {
      if (_debugDisposed) {
        return false;
      }
      _debugDisposed = true;
      return true;
    }(), 'DebounceController is already disposed');
    super.dispose();
    _session?.cancel();
    _session = null;
  }
}

/// A callback to be called when the future is completed with a value.
typedef FutureWidgetBuilderCallback<T> = Widget Function(
    BuildContext context, T value);

/// A callback to be called when the future is completed with an error.
typedef FutureWidgetBuilderErrorCallback = Widget Function(
    BuildContext context, Object error, StackTrace stackTrace);

/// A callback to be called when the future is still loading.
typedef FutureWidgetBuilderLoadingCallback = Widget Function(
    BuildContext context);

/// A callback to be called when the future is completed with no data.
typedef FutureWidgetBuilderEmptyCallback = Widget Function(
    BuildContext context);

/// A widget that builds itself based on the latest snapshot of interaction with
class FutureWidgetBuilder<T> extends StatelessWidget {
  /// The future to which this builder is currently connected.
  final Future<T>? future;

  /// The builder that will be called when the future is completed with a value.
  final FutureWidgetBuilderCallback<T> builder;

  /// The builder that will be called when the future is completed with an error.
  final FutureWidgetBuilderErrorCallback? errorBuilder;

  /// The builder that will be called when the future is still loading.
  final FutureWidgetBuilderLoadingCallback? loadingBuilder;

  /// The builder that will be called when the future is completed with no data.
  final FutureWidgetBuilderEmptyCallback? emptyBuilder;

  /// The initial data to be used when the future is not completed.
  final T? initialData;

  /// Create a FutureWidgetBuilder.
  const FutureWidgetBuilder({
    super.key,
    this.initialData,
    required this.future,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      initialData: initialData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder?.call(context) ?? const SizedBox();
        }
        if (snapshot.hasError) {
          return errorBuilder?.call(
                  context, snapshot.error!, snapshot.stackTrace!) ??
              const SizedBox();
        }
        if (!snapshot.hasData) {
          return emptyBuilder?.call(context) ?? const SizedBox();
        }
        return builder(context, snapshot.requireData);
      },
    );
  }
}
