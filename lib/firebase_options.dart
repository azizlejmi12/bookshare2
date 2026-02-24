import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyCMLs5JMc4sxIANzV61XH2AUDt3Wlo5DLw',
      authDomain: 'bookshare-aziz.firebaseapp.com',
      projectId: 'bookshare-aziz',
      storageBucket: 'bookshare-aziz.firebasestorage.app',
      messagingSenderId: '422623714876',
      appId: '1:422623714876:web:2b36319dcc89912d01ad39',
      measurementId: 'G-S3PH8KY9J5',
    );
  }
}