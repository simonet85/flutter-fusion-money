# Phase 4 Requirements — App d'exemple

## Scope

Prouver le parcours de bout en bout sur un appareil Android avec un faux backend local :

- Extension du package : `statusBaseUrl` facultatif sur `MoneyFusionClient` (défaut `https://pay.moneyfusion.net`), pour rendre le statut vérifiable localement. Version `0.3.0`.
- App `example/` minimale : montant, téléphone, nom, bouton payer, affichage du `PaymentResult`.
- Faux backend autonome `example/fake_backend/server.dart` (`dart:io`, zéro dépendance) : création, page de paiement factice « Payer » / « Annuler », statut.
- Android : installation d'Android Studio (SDK, licences, émulateur), exécution de la démo, vérification manuelle des quatre issues (paid, failure, annulation, erreur réseau).
- README : commandes de lancement, adresse `10.0.2.2`, cleartext Android, limites (iOS non vérifié).

## Out of Scope

- Vérification iOS : aucun Mac disponible ; restera ouverte après cette phase.
- Support web, Windows ou Linux de l'exemple : `webview_flutter` ne les supporte pas.
- Réception de webhooks dans le faux backend, PAYOUT, polling : backend ou plus tard.
- Appels réels à MoneyFusion : aucun secret, aucun paiement réel.
- Démo enrichie (articles libres, `personal_Info`, `webhook_url` saisis, journal d'étapes).
- Tests automatisés de l'app d'exemple et de la WebView.
- CI.

## Decisions

### `statusBaseUrl` injectable

```dart
MoneyFusionClient({
  required Uri backendUrl,
  Uri? statusBaseUrl,
  http.Client? httpClient,
  Duration timeout = const Duration(seconds: 30),
});
```

`statusBaseUrl` est facultatif ; sans valeur, le comportement de la phase 2 est inchangé (`https://pay.moneyfusion.net`). L'URL de vérification est résolue en relatif : `statusBaseUrl.resolve('paiementNotif/{token}')`, avec le token encodé comme aujourd'hui. Une base contenant un chemin doit donc se terminer par `/`. Le champ est public, comme `backendUrl`.

Motif : le `checkStatus` était figé sur MoneyFusion, ce qui interdisait toute démonstration locale du statut. L'injection reste une extension sans rupture ; la vérification du statut par défaut est déjà couverte par les tests de la phase 2.

### App `example/` minimale

Générée avec `flutter create --template=app --project-name money_fusion_example --platforms=android example`, dépendance `money_fusion: {path: ../}`. Un seul écran, dans un `StatefulWidget` :

- champs montant (défaut `200`), téléphone (défaut `01010101`), nom (défaut `John Doe`) ;
- bouton « Payer » désactivé pendant l'appel ;
- appel `MoneyFusion.pay(context, request, client: client)` ;
- affichage du résultat : statut et détails pour `PaymentCompleted`, message pour `PaymentError`, texte pour `PaymentCancelled` ;
- client créé dans `initState` et fermé dans `dispose`.

Configuration locale, centralisée en constantes : `backendUrl` = `http://10.0.2.2:8090/payments`, `statusBaseUrl` = `http://10.0.2.2:8090`, `returnUrl` = `http://10.0.2.2:8090/callback`. `10.0.2.2` est l'alias de la machine hôte vu depuis l'émulateur Android ; le README le précise.

Android : `android.permission.INTERNET` et `android:usesCleartextTraffic="true"` dans le manifeste principal de l'exemple, sans quoi la WebView et le client HTTP refusent le HTTP local.

### Faux backend autonome

`example/fake_backend/server.dart`, exécuté avec `dart run example/fake_backend/server.dart`, écoute sur `0.0.0.0:8090` :

- `POST /payments` : valide la présence de `totalPrice`, `article`, `numeroSend`, `nomclient`, `return_url` ; sinon `{statut: false, message: ...}` avec HTTP 200. Sinon crée un token `demo-<n>`, mémorise montant et `return_url`, renvoie `{statut: true, token, message, url: "http://10.0.2.2:8090/pay/<token>"}`.
- `GET /pay/<token>` : page HTML avec le montant, « Payer » et « Annuler ».
- `GET /pay/<token>/finish?result=paid|failure` : met à jour le statut, puis renvoie une page HTML qui navigue vers le `return_url` mémorisé par `location.replace(...)`, avec le token en query.
- `GET /paiementNotif/<token>` : `{statut: true, data: {Montant, frais, statut, moyen, numeroTransaction}}` avec le statut courant (`pending` par défaut, puis `paid` ou `failure`).
- `GET /callback` : page de repli « Retour à l'app » (navigation normalement interceptée avant requête).

La navigation de retour est déclenchée par JavaScript, pas par une redirection HTTP 302 : la détection des redirections serveur reste le point à vérifier sur appareil consigné en phase 2. Le token et le montant suffisent ; aucun webhook.

### Vérification Android

Android Studio est installé (SDK, licences, émulateur), un appareil virtuel est créé, le faux backend est lancé dans un terminal et l'app dans un autre (`cd example && flutter run`). Scénarios manuels :

1. « Payer » → `PaymentCompleted` avec `paid` et les détails ;
2. « Annuler » → `PaymentCompleted` avec `failure` ;
3. croix de fermeture → `PaymentCancelled` ;
4. backend arrêté → `PaymentError` de type réseau à la création.

Le cas `pending` n'est pas produit par le faux backend ; il reste couvert par les tests unitaires.

### Version `0.3.0`

Version mineure : ajout de `statusBaseUrl` et de l'exemple, sans rupture. `version` du pubspec, `moneyFusionVersion` et entrée `0.3.0` du CHANGELOG passent ensemble.

## Context

Les phases 2 et 3 ont livré le parcours et son API de haut niveau, mais tout est vérifié par des tests sans appareil. Cette phase installe la toolchain Android (reportée depuis la phase 1), ajoute la seule extension d'API nécessaire pour rendre le parcours local possible, et fait tourner la démo réelle. Les comportements WebView laissés ouverts en phase 2 (retour par navigation JavaScript, erreurs de sous-ressource) sont observés à cette occasion.

Rappels inchangés : aucun secret dans le package ni dans l'exemple, la création passe par le backend, le webhook reste la source de vérité (non simulé ici).

## Stakeholder Notes

- **Développeurs des apps** : disposent d'un exemple exécutable et d'un client utilisable contre un backend de test grâce à `statusBaseUrl`.
- **Équipe backend** : aucun changement de contrat ; le faux backend n'est qu'un outil de démonstration.
- **Relecteurs** : la vérification Android est manuelle et documentée ; iOS reste non vérifié.
