import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voltpay/core/auth/hooks/auth_policy_client.dart';
import 'package:voltpay/core/auth/hooks/models.dart';
import 'package:voltpay/core/auth/provider/auth_policy_providers.dart';

Future<bool> preflightEmail(
  BuildContext context,
  WidgetRef ref,
  String email,
) async {
  final AuthPolicyClient client = ref.read(authPolicyClientProvider);

  final BeforeCreateResult res = await client.beforeCreate(
    email: email,
    providerId: ProviderId.emailLink,
  );

  return res.map(
    allow: (_) => true,
    deny: (dynamic d) {
      final String msg = d.errorMessage ?? 'Sign up not allowed.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return false;
    },
  );
}
