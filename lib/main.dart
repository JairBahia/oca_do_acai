import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'app_theme.dart';
import 'screens/login_screen.dart';
import 'services/cart_service.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerLazySingleton<CartService>(() => CartService());
}

void main() {
  setup();
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const OcaDoAcaiApp(),
    ),
  );
}

class OcaDoAcaiApp extends StatelessWidget {
  const OcaDoAcaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oca do Açaí',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      home: const LoginScreen(),
    );
  }
}