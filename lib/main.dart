import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voltpay/core/providers/observers.dart';
import 'package:voltpay/core/router/app_router.dart';
import 'package:voltpay/core/theme/theme_controller.dart';
import 'package:voltpay/core/theme/theme_provider.dart';
import 'package:voltpay/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // debugPrint('API_BASE = ${Env.apiBase}');
  // final ApiConfig cfg = ApiConfig(Env.apiBase);
  // debugPrint('ApiConfig.baseUrl = ${cfg.baseUrl}');
  // debugPrint('ApiConfig.health = ${cfg.healthUri()}');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Robust check for development mode
  if (kDebugMode) {
    final String emuHost = defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2' // Android emulator -> host machine
        : 'localhost';
    if (defaultTargetPlatform == TargetPlatform.android) {
      await FirebaseAuth.instance.useAuthEmulator(emuHost, 9099);
      FirebaseFirestore.instance.useFirestoreEmulator(emuHost, 8082);
      FirebaseStorage.instance.useStorageEmulator(emuHost, 9199);
      FirebaseFunctions.instanceFor(
        region: 'europe-west2',
      ).useFunctionsEmulator(emuHost, 5001);
    }
    const bool isTestEnv = bool.fromEnvironment('FLUTTER_TEST');
    if (isTestEnv) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    await FirebaseAppCheck.instance.activate(
      providerAndroid: const AndroidPlayIntegrityProvider(),
      providerApple: const AppleAppAttestProvider(),
    );
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
    );
  } else {
    // ✅ Use PRODUCTION provider on real device
    await FirebaseAppCheck.instance.activate(
      providerAndroid: const AndroidPlayIntegrityProvider(),
    );
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: false,
    );
  }

  // await FirebaseAppCheck.instance.activate(
  //   providerAndroid: const AndroidPlayIntegrityProvider(),
  // );
  //
  // await FirebaseAuth.instance.setSettings(
  //   appVerificationDisabledForTesting: false,
  // );

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
    final AppThemeMode appMode = ref.watch(
      themeControllerProvider,
    ); // AppThemeMode
    final ThemeData light = ref.watch(lightThemeProvider);
    final ThemeData dark = ref.watch(darkThemeProvider);

    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: light,
      darkTheme: dark,
      themeMode: appMode.material,
    );
  }
}
