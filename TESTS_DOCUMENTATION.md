# 🧪 Documentation Complète des Tests - Assistant Thérapeutique

## Vue d'ensemble

Ce projet implémente une **stratégie de tests multi-niveaux** couvrant le backend (Java/Spring Boot) et le frontend (Flutter/Dart), avec des tests de sécurité automatisés.

---

## 📊 Types de Tests Implémentés

| Type | Backend | Frontend | Total |
|------|---------|----------|-------|
| **Tests Unitaires** | 12 fichiers | 15 fichiers | 27 |
| **Tests d'Intégration** | 5 fichiers | - | 5 |
| **Tests E2E** | - | 8 fichiers | 8 |
| **Tests de Sécurité** | ✅ OWASP Dependency-Check + ZAP | - | 2 outils |


---

## 1️⃣ Tests Unitaires

### Définition
Tests isolés qui vérifient le comportement d'une unité de code (fonction, méthode, classe) en **mockant** toutes les dépendances externes.

### Pourquoi les utiliser ?
- ⚡ **Exécution rapide** (millisecondes)
- 🔍 **Localisation précise** des bugs
- 🔄 **Feedback immédiat** lors du développement
- 📈 **Couverture de code** mesurable

---

### Backend (Java/Spring Boot)

#### Outils utilisés

| Outil | Rôle dans le projet |
|-------|---------------------|
| **JUnit 5** | Framework de tests - structure des tests, assertions, annotations `@Test` |
| **Mockito** | Mock des repositories et services pour isoler les tests |
| **Spring Boot Test** | Configuration du contexte de test, injection de dépendances |
| **JaCoCo** | Mesure de couverture de code, génération de rapports XML pour SonarQube |

#### Fichiers de tests

**Controllers (6 fichiers)** - Tests de la logique de routing et validation :
- `AuthControllerTest.java`
- `ChatMessageControllerTest.java`
- `ConversationControllerTest.java`
- `JournalControllerTest.java`
- `MoodControllerTest.java`
- `UserControllerTest.java`

**Services (6 fichiers)** - Tests de la logique métier :
- `AiServiceTest.java`
- `ChatMessageServiceTest.java`
- `ConversationServiceTest.java`
- `JournalServiceTest.java`
- `MoodServiceTest.java`
- `UserServiceTest.java`

#### Exécution via IntelliJ
1. Ouvrir le panneau **Maven** (à droite)
2. Naviguer vers : `Backend_Assistant_therapeutique → Lifecycle → test`
3. Double-cliquer sur **test**

---

### Frontend (Flutter/Dart)

#### Outils utilisés

| Outil | Rôle dans le projet |
|-------|---------------------|
| **flutter_test** | Framework de tests Flutter, assertions sur widgets |
| **Mockito (Dart)** | Mock des services HTTP et dépendances |
| **http_mock_adapter** | Simulation des réponses API REST |
| **LCOV** | Format de rapport de couverture pour SonarQube |

#### Fichiers de tests

**Models (5 fichiers)** - Tests de sérialisation JSON :
- `conversation_model_test.dart`
- `journal_model_test.dart`
- `message_model_test.dart`
- `mood_model_test.dart`
- `quote_model_test.dart`

**Services (5 fichiers)** - Tests des appels API :
- `auth_service_test.dart`
- `chat_service_test.dart`
- `journal_service_test.dart`
- `mood_service_test.dart`
- `quote_service_test.dart`

**Widgets (5 fichiers)** - Tests des composants UI :
- `daily_quote_widget_test.dart`
- `email_field_test.dart`
- `password_field_test.dart`
- `separator_test.dart`
- `tips_box_test.dart`

#### Exécution via IntelliJ/Android Studio
1. Ouvrir le projet Flutter dans IntelliJ
2. Clic droit sur le dossier `test/` → **Run Tests in 'test'**
3. Ou : Terminal intégré → `flutter test --coverage`

---

## 2️⃣ Tests d'Intégration

### Définition
Tests qui vérifient l'interaction entre plusieurs composants **réels** (controller → service → repository → base de données).

### Pourquoi les utiliser ?
- 🔗 **Validation des flux complets** (requête HTTP → réponse)
- 🗃️ **Test avec vraie base de données** (H2 in-memory)
- 🐛 **Détection des problèmes d'intégration** entre couches
- 📊 **Rapports visuels** avec Allure

---

### Backend (Java/Spring Boot)

#### Outils utilisés

| Outil | Rôle dans le projet |
|-------|---------------------|
| **MockMvc** | Simulation de requêtes HTTP sans serveur réel |
| **H2 Database** | Base de données in-memory pour isolation des tests |
| **@SpringBootTest** | Chargement du contexte Spring complet |
| **@DirtiesContext** | Réinitialisation du contexte entre les classes de tests |
| **Allure** | Génération de rapports HTML interactifs et visuels |

