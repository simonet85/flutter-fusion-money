# Phase 3 Validation — API de haut niveau

## Definition of Done

Tout ce qui suit doit être vrai avant de fusionner la branche dans `main`.

### 1. L'analyse est propre

```
flutter analyze
```

`No issues found!`, code 0, analyse stricte toujours active.

### 2. Les tests passent

```
flutter test
```

Code 0, et la suite existante de la phase 2 reste verte. Elle couvre en plus :

- `MoneyFusion.pay` avec `MockClient` en échec de création : `statut: false` → `PaymentError` portant `PaymentCreationException`
- `MoneyFusion.pay` : coupure réseau → `PaymentError` portant `MoneyFusionNetworkException`
- `MoneyFusion.pay` : HTTP non 2xx → `PaymentError` portant `MoneyFusionHttpException`
- `MoneyFusion.pay` : JSON invalide → `PaymentError` portant `MoneyFusionFormatException`
- aucun de ces cas ne lève d'exception hors de `PaymentResult` et aucune navigation n'est tentée

### 3. Le formatage est respecté

```
dart format --output=none --set-exit-if-changed .
```

Code 0.

### 4. Les dépendances restent maîtrisées

`pubspec.yaml` ne contient toujours que `flutter`, `http`, `material_ui` et `webview_flutter` en dépendances. Aucun paquet ajouté.

### 5. L'API tient la promesse d'un seul appel

- `MoneyFusion.pay` renvoie `Future<PaymentResult>` non nul ; une route fermée sans résultat devient `PaymentCancelled`
- une erreur de création est renvoyée dans `PaymentError`, jamais levée
- `MoneyFusion.pay` est documenté en dartdoc ; aucun type interne n'apparaît dans sa signature
- l'API de bas niveau de la phase 2 (`MoneyFusionClient`, `MoneyFusionCheckout`, `PaymentResult`) reste publique et inchangée

### 6. Le README est à jour

- parcours principal avec `MoneyFusion.pay` et `switch` à trois cas (`PaymentCompleted`, `PaymentCancelled`, `PaymentError`), sans `case null`
- sous-section « API de bas niveau » conservant le parcours de la phase 2
- contrat backend inchangé, avec le rappel que le lien API et la clé PAYOUT restent au backend

### 7. Version et changelog alignés

`version: 0.2.0`, `moneyFusionVersion == '0.2.0'` (test existant), entrée `0.2.0` dans `CHANGELOG.md`.

### 8. Aucun test ne touche le réseau ni une vraie WebView

Tous les appels HTTP passent par `MockClient`. Le chemin nominal de `pay` (création réussie puis checkout) n'est pas instancié en test ; les erreurs d'une sous-ressource WebView et le retour par redirection restent vérifiés sur appareil en phase 4.

## Not Required

- Vérification sur émulateur/simulateur : phase 4 (app d'exemple)
- Appels réels à MoneyFusion ou à un backend : hors périmètre des tests
- Webhooks, PAYOUT, polling du statut : backend ou phases ultérieures
- Personnalisation de la route, du thème ou de la localisation : hors périmètre
- CI

## Résultat de validation — 2026-11-24

Exécuté sur Flutter 3.50.1 (canal stable) / Dart 3.14.0.

| Vérification | Résultat |
|---|---|
| `flutter analyze` | `No issues found!`, code 0 |
| `flutter test` | 34 tests, `All tests passed!`, code 0 (30 de la phase 2 + 4 pour `pay`) |
| `dart format --output=none --set-exit-if-changed .` | 0 fichier modifié, code 0 |
| Dépendances | inchangées : `flutter`, `http` 1.6.0, `material_ui` 1.11.1, `webview_flutter` 4.14.1 |
| API | `MoneyFusion.pay` exportée, résultat non nul, erreurs de création dans `PaymentError` |
| README | parcours principal `pay` + sous-section « API de bas niveau » ; contrat backend inchangé |
| Version | `0.2.0` dans le pubspec, `moneyFusionVersion` et le CHANGELOG |
| Réseau et WebView | aucun appel réel ; `MockClient` uniquement, chemin nominal non instancié en test |

Les 8 points du Definition of Done sont satisfaits. La vérification du chemin
nominal et des comportements WebView sur appareil reste reportée à la phase 4,
conformément au périmètre.
