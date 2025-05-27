import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shake_flutter/shake_flutter.dart';
import 'providers/auth_provider.dart';
import 'providers/recipe_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  String apiKey = Platform.isIOS ? 'E4fLCW9lx5LkjfqSxHvXBlewDzPC8iAvkuYIljB4KppfXPhU5TfxEfI' : 'YZNCpI1ubcZkfAn8HgNcGtLOAkJBuiaT8JNJAvRVdkZjIoRmbdGi9Rt';
  Shake.start(apiKey);
  Shake.setInvokeShakeOnShakeDeviceEvent(true);
  Shake.setInvokeShakeOnScreenshot(true);
  Shake.setShowFloatingReportButton(true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()..loadRecipes()),
      ],
      child: MaterialApp(
        title: 'Bereket',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE65100), // Deep Orange
            primary: const Color(0xFFE65100),
            secondary: const Color(0xFF4CAF50), // Green
            tertiary: const Color(0xFFFFA000), // Amber
            background: const Color(0xFFFFF3E0), // Orange 50
            surface: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onTertiary: Colors.white,
            onBackground: const Color(0xFF3E2723), // Brown 900
            onSurface: const Color(0xFF3E2723),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFE65100),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIconColor: const Color(0xFFE65100),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE65100), width: 2),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: const Color(0xFFFFF3E0),
            selectedColor: const Color(0xFFE65100),
            labelStyle: const TextStyle(
              color: Color(0xFF3E2723),
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
        ],
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.user == null) {
          return const LoginScreen();
        }
        return const SplashScreen();
      },
    );
  }
}
