import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // 🔥 Configuration WEB
      return const FirebaseOptions(
        apiKey: 'AIzaSyCMLs5JMc4sx1ANzV61XH2AUDt3Wlo5DLw',
        authDomain: 'bookshare-aziz.firebaseapp.com',
        projectId: 'bookshare-aziz',
        storageBucket: 'bookshare-aziz.firebasestorage.app',
        messagingSenderId: '422623714876',
        appId: '1:422623714876:web:2b36319dcc89912d01ad39',
        measurementId: 'G-S3PH8KY9J5',
      );
    }
    // 🔥 Configuration ANDROID/IOS (utilise google-services.json/GoogleService-Info.plist)
    // Ces plateformes ne nécessitent pas FirebaseOptions explicites
    throw UnsupportedError('Cette plateforme n\'est pas supportée');
  }
}