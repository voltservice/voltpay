// lib/core/providers/observers.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

base class AppProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    // You can inspect:
    // context.provider        -> the provider that changed
    // context.container       -> the ProviderContainer
    // context.container.hash  -> container identity
    // context.name / runtimeType etc.

    // Example: simple debug log
    debugPrint(
      '[Provider Updated] ${context.provider.name ?? context.provider.runtimeType} '
      'from $previousValue to $newValue',
    );
  }
}
