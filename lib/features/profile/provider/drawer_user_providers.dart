import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:voltpay/core/auth/provider/auth_provider.dart';

part 'drawer_user_providers.freezed.dart';

@freezed
abstract class DrawerUserUi with _$DrawerUserUi {
  const factory DrawerUserUi({
    required String uid,
    required String displayName,
    required String email,
    required String initials,
    required List<String> providerIds,
    String? photoUrl,
  }) = _DrawerUserUi;
}

/// Maps Firebase user → DrawerUserUi
final Provider<AsyncValue<DrawerUserUi>> drawerUserProvider =
    Provider<AsyncValue<DrawerUserUi>>((Ref ref) {
  final AsyncValue<User?> userAsync = ref.watch(
    firebaseUserChangesProvider,
  );

  return userAsync.whenData((User? u) {
    final String name = (u?.displayName?.trim().isNotEmpty ?? false)
        ? u!.displayName!.trim()
        : (u?.email?.split('@').first ?? 'VoltPay User');

    final String initials = () {
      final String src = name.trim();
      if (src.isEmpty) {
        return 'V';
      }
      final List<String> parts =
          src.split(RegExp(r'\s+')).where((String p) => p.isNotEmpty).toList();
      if (parts.length == 1) {
        return parts.first.characters.take(1).toString().toUpperCase();
      }
      return (parts.first.characters.take(1).toString() +
              parts.last.characters.take(1).toString())
          .toUpperCase();
    }();

    final List<String> providerIds = (u?.providerData ?? const <UserInfo>[])
        .map((UserInfo p) => p.providerId)
        .toList(growable: false);

    return DrawerUserUi(
      uid: u?.uid ?? 'anonymous',
      displayName: name,
      email: u?.email ?? '',
      photoUrl: u?.photoURL,
      initials: initials,
      providerIds: providerIds,
    );
  });
});

/// Compact chip model for linked providers.
@freezed
abstract class LinkedProviderChip with _$LinkedProviderChip {
  const factory LinkedProviderChip({
    required String id,
    required String label,
    required IconData icon,
  }) = _LinkedProviderChip;
}

final Provider<List<LinkedProviderChip>> linkedProviderChipsProvider =
    Provider<List<LinkedProviderChip>>((Ref ref) {
  final DrawerUserUi? ui = ref.watch(drawerUserProvider).value;
  if (ui == null) {
    return const <LinkedProviderChip>[];
  }

  return ui.providerIds.map((dynamic id) {
    switch (id) {
      case 'google.com':
        return const LinkedProviderChip(
          id: 'google.com',
          label: 'Google',
          icon: Icons.g_mobiledata,
        );
      case 'facebook.com':
        return const LinkedProviderChip(
          id: 'facebook.com',
          label: 'Facebook',
          icon: Icons.facebook,
        );
      case 'password':
        return const LinkedProviderChip(
          id: 'password',
          label: 'Email',
          icon: Icons.alternate_email,
        );
      case 'apple.com':
        return const LinkedProviderChip(
          id: 'apple.com',
          label: 'Apple',
          icon: Icons.apple,
        );
      default:
        return LinkedProviderChip(
          id: id,
          label: id,
          icon: Icons.person_outline,
        );
    }
  }).toList(growable: false);
});
