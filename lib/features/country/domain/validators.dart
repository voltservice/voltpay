// lib/features/country/domain/validators.dart
import 'package:voltpay/features/country/domain/country.dart';
import 'package:voltpay/features/country/domain/iban_spec.dart';
import 'package:voltpay/features/country/domain/length_rule.dart';

bool validateLocalAccount(Country c, String accountNumber) {
  final LengthRule? rule = c.payoutRules.bankTransfer?.local?.accountNumber;
  if (rule == null) {
    return true; // no constraints
  }
  if (rule.lengths != null && rule.lengths!.isNotEmpty) {
    return rule.lengths!.contains(accountNumber.length);
  }
  if (rule.minLen != null && accountNumber.length < rule.minLen!) {
    return false;
  }
  if (rule.maxLen != null && accountNumber.length > rule.maxLen!) {
    return false;
  }
  return true;
}

bool validateRouting(Country c, String routing) {
  final LengthRule? rule = c.payoutRules.bankTransfer?.local?.routing;
  if (rule == null) {
    return true;
  }
  if (rule.lengths != null && rule.lengths!.isNotEmpty) {
    return rule.lengths!.contains(routing.length);
  }
  if (rule.minLen != null && routing.length < rule.minLen!) {
    return false;
  }
  if (rule.maxLen != null && routing.length > rule.maxLen!) {
    return false;
  }
  return true;
}

// For IBAN, consider a library, or basic length/country code check:
bool validateIbanBasic(Country c, String iban) {
  final IbanSpec? spec = c.payoutRules.bankTransfer?.iban;
  if (spec == null) {
    return false;
  }
  final String normalized = iban.replaceAll(' ', '').toUpperCase();
  return normalized.length == spec.length &&
      normalized.startsWith(spec.countryCode);
}
