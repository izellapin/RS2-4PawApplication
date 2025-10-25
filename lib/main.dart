import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veterinarska_shared/veterinarska_shared.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kDebugMode) {
    print('🚀 Starting 4Paw mobile app...');
  }
  
  // Postavi HTTP overrides za HTTPS sertifikate (kao u Iron-Vault)
  HttpOverrides.global = MyHttpOverrides();
  
  if (kDebugMode) {
    print('🔧 Setting up service locator...');
  }
  
  await setupServiceLocator();
  
  if (kDebugMode) {
    print('✅ Service locator setup complete, starting app...');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => serviceLocator.authService),
      ],
      child: MaterialApp(
        title: '4Paw Veterinarska Stanica',
        theme: ThemeData(
          primarySwatch: Colors.green,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // Proveri da li je korisnik ulogovan
        if (authService.isAuthenticated) {
          return const MobileHomeScreen();
        } else {
          return const MobileLoginScreen();
        }
      },
    );
  }
}

/// HTTP overrides klasa za HTTPS sertifikate (kao u Iron-Vault projektu)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}