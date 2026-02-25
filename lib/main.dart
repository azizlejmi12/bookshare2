import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart' as auth;
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔥 Initialise différemment selon la plateforme
  try {
    if (kIsWeb) {
      // WEB : utilise les options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      // ANDROID : utilise google-services.json automatiquement
      await Firebase.initializeApp();
    }
    debugPrint('✅ Firebase initialisé avec succès');
  } catch (e) {
    debugPrint('❌ Erreur d\'initialisation Firebase: $e');
  }
  
  runApp(const BookShareApp());
}

class BookShareApp extends StatelessWidget {
  const BookShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 🔥 Provider pour l'authentification
        ChangeNotifierProvider(create: (_) => auth.AuthProvider()),
      ],
      child: MaterialApp(
        title: 'BookShare',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF2C3E50),
          scaffoldBackgroundColor: const Color(0xFFF5F5F0),
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            debugPrint('🔄 État d\'authentification: ${snapshot.data?.email ?? "Non connecté"}');
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            // Si l'utilisateur est connecté, affiche HomeScreen
            if (snapshot.hasData && snapshot.data != null) {
              debugPrint('✅ Utilisateur connecté: ${snapshot.data!.email}');
              return const HomeScreen();
            }
            
            // Sinon, affiche l'écran de connexion
            debugPrint('❌ Utilisateur non connecté');
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}