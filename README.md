# 📚 BookShare - Plateforme de Partage de Livres

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green)](#licence)

BookShare est une application mobile collaborative permettant aux utilisateurs de partager, d'emprunter et d'échanger des livres au sein d'une communauté. L'application favorise la lecture et la durabilité en facilitant l'accès aux ressources littéraires.

## 🎯 Caractéristiques Principales

- **Catalogue de Livres** - Parcourez et gérez votre collection personnelle de livres
- **Système d'Emprunt** - Emprantez des livres à d'autres utilisateurs avec suivi automatique
- **Messagerie Directe** - Communiquez avec d'autres lecteurs pour négocier des échanges
- **Avis et Critiques** - Partagez vos avis sur les livres avec la communauté
- **Notifications en Temps Réel** - Recevez des alertes sur vos emprunts et messages
- **Événements Littéraires** - Découvrez et organisez des rencontres littéraires locales
- **Authentification Sécurisée** - Connexion via Firebase avec gestion des sessions

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir installé:

- **Flutter** (v3.0+) - [Installation](https://docs.flutter.dev/get-started/install)
- **Dart** (v2.18+) - Livré avec Flutter
- **Firebase CLI** - [Installation](https://firebase.google.com/docs/cli)
- **Git** - Pour le contrôle de version
- **Android Studio** ou **Xcode** - Selon les plateformes cibles

## 🚀 Installation

### 1. Cloner le dépôt

```bash
git clone https://github.com/votre-username/bookshare.git
cd bookshare
```

### 2. Installer les dépendances

```bash
flutter pub get
```

### 3. Configurer Firebase

1. Créez un projet Firebase sur [Firebase Console](https://console.firebase.google.com)
2. Téléchargez les fichiers de configuration:
   - `google-services.json` pour Android → `android/app/`
   - `GoogleService-Info.plist` pour iOS → `ios/Runner/`
3. Exécutez la configuration Firebase:

```bash
flutterfire configure
```

### 4. Exécuter l'application

```bash
# Sur Android/iOS
flutter run

# Sur Web
flutter run -d web

# Sur Windows
flutter run -d windows

# Sur macOS
flutter run -d macos

# Sur Linux
flutter run -d linux
```

## 🏗️ Architecture

L'application suit une architecture en couches inspirée de la Clean Architecture:

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── models/                   # Modèles de données
│   ├── book_model.dart
│   ├── user_model.dart
│   ├── loan_model.dart
│   └── ...
├── providers/                # Gestion d'état (StateNotifier/ChangeNotifier)
│   ├── auth_provider.dart
│   ├── catalogue_provider.dart
│   └── ...
├── services/                 # Logique métier et API
│   ├── firebase_options.dart
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── ...
├── views/                    # Écrans de l'application
└── widgets/                  # Composants réutilisables
```

### Pile Technologique

- **Framework**: Flutter + Dart
- **Base de Données**: Cloud Firestore
- **Authentification**: Firebase Authentication
- **Gestion d'État**: Provider Pattern
- **Platform**: Android, iOS, Web, Windows, Linux, macOS

## ⚙️ Configuration

### Variables d'Environnement

Créez un fichier `.env` à la racine du projet (si nécessaire):

```env
FIREBASE_API_KEY=votre_clé_api
FIREBASE_PROJECT_ID=votre_project_id
```

### Firestore Rules

Les règles de sécurité Firestore sont définies dans `firestore.rules`. Déployez-les via:

```bash
firebase deploy --only firestore:rules
```

## 📖 Utilisation

### Authentification

```dart
final authProvider = ref.read(authProvider);
await authProvider.login(email, password);
```

### Gestion du Catalogue

```dart
final catalogueProvider = ref.read(catalogueProvider);
final books = await catalogueProvider.fetchBooks();
```

### Emprunt de Livres

```dart
final loansProvider = ref.read(loansProvider);
await loansProvider.borrowBook(bookId, userId);
```

## 🔧 Commandes Utiles

```bash
# Formater le code
dart format .

# Analyser le code
dart analyze

# Exécuter les tests
flutter test

# Générer des fichiers de build
flutter pub run build_runner build

# Nettoyer la build
flutter clean
```

## 📱 Plateformes Supportées

- ✅ Android (v21+)
- ✅ iOS (v12+)
- ✅ Web (Chrome, Firefox, Safari)
- ✅ Windows (10+)
- ✅ macOS (10.14+)
- ✅ Linux (Ubuntu 18.04+)

## 🤝 Contribution

Les contributions sont bienvenues! Pour contribuer:

1. Fork le dépôt
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. Commitez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Poussez vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📝 Licences

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 📧 Contact & Support

- **Email**: support@bookshare.app
- **Issues**: [GitHub Issues](https://github.com/votre-username/bookshare/issues)
- **Documentation**: [Wiki](https://github.com/votre-username/bookshare/wiki)

---

**Fait avec ❤️ par la communauté BookShare**
