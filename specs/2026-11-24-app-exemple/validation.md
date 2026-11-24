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

- `statusBaseUrl` local → `GET http://10.0.2.2:8080/paiementNotif/{token}` exact
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
- écoute sur `0.0.0.0:8080`, joignable en `10.0.2.2` depuis l'émulateur

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

## Résultat de validation — À COMPLÉTER
