# Phase 4 Validation — App d'exemple

## Definition of Done

Tout ce qui suit doit être vrai avant de fusionner la branche dans `main`.

### 1. L'analyse est propre partout

```
flutter analyze            # racine du package
cd example && flutter analyze
```

`No issues found!`, code 0 dans les deux cas, analyse stricte toujours active pour le package.

### 2. Les tests du package passent

```
flutter test
```

Code 0, suite des phases 2 et 3 toujours verte, plus :

- `statusBaseUrl` local → `GET http://10.0.2.2:8090/paiementNotif/{token}` exact
- sans `statusBaseUrl` → `GET https://pay.moneyfusion.net/paiementNotif/{token}` (test existant)

Le code de l'exemple n'a pas de tests automatisés (cf. Not Required).

### 3. Le formatage est respecté

```
dart format --output=none --set-exit-if-changed .
```

Code 0, y compris `example/` et `example/fake_backend/`.

### 4. L'extension d'API est sans rupture

- `statusBaseUrl` est facultatif ; son absence reproduit le comportement de la phase 2
- `backendUrl`, `timeout`, l'injection de `http.Client` et `close()` sont inchangés
- version `0.3.0` dans le pubspec, `moneyFusionVersion` et le CHANGELOG

### 5. Le faux backend se comporte comme le contrat

Vérifié à la main :

- `POST /payments` sans `return_url` → `statut: false` ; avec le corps complet → `statut: true`, `token`, `url`
- `GET /paiementNotif/<token>` → `data.statut` `pending` puis `paid` ou `failure` après `finish`
- `Montant`, `frais`, `moyen`, `numeroTransaction` présents et cohérents avec la requête
- écoute sur `0.0.0.0:8090`, joignable en `10.0.2.2` depuis l'émulateur

### 6. La démo fonctionne sur émulateur Android

Android Studio, SDK et émulateur installés ; faux backend et app lancés ; scénarios observés :

- « Payer » → écran de résultat `paid` avec les détails de transaction
- « Annuler » → écran de résultat `failure`
- croix de fermeture → `PaymentCancelled`
- backend arrêté → `PaymentError` de type réseau dès la création

Les comportements WebView laissés ouverts en phase 2 sont notés : retour par navigation JavaScript détecté, erreurs de sous-ressource sans fermeture intempestive du checkout.

### 7. Le README permet de rejouer la démo

Section « Exemple » avec les deux commandes, l'alias `10.0.2.2`, la nécessité du cleartext Android, et la mention que iOS n'est pas vérifié. Prérequis mis à jour (toolchain Android requise à partir de cette phase).

### 8. Aucun appel réel à MoneyFusion

Aucun secret, aucun paiement réel ; l'app ne parle qu'au backend local. Les tests du package restent sans réseau via `MockClient`.

## Not Required

- Vérification iOS : aucun Mac disponible ; reste ouverte
- Tests automatisés de l'app d'exemple et de la WebView
- Support web, Windows ou Linux
- Webhooks, PAYOUT, polling du statut
- CI

## Résultat de validation — 2026-11-25

Exécuté sur Flutter 3.50.1 (canal stable) / Dart 3.14.0, avec Android Studio
2026.2.2.10, SDK Android 36 (build-tools 36.0.0, platform-tools 37.0.3),
émulateur 37.3.10.0 et AVD `demo36` (`system-images;android-36;google_apis;x86_64`,
profil Pixel 6), accéléré par WHPX.

| Vérification | Résultat |
|---|---|
| `flutter analyze` (racine et `example/`) | `No issues found!`, code 0 dans les deux cas |
| `flutter test` | 35 tests, `All tests passed!`, code 0 (34 + `statusBaseUrl`) |
| `dart format --output=none --set-exit-if-changed .` | 0 fichier modifié, code 0 |
| Extension d'API | `statusBaseUrl` testé ; URL par défaut inchangée ; version `0.3.0` alignée |
| Faux backend (`curl`) | création refusée → `statut: false` ; acceptée → token et `url` ; statut `pending` → `paid` et `failure` ; champs de `data` conformes |
| Android Studio, SDK, émulateur | installés et vérifiés (`flutter doctor` : toolchain Android verte, licences acceptées, `-accel-check` : WHPX utilisable) |
| Scénario « Payer » | `Statut : paid`, `Montant : 200`, `Frais : 0`, `Moyen : orange`, `Transaction : demo-txn-demo-4` |
| Scénario « Annuler » | `Statut : failure` avec les mêmes détails de transaction |
| Scénario fermeture (X) | `Paiement annulé.` (`PaymentCancelled`) |
| Scénario backend arrêté | `Erreur : Erreur réseau : Connection refused` (`PaymentError` réseau dès la création) |
| WebView | retour au `return_url` par navigation JavaScript détecté dans les deux issues ; page locale sans sous-ressource, donc aucun cas d'erreur de sous-ressource observé ; aucune exception dans logcat |

Le port de la démo est `8090` : `8080` était déjà utilisé par un autre service
local sur le poste. Le faux backend écoute sur `0.0.0.0:8090` et l'app cible
`10.0.2.2:8090`.

Note d'environnement : sur le réseau du poste, le wrapper Gradle n'arrivait pas
à télécharger `gradle-9.5.0-all.zip` (`Connection reset` puis
`UnknownHostException: services.gradle.org` côté Java, alors que curl suivait
les redirections). La distribution a été téléchargée via curl puis placée dans
`~/.gradle/wrapper/dists/`, après quoi le build a abouti. Aucun changement de
dépôt n'a été nécessaire.

La phase est validée : les huit points du DoD sont satisfaits.
