// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey.
//
// Dependency-free state propagation: an InheritedNotifier exposes [AppState] to
// the whole tree and rebuilds dependents when it notifies. Read it with
// `AppScope.of(context)`.

import 'package:flutter/material.dart';

import 'app_state.dart';

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope?.notifier != null, 'No AppScope found in context');
    return scope!.notifier!;
  }

  /// Read [AppState] without subscribing to rebuilds (for one-off actions).
  static AppState read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope?.notifier != null, 'No AppScope found in context');
    return scope!.notifier!;
  }
}
