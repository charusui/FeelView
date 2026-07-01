import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'firebase_options.dart';
import 'providers/app_providers.dart';

/// Set to false before shipping to production.
const bool useEmulator = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (useEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
    await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
    await FirebaseStorage.instance.useStorageEmulator('127.0.0.1', 9199);
  }

  runApp(const ProviderScope(child: FeelViewApp()));
}

class FeelViewApp extends ConsumerWidget {
  const FeelViewApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseScale = ref.watch(textScaleProvider);
    final isSimplified = ref.watch(simplifyFurtherProvider);
    final effectiveScale = isSimplified ? (baseScale * 1.25).clamp(0.8, 2.5) : baseScale;

    return MaterialApp(
      title: 'FeelView',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRouter.devRoot,
      onGenerateRoute: AppRouter.generateRoute,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(effectiveScale),
          ),
          child: child!,
        );
      },
    );
  }
}
