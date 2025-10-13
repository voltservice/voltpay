import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:voltpay/features/rates/domain/pay_method_type.dart';
import 'package:voltpay/features/rates/domain/quote.dart';
import 'package:voltpay/features/rates/infrastructure/quote_repository.dart';
import 'package:voltpay/features/rates/providers/api_config_provider.dart';

part 'quote_provider.g.dart';

/// Immutable input model for quotes.
class QuoteParams {
  const QuoteParams({
    required this.source,
    required this.target,
    required this.amount,
    required this.method,
  });

  final String source;
  final String target;
  final double amount;
  final PaymentMethodType method;

  QuoteParams copyWith({
    String? source,
    String? target,
    double? amount,
    PaymentMethodType? method,
  }) {
    return QuoteParams(
      source: source ?? this.source,
      target: target ?? this.target,
      amount: amount ?? this.amount,
      method: method ?? this.method,
    );
  }
}

/// Keeps the latest user-entered quote parameters.
/// Use ref.watch(quoteParamsProvider) to get current values.
@riverpod
class QuoteParamsNotifier extends _$QuoteParamsNotifier {
  @override
  QuoteParams build() => const QuoteParams(
    source: 'USD',
    target: 'NGN',
    amount: 100,
    method: PaymentMethodType.wire,
  );

  void update(QuoteParams newParams) => state = newParams;

  void patch({
    String? source,
    String? target,
    double? amount,
    PaymentMethodType? method,
  }) {
    state = state.copyWith(
      source: source,
      target: target,
      amount: amount,
      method: method,
    );
  }
}

/// Fetches a fresh quote when parameters change.
/// Exposes AsyncValue<Quote).
@riverpod
class QuoteNotifier extends _$QuoteNotifier {
  @override
  FutureOr<Quote> build() async {
    // Watch params reactively
    final QuoteParams params = ref.watch(quoteParamsProvider);
    // final VoltApiClient api = ref.read(voltApiClientProvider);
    final QuoteRepository api = ref.read(quoteRepoProvider);

    // debounce rapid edits
    await Future<void>.delayed(const Duration(milliseconds: 200));

    return api.getQuote(
      source: params.source,
      target: params.target,
      amount: params.amount,
      method: params.method,
    );
  }

  /// Manual refresh if needed
  Future<void> refresh() async {
    state = const AsyncLoading<Quote>();
    try {
      final QuoteParams params = ref.read(quoteParamsProvider);
      // final VoltApiClient api = ref.read(voltApiClientProvider);
      final QuoteRepository api = ref.read(quoteRepoProvider);
      final Quote quote = await api.getQuote(
        source: params.source,
        target: params.target,
        amount: params.amount,
        method: params.method,
      );
      state = AsyncData<Quote>(quote);
    } catch (e, st) {
      state = AsyncError<Quote>(e, st);
    }
  }
}

// String _methodToString(PaymentMethodType t) => switch (t) {
//       PaymentMethodType.wire => 'wire',
//       PaymentMethodType.debitCard => 'debitCard',
//       PaymentMethodType.creditCard => 'creditCard',
//       PaymentMethodType.accountTransfer => 'accountTransfer',
//     };