#### Fichiers de tests (5 fichiers, ~30 tests)

| Fichier | Tests | Endpoints couverts |
|---------|-------|-------------------|
| `AuthControllerIntegrationTest.java` | 3 | Register, Login |
| `JournalControllerIntegrationTest.java` | 6 | CRUD Journal |
| `MoodControllerIntegrationTest.java` | 7 | CRUD Mood |
| `UserControllerIntegrationTest.java` | 7 | Profile, Stats |
| `ConversationControllerIntegrationTest.java` | 7 | CRUD Conversations |

#### Exécution via IntelliJ

**Lancer les tests d'intégration :**
1. Panneau **Maven** → `Backend_Assistant_therapeutique → Lifecycle`
2. Double-cliquer sur **clean** puis **verify**

**Générer le rapport Allure :**
1. Panneau **Maven** → `Backend_Assistant_therapeutique → Plugins → allure`
2. Double-cliquer sur **allure:serve**
3. Le rapport s'ouvre automatiquement dans le navigateur

**Accès manuel au rapport :** `target/site/allure-maven-plugin/index.html`

---

## 3️⃣ Tests End-to-End (E2E)

### Définition
Tests qui simulent un **utilisateur réel** interagissant avec l'application complète via l'interface graphique.

### Pourquoi les utiliser ?
- 👁️ **Tests visuels** - voir l'application s'exécuter
- 🔄 **Validation des parcours utilisateur** complets
- 🐛 **Détection des régressions UI**
- ✅ **Confiance** avant mise en production

---

### Frontend (Flutter)

#### Outils utilisés

| Outil | Rôle dans le projet |
|-------|---------------------|
| **integration_test** | Framework E2E Flutter officiel |
| **flutter_driver** | Pilotage de l'application pendant les tests |
| **ChromeDriver** | Automatisation du navigateur Chrome |

#### Fichiers de tests (8 fichiers)

| Fichier | Scénarios testés |
|---------|------------------|
| `all_features_test.dart` | ⭐ Test consolidé (login unique, toutes features) |
| `login_test.dart` | Connexion (succès/échec) |
| `register_test.dart` | Inscription utilisateur |
| `mood_tracking_test.dart` | Suivi d'humeur |
| `journal_test.dart` | CRUD entrées journal |
| `wellness_test.dart` | Méditation, respiration |
| `user_flow_test.dart` | Parcours utilisateur complet |
| `test_bundle.dart` | Bundle de tests groupés |

#### Exécution via IntelliJ

