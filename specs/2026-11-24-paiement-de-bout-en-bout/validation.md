# Phase 2 Validation — Paiement de bout en bout

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

Code 0. La suite couvre au minimum :

- sérialisation `PaymentRequest` : clés `totalPrice`, `article`, `numeroSend`, `nomclient`, `personal_Info`, `return_url`, `webhook_url` ; aucune occurrence de `callback_url`
- `personal_Info` absent → clé absente du JSON ; `webhook_url` absent → clé absente
- `PaymentSession.fromJson` sur l'exemple de la doc ; `token`/`url` manquants → `MoneyFusionFormatException`
- statuts : `pending`, `paid`, `failure`, `"no paid"` → `noPaid` ; valeur inconnue → `UnknownPaymentStatusException`
- `PaymentDetails` sur l'exemple de la doc (`Montant`, `frais`, `moyen`, `numeroTransaction`), champs absents → `null`
- client : `POST` sur `backendUrl` avec le bon corps et l'en-tête JSON ; `GET` sur `paiementNotif/{token}` exact
- client : 500 → `MoneyFusionHttpException`, coupure réseau → `MoneyFusionNetworkException`, timeout → `MoneyFusionNetworkException`, JSON invalide → `MoneyFusionFormatException`, `statut: false` → création/statut refusés
- `matchesReturnUrl` : query ignorée, host différent refusé, chemin seulement préfixé refusé
- `CheckoutFlow` : un unique `checkStatus` par retour, `PaymentCancelled` sur fermeture, `PaymentError` sur erreur du client

### 3. Le formatage est respecté

```
dart format --output=none --set-exit-if-changed .
```

Code 0.

### 4. Les dépendances restent maîtrisées

`pubspec.yaml` ne contient que `flutter`, `http`, `material_ui` et `webview_flutter` en dépendances ; `material_ui` est le paquet officiel qui remplace `flutter/material`, déprécié en 3.50. Aucun autre paquet ajouté sans décision consignée.

### 5. Le contrat backend est documenté

README : envoi `POST` du corps MoneyFusion brut, réponse `{statut, token, message, url}`, signification de `statut: false`, et rappel que le lien API et la clé PAYOUT ne quittent jamais le backend.

### 6. L'API publique est utilisable telle quelle

Le README montre le parcours complet : `MoneyFusionClient`, `createPayment`, `MoneyFusionCheckout`, `PaymentResult`. Les membres publics sont documentés (dartdoc) et l'API ne fuit aucun type interne.

### 7. Version et changelog alignés

`version: 0.1.0`, `moneyFusionVersion == '0.1.0'` (test existant), entrée `0.1.0` dans `CHANGELOG.md`.

### 8. Aucun test ne touche le réseau ni une vraie WebView

Tous les appels HTTP passent par `MockClient` ; le widget n'est pas instancié avec la plateforme `webview_flutter` en test. La logique testable vit dans `CheckoutFlow` et `matchesReturnUrl`.

## Not Required

- Vérification sur émulateur/simulateur : phase 4 (app d'exemple), avec la toolchain Android/iOS
- Comportements WebView dépendants de la plateforme, à vérifier en phase 4 : retour par redirection serveur (détecté via `onNavigationRequest`) et erreurs de sous-ressource quand `isForMainFrame` est `null`
- Appels réels à MoneyFusion ou à un backend : hors périmètre des tests
- Polling du statut, webhooks, PAYOUT, API de haut niveau : phases ou backend ultérieurs
- CI

## Résultat de validation — 2026-11-24

Exécuté sur Flutter 3.50.1 (canal stable) / Dart 3.14.0.

| Vérification | Résultat |
|---|---|
| `flutter analyze` | `No issues found!`, code 0 |
| `flutter test` | 30 tests, `All tests passed!`, code 0 |
| `dart format --output=none --set-exit-if-changed .` | 0 fichier modifié, code 0 |
| Dépendances | `flutter`, `http` 1.6.0, `material_ui` 1.11.1, `webview_flutter` 4.14.1 |
| Contrat backend | README : sections « Utilisation » et « Contrat backend » |
| Version | `0.1.0` dans le pubspec, `moneyFusionVersion` et le CHANGELOG |
| Réseau et WebView | aucun appel réel ; tout passe par `MockClient`, aucun test n'instancie la WebView |

Les 8 points du Definition of Done sont satisfaits. La vérification sur
appareil reste reportée à la phase 4, conformément au périmètre.
