import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'views/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 🔍 DEBUG: Vérifier l'utilisateur aziz@gmail.com
  await _checkAzizAdmin();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
      ],
      child: const BookShareApp(),
    ),
  );
}

/// Vérifier et corriger isAdmin pour aziz@gmail.com
Future<void> _checkAzizAdmin() async {
  try {
    final userId = 'fZ9Ki84VPMfIr8qahsSmbnmabEw1';
    final db = FirebaseFirestore.instance;
    
    print('🔍 Vérification utilisateur ID: $userId');
    
    final doc = await db.collection('users').doc(userId).get();
    
    if (!doc.exists) {
      print('❌ Document non trouvé!');
      return;
    }
    
    final data = doc.data()!;
    print('✅ Document trouvé:');
    print('   Email: ${data['email']}');
    print('   Name: ${data['name']}');
    print('   isAdmin: ${data['isAdmin']}');
    
    // Si isAdmin n'est pas true, le corriger
    if (data['isAdmin'] != true) {
      print('⚠️ isAdmin est ${data['isAdmin']}, correction en cours...');
      await db.collection('users').doc(userId).update({
        'isAdmin': true,
      });
      print('✅ isAdmin mis à jour à true!');
    } else {
      print('✅ isAdmin est déjà true');
    }
    
  } catch (e) {
    print('❌ Erreur: $e');
  }
}

class BookShareApp extends StatelessWidget {
  const BookShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookShare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2C3E50),
        scaffoldBackgroundColor: const Color(0xFFF5F5F0),
      ),
      home: const LoginScreen(),
    );
  }
}