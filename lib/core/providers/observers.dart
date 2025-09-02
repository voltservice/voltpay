// lib/core/providers/observers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<dynamic> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // Add structured logging if you want
    // debugPrint('[PROVIDER] ${provider.name ?? provider.runtimeType} -> $next');
  }
}
