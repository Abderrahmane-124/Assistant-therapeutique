# 🧪 Documentation des Tests - Assistant Thérapeutique

## Vue d'ensemble

Ce projet utilise une stratégie de tests unitaires ciblée sur les couches contenant de la logique métier, tout en excluant les fichiers purement déclaratifs ou générés.

---

## Backend (Java/Spring Boot)

### Types de tests

| Type | Description |
|------|-------------|
| **Tests unitaires** | Tests isolés avec mocking des dépendances |
| **Tests d'intégration** | Tests complets avec base de données H2 in-memory |

### Technologies utilisées

| Outil | Rôle |
|-------|------|
| JUnit 5 | Framework de tests |
| Mockito | Mocking des dépendances |
| Spring Boot Test | Support pour tests Spring |
| MockMvc | Simulation des requêtes HTTP |
| H2 Database | Base de données in-memory pour tests d'intégration |
| JaCoCo | Couverture de code |
| **Allure** | Rapports visuels HTML interactifs |

### Tests Unitaires ✅

| Couche | Fichiers | Justification |
|--------|----------|---------------|
| **Controllers** | 6/7 | Logique de routing et validation des requêtes |
| **Services** | 6/6 | Cœur de la logique métier |

### Tests d'Intégration ✅

| Controller | Tests | Endpoints testés |
|------------|-------|------------------|
| **AuthController** | 3 | Register, Login (success/failure) |
| **JournalController** | 6 | CRUD complet (Create, Read, Update, Delete) |
| **MoodController** | 7 | CRUD complet + validation |
| **UserController** | 7 | GetById, Update, Stats |
| **ConversationController** | 7 | CRUD + UpdateTitle |
| **TOTAL** | **30** | |

> **Note** : `ChatMessageController` et `CustomErrorController` sont exclus car ils dépendent de services externes (AI) ou sont génériques.

### Parties exclues ❌

| Couche | Justification |
|--------|---------------|
| **Models/Entities** | Classes générées par Lombok (`@Data`) - aucune logique |
| **DTOs** | Simples transporteurs de données |
| **Repositories** | Interfaces Spring Data - testées implicitement via intégration |
| **Config** | Configuration déclarative (CORS, etc.) |
| **Application.java** | Point d'entrée Spring Boot |

### Commandes d'exécution

#### Exécuter tous les tests (unitaires + intégration)
```bash
cd Backend_Assistant_therapeutique
mvn clean verify
```

#### Générer et voir le rapport Allure (interface visuelle)
```bash
# Après avoir exécuté les tests
mvn allure:serve
```
> 🌐 Un serveur local démarre et ouvre le rapport dans votre navigateur

#### Générer le rapport sans ouvrir le navigateur
```bash
mvn allure:report
# Rapport généré dans target/site/allure-maven-plugin/
```

### Rapport Allure - Fonctionnalités

Le rapport Allure offre :
- 📊 **Dashboard** : Vue d'ensemble des résultats
- 📈 **Graphiques** : Taux de réussite, durée des tests
- 🏷️ **Catégories** : Tests groupés par Epic/Feature/Story
- 📝 **Détails** : Stack traces, descriptions, sévérité
- 📜 **Historique** : Évolution des tests au fil du temps



## Frontend (Flutter/Dart)

### Type de tests
- **Tests unitaires** pour les modèles et services
- **Tests de widgets** pour les composants UI réutilisables

### Technologies utilisées
| Outil | Rôle |
|-------|------|
| flutter_test | Framework de tests Flutter |
| Mockito | Mocking des dépendances |
| http_mock_adapter | Mock des appels HTTP |
| LCOV | Format de rapport de couverture |

### Parties testées ✅
| Couche | Fichiers | Justification |
|--------|----------|---------------|
| **Models** | 5/5 | Logique de sérialisation JSON (fromJson/toJson) |
| **Services** | 5/4 | Appels API et gestion des données |
| **Widgets** | 5 | Composants UI réutilisables (champs, boutons) |

### Parties exclues ❌
| Couche | Justification |
|--------|---------------|
| **Features (screens)** | Écrans complets - testés manuellement ou via tests d'intégration |
| **main.dart** | Point d'entrée de l'application |
| **UI/Styles** | Constantes de thème - aucune logique |

### Commande d'exécution
```bash
cd Assistant-therapeutique-frontend
flutter test --coverage
dart run tool/lcov_to_sonar.dart  # Conversion pour SonarQube
```

---

## Intégration SonarQube

### Configuration
Les exclusions de couverture sont définies dans `sonar-project.properties` :
```properties
sonar.coverage.exclusions=**/model/**,**/dto/**,**/config/**,**/repository/**,...
```

### Rapports utilisés
| Langage | Format | Fichier |
|---------|--------|---------|
| Java | JaCoCo XML | `target/site/jacoco/jacoco.xml` |
| Dart | Generic Coverage | `coverage/sonar-coverage.xml` |

---

## Métriques de couverture

| Projet | Couverture locale | Objectif |
|--------|-------------------|----------|
| Backend | ~85% (lignes testées) | ≥ 50% |
| Frontend | ~78% (lignes testées) | ≥ 50% |

