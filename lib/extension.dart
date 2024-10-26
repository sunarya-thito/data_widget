library;

import 'package:flutter/widgets.dart';

import 'data_widget.dart';

extension BuildContextExtension on BuildContext {
  /// {@macro Data.maybeOf}
  T? maybeOf<T>() {
    return Data.maybeOf<T>(this);
  }

  /// {@macro Data.of}
  T of<T>() {
    return Data.of<T>(this);
  }

  /// {@macro Data.maybeFind}
  T? maybeFind<T>() {
    return Data.maybeFind<T>(this);
  }

  /// {@macro Data.find}
  T find<T>() {
    return Data.find<T>(this);
  }

  /// {@macro Model.ofProperty}
  ModelProperty<T> property<T>(Symbol key) {
    return Model.ofProperty<T>(this, key);
  }

  /// {@macro Model.maybeOfProperty}
  ModelProperty<T>? maybeProperty<T>(Symbol key) {
    return Model.maybeOfProperty<T>(this, key);
  }

  /// {@macro Model.findProperty}
  ModelProperty<T> findProperty<T>(Symbol key) {
    return Model.findProperty<T>(this, key);
  }

  /// {@macro Model.maybeFindProperty}
  ModelProperty<T>? maybeFindProperty<T>(Symbol key) {
    return Model.maybeFindProperty<T>(this, key);
  }

  /// {@macro Model.maybeOf}
  T? maybeModel<T>(Symbol key) {
    return Model.maybeOf<T>(this, key);
  }

  /// {@macro Model.find}
  T model<T>(Symbol key) {
    return Model.of<T>(this, key);
  }

  /// {@macro Model.maybeFind}
  T? maybeFindModel<T>(Symbol key) {
    return Model.maybeOf<T>(this, key);
  }

  /// {@macro Model.find}
  T findModel<T>(Symbol key) {
    return Model.of<T>(this, key);
  }

  /// {@macro Model.change}
  void changeModel<T>(Symbol key, T value) {
    Model.change<T>(this, key, value);
  }

  /// {@macro Model.maybeChange}
  void maybeChangeModel<T>(Symbol key, T value) {
    Model.maybeChange<T>(this, key, value);
  }

  /// {@macro Data.findMessenger}
  T findMessenger<T>() {
    return Data.findMessenger<T>(this);
  }

  /// {@macro Data.maybeFindMessenger}
  T? maybeFindMessenger<T>() {
    return Data.maybeFindMessenger<T>(this);
  }

  /// {@macro Data.findRoot}
  T findRoot<T>() {
    return Data.findRoot<T>(this);
  }

  /// {@macro Data.maybeFindRoot}
  T? maybeFindRoot<T>() {
    return Data.maybeFindRoot<T>(this);
  }
}

class StateExtension {
  final State state;

  StateExtension(this.state);

  /// {@macro Data.maybeOf}
  T? maybeOf<T>() {
    assert(state.mounted, 'State is not mounted');
    return Data.maybeOf<T>(state.context);
  }

  /// {@macro Data.of}
  T of<T>() {
    assert(state.mounted, 'State is not mounted');
    return Data.of<T>(state.context);
  }

  /// {@macro Data.maybeFind}
  T? maybeFind<T>() {
    assert(state.mounted, 'State is not mounted');
    return Data.maybeFind<T>(state.context);
  }

  /// {@macro Data.find}
  T find<T>() {
    assert(state.mounted, 'State is not mounted');
    return Data.find<T>(state.context);
  }

  /// {@macro Model.ofProperty}
  ModelProperty<T> property<T>(Symbol key) {
    assert(state.mounted, 'State is not mounted');
    return Model.ofProperty<T>(state.context, key);
  }

  /// {@macro Model.maybeOfProperty}
  ModelProperty<T>? maybeProperty<T>(Symbol key) {
    assert(state.mounted, 'State is not mounted');
    return Model.maybeOfProperty<T>(state.context, key);
  }

  /// {@macro Model.findProperty}
  ModelProperty<T> findProperty<T>(Symbol key) {
    assert(state.mounted, 'State is not mounted');
    return Model.findProperty<T>(state.context, key);
  }

  /// {@macro Model.maybeFindProperty}
  ModelProperty<T>? maybeFindProperty<T>(Symbol key) {
    assert(state.mounted, 'State is not mounted');
    return Model.maybeFindProperty<T>(state.context, key);
  }

  /// {@macro Model.maybeFind}
  T? maybeModel<T>(Symbol key) {
    assert(state.mounted, 'State is not mounted');
    return Model.maybeOf<T>(state.context, key);
  }

  /// {@macro Model.find}
  T model<T>(Symbol key) {
    assert(state.mounted, 'State is not mounted');
    return Model.of<T>(state.context, key);
  }

  /// {@macro Model.maybeFind}
  T? maybeFindModel<T>(Symbol key) {
    assert(state.mounted, 'State is not mounted');
    return Model.maybeOf<T>(state.context, key);
  }

  /// {@macro Model.find}
  T findModel<T>(Symbol key) {
    assert(state.mounted, 'State is not mounted');
    return Model.of<T>(state.context, key);
  }

  /// {@macro Model.change}
  void changeModel<T>(Symbol key, T value) {
    assert(state.mounted, 'State is not mounted');
    Model.change<T>(state.context, key, value);
  }

  /// {@macro Model.maybeChange}
  void maybeChangeModel<T>(Symbol key, T value) {
    assert(state.mounted, 'State is not mounted');
    Model.maybeChange<T>(state.context, key, value);
  }

  /// {@macro Data.findMessenger}
  T findMessenger<T>() {
    assert(state.mounted, 'State is not mounted');
    return Data.findMessenger<T>(state.context);
  }

  /// {@macro Data.maybeFindMessenger}
  T? maybeFindMessenger<T>() {
    assert(state.mounted, 'State is not mounted');
    return Data.maybeFindMessenger<T>(state.context);
  }

  /// {@macro Data.findRoot}
  T findRoot<T>() {
    assert(state.mounted, 'State is not mounted');
    return Data.findRoot<T>(state.context);
  }

  /// {@macro Data.maybeFindRoot}
  T? maybeFindRoot<T>() {
    assert(state.mounted, 'State is not mounted');
    return Data.maybeFindRoot<T>(state.context);
  }
}
