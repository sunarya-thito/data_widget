library;

import 'package:flutter/widgets.dart';

import 'data_widget.dart';

extension BuildContextExtension on BuildContext {
  T? maybeOf<T>() {
    return Data.maybeOf<T>(this);
  }

  T of<T>() {
    return Data.of<T>(this);
  }

  T? maybeFind<T>() {
    return Data.maybeFind<T>(this);
  }

  T find<T>() {
    return Data.find<T>(this);
  }

  ModelProperty<T> property<T>(Symbol key) {
    return Model.findProperty<T>(this, key);
  }

  ModelProperty<T>? maybeProperty<T>(Symbol key) {
    return Model.maybeFindProperty<T>(this, key);
  }

  T? maybeModel<T>(Symbol key) {
    return Model.maybeFind<T>(this, key);
  }

  T model<T>(Symbol key) {
    return Model.find<T>(this, key);
  }

  void changeModel<T>(Symbol key, T value) {
    Model.change<T>(this, key, value);
  }

  void maybeChangeModel<T>(Symbol key, T value) {
    Model.maybeChange<T>(this, key, value);
  }

  T findMessenger<T>() {
    return Data.findMessenger<T>(this);
  }

  T? maybeFindMessenger<T>() {
    return Data.maybeFindMessenger<T>(this);
  }

  T findRoot<T>() {
    return Data.findRoot<T>(this);
  }

  T? maybeFindRoot<T>() {
    return Data.maybeFindRoot<T>(this);
  }
}

class StateExtension {
  final State state;

  StateExtension(this.state);

  T? maybeOf<T>() {
    assert(state.mounted, 'State is not mounted');
    return Data.maybeOf<T>(state.context);
  }

  T of<T>() {
    assert(state.mounted, 'State is not mounted');
    return Data.of<T>(state.context);
  }

  T? maybeFind<T>() {
    assert(state.mounted, 'State is not mounted');
    return Data.maybeFind<T>(state.context);
  }

  T find<T>() {
    assert(state.mounted, 'State is not mounted');
    return Data.find<T>(state.context);
  }

  ModelProperty<T> property<T>(Symbol key) {
    assert(state.mounted, 'State is not mounted');
    return Model.findProperty<T>(state.context, key);
  }

  ModelProperty<T>? maybeProperty<T>(Symbol key) {
    assert(state.mounted, 'State is not mounted');
    return Model.maybeFindProperty<T>(state.context, key);
  }

  T? maybeModel<T>(Symbol key) {
    assert(state.mounted, 'State is not mounted');
    return Model.maybeFind<T>(state.context, key);
  }

  T model<T>(Symbol key) {
    assert(state.mounted, 'State is not mounted');
    return Model.find<T>(state.context, key);
  }

  void changeModel<T>(Symbol key, T value) {
    assert(state.mounted, 'State is not mounted');
    Model.change<T>(state.context, key, value);
  }

  void maybeChangeModel<T>(Symbol key, T value) {
    assert(state.mounted, 'State is not mounted');
    Model.maybeChange<T>(state.context, key, value);
  }

  T findMessenger<T>() {
    assert(state.mounted, 'State is not mounted');
    return Data.findMessenger<T>(state.context);
  }

  T? maybeFindMessenger<T>() {
    assert(state.mounted, 'State is not mounted');
    return Data.maybeFindMessenger<T>(state.context);
  }

  T findRoot<T>() {
    assert(state.mounted, 'State is not mounted');
    return Data.findRoot<T>(state.context);
  }

  T? maybeFindRoot<T>() {
    assert(state.mounted, 'State is not mounted');
    return Data.maybeFindRoot<T>(state.context);
  }
}
