# BookShare - Dossier de Soutenance Technique

## 1. Resume du projet
BookShare est une application Flutter de partage de livres avec Firebase.
Objectif: permettre a des utilisateurs de consulter un catalogue, emprunter des livres, discuter, laisser des avis, recevoir des notifications et participer a des evenements.

## 2. Architecture du code
Le projet suit une architecture en couches, simple et lisible:

- UI: ecrans et widgets dans `lib/views` et `lib/widgets`
- Etat applicatif: providers (ChangeNotifier) dans `lib/providers`
- Logique metier + acces donnees: services dans `lib/services`
- Contrats de donnees: modeles dans `lib/models`
- Initialisation app: `lib/main.dart`

### 2.1 Flux de donnees (pattern)
1. L'utilisateur agit sur un ecran (UI)
2. L'ecran appelle un Provider
3. Le Provider appelle un Service
4. Le Service lit/ecrit Firebase (Firestore/Auth)
5. Le Provider notifie l'UI avec `notifyListeners()`

Ce pattern se repete pour auth, livres, emprunts, messages, notifications, avis et evenements.

## 3. Outils et technologies utilises
### Framework et langage
- Flutter
- Dart

### Backend as a Service
- Firebase Core
- Firebase Authentication
- Cloud Firestore

### Gestion d'etat
- Provider (ChangeNotifier)

### Autres packages
- image_picker: selection image (profil/couverture)
- shared_preferences: persistance locale (ex: session/login)

### Qualite
- flutter_lints
- flutter analyze

## 4. Modules fonctionnels implementes
### 4.1 Authentification et profils
- Inscription / connexion / deconnexion
- Recuperation de mot de passe
- Creation/chargement du profil utilisateur depuis Firestore
- Gestion image de profil (taille controlee)

### 4.2 Catalogue de livres
- Chargement temps reel des livres
- Filtrage par genre
- CRUD livre cote admin
- Disponibilite livre (isAvailable)

### 4.3 Emprunts
- Emprunt avec date limite (`dueDate`)
- Retour de livre
- Prolongation (1 fois max)
- Historique + emprunts actifs
- Verifications metier (pas de double emprunt actif du meme livre par meme user)

### 4.4 Messagerie
- Conversations entre utilisateurs
- Envoi/reception temps reel des messages
- Marquage lu/non lu
- Suppression conversation

### 4.5 Notifications
- Notifications utilisateur
- Notifications non lues
- Marquage individuel / global en lu
- Rappels de retour
- Notification de disponibilite livre
- Invitation evenement

### 4.6 Avis (Reviews)
- Ajouter / modifier / supprimer un avis
- Note moyenne et nombre d'avis
- Verification d'avis deja existant par utilisateur/livre

### 4.7 Evenements
- Lecture des evenements pour utilisateur connecte
- CRUD evenement cote admin
- Inscription/desinscription utilisateur a un evenement
- Controle des places (`registeredCount`, `maxParticipants`)

### 4.8 Administration
- Dashboard admin
- Gestion des utilisateurs (promotion/demotion admin)
- Gestion du catalogue
- Gestion des evenements
- Statistiques globales (dont emprunts actifs globaux)

## 5. Besoins fonctionnels
### 5.1 Acteurs
- Utilisateur simple
- Administrateur

### 5.2 Besoins utilisateur simple
- S'inscrire / se connecter
- Parcourir et filtrer les livres
- Emprunter, retourner, prolonger un livre
- Voir son historique
- Discuter avec d'autres utilisateurs
- Laisser des avis
- Voir les evenements et s'y inscrire
- Recevoir des notifications

### 5.3 Besoins administrateur
- Acceder au dashboard admin
- Gerer utilisateurs et roles
- Gerer catalogue livres
- Gerer evenements
- Visualiser les statistiques globales

## 6. Besoins non fonctionnels
- Securite:
  - Acces par roles via Firestore Rules
  - Donnees segmentees par utilisateur
- Performance:
  - Streams Firestore pour maj temps reel
  - Transactions pour operations critiques (ex: emprunt)
- Fiabilite:
  - Gestion des erreurs provider/service
  - Fallback auth/profile si certaines rules bloquent
- Maintenabilite:
  - Separation UI / state / services
  - codebase modulaire par domaine
- Portabilite:
  - Android, iOS, Web, Desktop (structure Flutter multi-plateforme)

## 7. Securite Firestore (points cle)
Les regles definissent:
- lecture selon authentification
- ecriture restreinte selon role admin ou proprietaire
- lecture/ecriture messages limitees aux participants
- acces notifications limite au proprietaire
- evenements:
  - lecture: utilisateur connecte
  - creation/suppression: admin
  - update inscription: utilisateur connecte limite a `registeredCount` et `participants`

Important: apres modification des regles, il faut deployer:

```bash
firebase deploy --only firestore:rules
```