> **Note** : SonarQube affiche un pourcentage plus bas car il inclut tous les fichiers sources. Les exclusions configurées permettent d'aligner les métriques.

---

## Bonnes pratiques appliquées

1. **Isolation** : Chaque test est indépendant grâce au mocking
2. **Couverture ciblée** : Focus sur la logique métier, pas le boilerplate
3. **CI/CD ready** : Rapports générés automatiquement pour SonarQube
4. **Maintenabilité** : Structure de tests miroir de la structure source

---

## Tests E2E (Flutter Integration Tests Visuels)

### Vue d'ensemble

Les tests end-to-end (E2E) utilisent **flutter drive** avec **integration_test** pour exécuter les tests dans un navigateur Chrome réel avec **affichage visuel**.

> **Avantage** : Vous pouvez voir les tests s'exécuter en temps réel dans Chrome !

### Technologies utilisées

| Outil | Rôle |
|-------|------|
| integration_test SDK | Framework E2E Flutter |
| flutter_driver SDK | Driver pour exécution sur device |
| ChromeDriver | Automatisation navigateur Chrome |

### Architecture de test

```
integration_test/
├── all_features_test.dart    # ⭐ Test consolidé - Login unique (RECOMMANDÉ)
├── login_test.dart           # Tests page de connexion (3 tests)
├── register_test.dart        # Tests page d'inscription (2 tests)
├── mood_tracking_test.dart   # Tests suivi d'humeur (4 tests)
├── journal_test.dart         # Tests journal CRUD (5 tests)
├── wellness_test.dart        # Tests méditation/respiration (6 tests)
└── user_flow_test.dart       # Tests parcours complet (3 tests)

test_driver/
└── integration_test.dart     # Driver d'exécution
```

> 💡 **Recommandé** : Utilisez `all_features_test.dart` pour exécuter tous les tests avec un **seul login**, ce qui est plus rapide et efficace.

### Scénarios testés

#### 🔐 Authentification

| Fichier | Tests | Description |
|---------|-------|-------------|
| **login_test.dart** | 3 | Champs vides, credentials incorrects, login réussi → Home |
| **register_test.dart** | 2 | Champs vides, inscription valide avec email dynamique |

#### 😊 Suivi d'humeur (Mood Tracking)

| Fichier | Tests | Description |
|---------|-------|-------------|
| **mood_tracking_test.dart** | 4 | Navigation, validation sans sélection, création humeur, historique |

#### 📔 Journal (CRUD)

| Fichier | Tests | Description |
|---------|-------|-------------|
| **journal_test.dart** | 5 | Navigation, validation vide, création entrée, liste, affichage |

#### 🧘 Bien-être (Wellness)

| Fichier | Tests | Description |
|---------|-------|-------------|
| **wellness_test.dart** | 6 | Méditation (start/pause/reset), Respiration guidée (navigation, exercice) |

#### 🔄 Parcours utilisateur

| Fichier | Tests | Description |
|---------|-------|-------------|
| **user_flow_test.dart** | 3 | Parcours complet (Login → Mood → Journal → Home), navigation features, profil |

### Récapitulatif des tests

| Catégorie | Fichiers | Total Tests |
|-----------|----------|-------------|
| ⭐ **Consolidé** | 1 (`all_features_test.dart`) | 1 test complet |
| Authentification | 2 | 5 |
| Mood Tracking | 1 | 4 |
| Journal | 1 | 5 |
| Wellness | 1 | 6 |
| User Flow | 1 | 3 |
| **TOTAL** | **7** | **24** |

> ⭐ Le test consolidé `all_features_test.dart` se connecte **une seule fois** puis exécute tous les tests de fonctionnalités (Mood, Journal, Méditation, Respiration, Profil) en séquence.

### Commandes d'exécution

> ⚠️ **Important** : ChromeDriver doit être lancé dans un terminal séparé avant d'exécuter les tests.

**Étape 1** - Lancer ChromeDriver (dans un terminal) :
```bash
C:\chromedriver-win64\chromedriver.exe --port=4444
```

**Étape 2** - Exécuter les tests (dans un autre terminal) :
```bash
cd Assistant-therapeutique-frontend

# ⭐ RECOMMANDÉ - Test consolidé (login unique, toutes les fonctionnalités)
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/all_features_test.dart -d chrome
```

**Ou exécuter les tests individuels :**
```bash
# Tests de login
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/login_test.dart -d chrome

# Tests de register
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/register_test.dart -d chrome

# Tests Mood Tracking
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/mood_tracking_test.dart -d chrome

# Tests Journal
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/journal_test.dart -d chrome

# Tests Wellness (Méditation + Respiration)
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/wellness_test.dart -d chrome

# Tests Parcours utilisateur complet
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/user_flow_test.dart -d chrome
```

### Prérequis

1. SDK Flutter installé
2. Chrome installé
3. ChromeDriver installé et compatible avec votre version de Chrome
4. Backend Spring Boot en cours d'exécution (pour les tests avec API)

### Avantages

- ✅ **Tests visuels** - Voir les tests s'exécuter en temps réel dans Chrome
- ✅ Accès natif aux widgets Flutter
- ✅ Compatible Flutter Web
- ✅ Pas de packages externes requis
- ✅ Tests CRUD complets pour les features principales

