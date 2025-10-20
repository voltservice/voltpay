import 'package:flutter/material.dart';

enum PayMethodType { bankTransfer, debitCard, creditCard, swiftTransfer }

extension PayMethodTypeX on PayMethodType {
  String get label => switch (this) {
    PayMethodType.bankTransfer => 'Bank transfer',
    PayMethodType.debitCard => 'Debit card',
    PayMethodType.creditCard => 'Credit card',
    PayMethodType.swiftTransfer => 'Swift transfer',
  };

  IconData get icon => switch (this) {
    PayMethodType.bankTransfer => Icons.account_balance_rounded,
    PayMethodType.debitCard => Icons.credit_card_rounded,
    PayMethodType.creditCard => Icons.credit_card_rounded,
    PayMethodType.swiftTransfer => Icons.public_rounded,
  };
}