## 8. Decisions techniques importantes a expliquer au prof
1. Pourquoi Provider?
- Simple, lisible, suffisant pour ce perimetre.

2. Pourquoi Firestore en temps reel?
- Synchronisation immediate (emprunts, messages, events, notifications).

3. Pourquoi transactions sur emprunt?
- Eviter les incoherences (livre marque disponible alors qu'un emprunt est cree, etc.).

4. Pourquoi status de pret (`active`, `extended`, `returned`)?
- Regles metier explicites et statistiques plus faciles.

5. Pourquoi separation Service/Provider?
- Service = logique metier et acces donnees.
- Provider = etat UI + orchestration.

## 9. Risques techniques et corrections recentes (a connaitre)
- Erreur permission-denied sur events pour user simple:
  - Cause: regles ecriture trop strictes.
  - Correction: update limitee a `participants`/`registeredCount` pour utilisateur connecte.

- Erreur async/context Flutter (`_dependents.isEmpty`):
  - Cause probable: usage de context apres await/dialog pop.
  - Correction: verifications `mounted`, flux async securises.

- Dashboard admin "emprunts actifs = 0":
  - Cause: compteur base sur provider scope utilisateur.
  - Correction: compteur global base sur la collection `loans` (status active/extended).

## 10. Questions probables du prof (avec reponses courtes)
### Q1. Quelle architecture avez-vous adoptee?
Reponse:
Architecture en couches: UI -> Provider -> Service -> Firebase, avec modeles de donnees separes.

### Q2. Comment gerez-vous les droits admin vs utilisateur?
Reponse:
Par role `isAdmin` stocke dans `users`, puis enforce dans Firestore Rules.

### Q3. Pourquoi les streams au lieu de requetes ponctuelles?
Reponse:
Pour les vues temps reel (messages, notifications, emprunts, events), cela evite les refresh manuels.

### Q4. Comment evitez-vous les incoherences lors d'un emprunt?
Reponse:
Transaction Firestore: creation pret + update disponibilite livre dans la meme operation atomique.

### Q5. Que se passe-t-il si un user essaie d'emprunter 2 fois le meme livre?
Reponse:
Verification prealable dans la collection loans sur status actifs, puis exception metier.

### Q6. Pourquoi le dashboard admin affichait 0 emprunts actifs?
Reponse:
Il lisait les emprunts du user courant, pas tous les users. Corrige via stream global sur loans.

### Q7. Comment garantissez-vous la securite des messages?
Reponse:
Regles Firestore: lecture/ecriture seulement pour les participants (ou admin).

### Q8. Comment testez-vous la qualite du code?
Reponse:
`flutter analyze`, tests Flutter, revue manuelle des flux critiques (auth, emprunt, permissions, events).

### Q9. Pourquoi Firestore plutot qu'un backend custom?
Reponse:
Vitesse de mise en place, auth integree, temps reel natif, suitable pour MVP academic.

### Q10. Quelles limites actuelles?
Reponse:
Certaines parties restent orientees MVP (tests auto encore limités, logs et refactorings possibles, pagination optimisable).

## 11. Scenarios de demo recommandes (script soutenance)
1. Login user simple
2. Parcourir catalogue + filtre
3. Emprunter un livre -> voir "Emprunts"
4. Ouvrir admin dashboard (compteur emprunts actifs augmente)
5. Event: user simple voit les events et s'inscrit
6. Admin: cree/modifie event
7. Avis: ajouter/modifier avis sur livre
8. Notifications: marquer comme lu
9. Messagerie: envoyer un message

## 12. Checklist avant la soutenance
- `flutter pub get`
- `flutter analyze` (pas d'erreurs bloquantes)
- `flutter run` sur l'appareil de demo
- Regles Firestore deployee
- Compte admin + compte user simple prets
- Donnees de demo dans Firestore (livres, events, users)
- Internet stable

## 13. Commandes utiles
```bash
flutter pub get
flutter analyze
flutter test
flutter run
firebase deploy --only firestore:rules
```

## 14. Pitch de 45 secondes (memorisation)
"BookShare est une application Flutter connectee a Firebase qui digitalise le partage de livres. J'ai structure le projet en couches UI/Provider/Service pour separer affichage, etat et logique metier. Les fonctions principales sont l'authentification, le catalogue, les emprunts avec regles metier, la messagerie, les notifications, les avis et les evenements. La securite est enforcee par Firestore Rules avec gestion des roles admin/utilisateur. Les flux critiques utilisent des streams et des transactions pour garder la coherence des donnees en temps reel."

## 15. Axes d'amelioration (si on te demande "et ensuite?")
- Ajouter des tests d'integration pour les cas metier critiques
- Ajouter pagination et indexation avancee Firestore
- Ajouter monitoring/crash reporting
- Migrer progressivement vers une architecture Clean Architecture complete (domain/use-cases/repositories)
- Ajouter CI/CD (analyze + tests + build)