**Étape 1** - Lancer ChromeDriver :
1. Terminal IntelliJ (bas de l'écran) → Onglet **+** (nouveau terminal)
2. Exécuter : `C:\chromedriver-win64\chromedriver.exe --port=4444`

**Étape 2** - Lancer les tests E2E :
1. Ouvrir le projet Flutter dans IntelliJ
2. Clic droit sur `integration_test/all_features_test.dart`
3. Sélectionner **Run 'all_features_test.dart'**

*Ou via Terminal intégré :*
`flutter drive --driver=test_driver/integration_test.dart --target=integration_test/all_features_test.dart -d chrome`

#### Prérequis
- Backend Spring Boot en cours d'exécution
- ChromeDriver installé et compatible avec Chrome

---

## 4️⃣ Tests de Sécurité

### Définition
Ensemble d'outils pour détecter les **vulnérabilités** dans le code, les dépendances et l'application en cours d'exécution.

### Pourquoi les utiliser ?
- 🔒 **Détection proactive** de failles de sécurité
- 📋 **Conformité** aux standards (OWASP Top 10, SANS)
- 🚨 **Alertes** sur les vulnérabilités connues (CVE)

### Types de tests de sécurité implémentés

| Type | Outil | Ce qu'il analyse |
|------|-------|------------------|
| **SCA** (Software Composition Analysis) | OWASP Dependency-Check | Dépendances Maven (CVE) |
| **DAST** (Dynamic Application Security Testing) | OWASP ZAP | Application en cours d'exécution |

---

### OWASP Dependency-Check (SCA)

Scan des **dépendances** pour détecter les vulnérabilités connues (ex: Log4Shell).

#### Outils utilisés

| Outil | Rôle dans le projet |
|-------|---------------------|
| **dependency-check-maven** | Plugin Maven pour scan de sécurité |
| **NVD (National Vulnerability Database)** | Base de données CVE officielle (nécessite API key) |
| **OSS Index** | Base alternative Sonatype (gratuite, sans API key) |

#### Exécution via IntelliJ

**Créer une configuration de Run :**
1. Menu **Run → Edit Configurations...**
2. Cliquer **+** → **Maven**
3. **Name** : `OWASP Security Scan`
4. **Command line** : `dependency-check:check -DnvdApiKey=VOTRE_CLE_API`
5. Cliquer **OK**
6. Lancer avec le bouton ▶️

**Ou via panneau Maven :**
1. `Plugins → dependency-check → dependency-check:check`

#### Accès au rapport
- Clic droit sur `target/dependency-check/dependency-check-report.html` → **Open in Browser**

#### Obtenir une clé API NVD (gratuite)
1. Aller sur : https://nvd.nist.gov/developers/request-an-api-key
2. Remplir le formulaire (email)
3. Recevoir la clé par email (activation sous 24h)

---

### OWASP ZAP (DAST)

Scan de l'**application en cours d'exécution** pour détecter les vulnérabilités web (XSS, injection SQL, CSRF, etc.).

#### Outils utilisés

| Outil | Rôle dans le projet |
|-------|---------------------|
| **OWASP ZAP** | Scanner de sécurité dynamique |
| **OpenAPI/Swagger** | Import automatique des endpoints API |

#### Prérequis
- Télécharger ZAP : https://www.zaproxy.org/download/
- Backend Spring Boot en cours d'exécution
- Swagger UI accessible : `http://localhost:8080/swagger-ui.html`

#### Exécution via OWASP ZAP GUI

**Étape 1** - Lancer le Backend :
- IntelliJ → Run `AssistantTherapeutiqueApplication`

**Étape 2** - Importer les APIs dans ZAP :
1. Ouvrir OWASP ZAP
2. Menu **Import → Import an OpenAPI Definition from URL**
3. **URL** : `http://localhost:8080/v3/api-docs`
4. **Target URL** : `http://localhost:8080`
5. Cliquer **Import**

**Étape 3** - Lancer le scan :
1. Clic droit sur le site importé → **Active Scan**
2. Attendre la fin du scan

**Étape 4** - Générer le rapport :
1. Menu **Report → Generate Report...**
2. Choisir format **HTML**
3. Sauvegarder dans le projet

#### Accès au rapport
- Ouvrir le fichier `zap-report.html` sauvegardé

#### Vulnérabilités détectées

| Niveau | Signification |
|--------|---------------|
| 🔴 **High** | Vulnérabilités critiques à corriger immédiatement |
| 🟠 **Medium** | Problèmes importants à corriger |
| 🟡 **Low** | Améliorations recommandées |
| 🔵 **Informational** | Conseils, pas de risque direct |

---


## 5️⃣ Analyse de Code (SonarQube)

### Définition
Analyse statique du code pour détecter bugs, code smells, vulnérabilités et mesurer la couverture.

### Pourquoi l'utiliser ?
- 📊 **Qualité de code** mesurable
- 🐛 **Détection de bugs** potentiels
- 🔒 **Vulnérabilités de sécurité** (SAST)
- 📈 **Tendances** au fil du temps

#### Exécution via IntelliJ
1. Terminal IntelliJ (bas de l'écran)
2. Se placer à la racine du projet : `cd c:\Users\abder\Desktop\5IIR\Dev MultiPlatforme\Assistant-thearpeutique`
3. Exécuter : `sonar-scanner`

#### Configuration
Voir `sonar-project.properties` à la racine du projet.

---

## 📋 Récapitulatif via IntelliJ GUI

| Action | Chemin IntelliJ |
|--------|----------------|
| **Tests unitaires Backend** | Maven → Lifecycle → **test** |
| **Tests unitaires Frontend** | Clic droit `test/` → Run Tests |
| **Tests d'intégration** | Maven → Lifecycle → **clean** puis **verify** |
| **Rapport Allure** | Maven → Plugins → allure → **allure:serve** |
| **Tests E2E** | Clic droit `all_features_test.dart` → Run |
| **Scan sécurité** | Maven → Plugins → dependency-check → **check** |
| **Analyse SonarQube** | Terminal → `sonar-scanner` |

---

## 📊 Métriques de Couverture

| Composant | Couverture estimée |
|-----------|-------------------|
| Backend (Controllers + Services) | ~85% |
| Frontend (Models + Services) | ~78% |
| Tests d'intégration | 30 tests |
| Tests E2E | 8 scénarios |

---

## 🏗️ Architecture des Tests

```
Assistant-thearpeutique/
├── Backend_Assistant_therapeutique/
│   └── src/test/java/.../
│       ├── controller/          # 6 tests unitaires
│       ├── service/             # 6 tests unitaires
│       └── integration/         # 5 tests d'intégration
│
├── Assistant-therapeutique-frontend/
│   ├── test/
│   │   ├── models/              # 5 tests unitaires
│   │   ├── services/            # 5 tests unitaires
│   │   └── widgets/             # 5 tests unitaires
│   └── integration_test/        # 8 tests E2E
│
└── sonar-project.properties     # Config SonarQube
```
