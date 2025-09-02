import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voltpay/core/providers/observers.dart';
import 'package:voltpay/core/router/app_router.dart';
import 'package:voltpay/core/theme/themes/theme_provider.dart';
import 'package:voltpay/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Robust check for development mode
  if (kDebugMode) {
    const String host = 'localhost';
    if (defaultTargetPlatform == TargetPlatform.android) {
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8082);
      FirebaseStorage.instance.useStorageEmulator(host, 9199);
    }
    const bool isTestEnv = bool.fromEnvironment('FLUTTER_TEST');
    if (isTestEnv) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // // ✅ Use DEBUG provider on emulator/dev
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
    //
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
    );
  } else {
    // ✅ Real attestation for production
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest, // or deviceCheck
    );
  }

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest, // or deviceCheck
  );

  await FirebaseAuth.instance.setSettings(
    appVerificationDisabledForTesting: true,
  );

  runApp(
    ProviderScope(
      observers: <ProviderObserver>[AppProviderObserver()],
      child: const VoltPayApp(),
    ),
  );
}

class VoltPayApp extends ConsumerWidget {
  const VoltPayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final ThemeData lightTheme = ref.watch(lightThemeProvider);
    final ThemeData darkTheme = ref.watch(darkThemeProvider);

    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
    );
  }
}
