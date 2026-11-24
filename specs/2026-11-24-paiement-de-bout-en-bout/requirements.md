# Phase 2 Requirements — Paiement de bout en bout

## Scope

Livrer le parcours complet côté app, de la requête typée au résultat affichable :

- Modèles `PaymentRequest`, `PaymentSession`, `PaymentStatus`, `PaymentDetails`, et le résultat `PaymentResult`.
- Client HTTP `MoneyFusionClient` : création via notre backend, vérification du statut via MoneyFusion.
- Widget `MoneyFusionCheckout` : page de paiement en WebView, détection du retour, statut renvoyé à l'appelant.
- Erreurs typées, documentation du contrat backend, tests.

## Out of Scope

- Retraits (PAYOUT), réception des webhooks : backend uniquement.
- Polling du statut : un seul check après le retour (cf. Decisions).
- API de haut niveau `MoneyFusion.pay` : phase 3.
- App `example/`, émulateur, simulateur, vérification sur appareil : phase 4.
- Retries, détection de connectivité, thème ou localisation du widget, CI.

## Decisions

### Contrat backend : relais brut

Le package envoie à notre endpoint backend le corps de création MoneyFusion tel quel, en `POST`, `Content-Type: application/json` :

```json
{
  "totalPrice": 200,
  "article": [{"sac": 100, "chaussure": 100}],
  "personal_Info": [{"userId": 1, "orderId": 123}],
  "numeroSend": "01010101",
  "nomclient": "John Doe",
  "return_url": "https://notre-app.example/callback",
  "webhook_url": "https://notre-backend.example/hooks/moneyfusion"
}
```

Le backend ajoute le lien API (secret, IP enregistrée) et relaie vers MoneyFusion. Il renvoie la réponse MoneyFusion brute :

```json
{
  "statut": true,
  "token": "xxxxxxxx",
  "message": "paiement en cours",
  "url": "https://payin.moneyfusion.net/payment/xxxxxxxx/Marchand"
}
```

- `statut: false` → `PaymentCreationException(message)`.
- HTTP non 2xx → `MoneyFusionHttpException`.
- Corps illisible, `token` ou `url` absents → `MoneyFusionFormatException`.
- `return_url` (jamais `callback_url`) et `webhook_url` gardent leurs noms exacts.

### Champs libres `article` et `personal_Info`

La doc déclare `article` (exigé) et `personal_Info` (facultatif) comme `Array<Object>` : des objets à clés libres, non interprétés par MoneyFusion. Le package les type en `List<Map<String, Object?>>`, les sérialise sans transformation et ne leur impose aucune structure métier.

### Montants

`totalPrice`, `Montant` et `frais` sont typés `num` pour rester fidèles au `Number` de la doc ; en XAF les valeurs sont entières en pratique. Aucun arrondi ni conversion de devise dans le package.

### Client configurable et injectable

`MoneyFusionClient({required Uri backendUrl, http.Client? httpClient, Duration timeout = const Duration(seconds: 30)})`. Le client HTTP est injectable (`MockClient` en test) ; sans injection, le client est créé et fermé par `close()`. Pas de configuration globale ni statique. Le timeout s'applique à chaque appel.

### Un seul check après le retour

Après l'interception de `return_url`, un unique `GET paiementNotif/{token}`. `pending` est renvoyé tel quel à l'app, qui décide de revérifier. Le webhook reçu par le backend reste la source de vérité.

### Résultat scellé à trois cas

```dart
sealed class PaymentResult {}
final class PaymentCompleted extends PaymentResult { PaymentStatus status; PaymentDetails? details; }
final class PaymentCancelled extends PaymentResult {}
final class PaymentError extends PaymentResult { MoneyFusionException error; }
```

`PaymentCompleted` signifie « parcours terminé » et peut porter `pending` ; `PaymentCancelled` couvre la fermeture par l'utilisateur (bouton ou retour système) et reste distinct d'un échec. Les erreurs de transport ou de format ne sont ni un statut MoneyFusion ni une annulation : `PaymentError` les porte pour que l'app fasse un `switch` exhaustif et n'ait rien à intercepter autour de `Navigator.push`.

### Détection du retour

`MoneyFusionCheckout({required MoneyFusionClient client, required PaymentSession session, required Uri returnUrl})`. Une navigation est reconnue comme retour si `scheme`, `host` et `path` sont égaux à `returnUrl` ; query et fragment sont ignorés. La navigation est bloquée (`NavigationDecision.prevent`) puis le statut est demandé. `returnUrl` est requis dans `PaymentRequest` (MoneyFusion le marque facultatif, notre parcours en dépend) ; `webhookUrl` reste facultatif.

### Normalisation des statuts

Valeur brute de `data.statut` : `trim` puis minuscules. `pending`, `paid`, `failure` sont mappés tels quels ; `no paid` devient `PaymentStatus.noPaid`. Toute autre valeur lève `UnknownPaymentStatusException` avec la valeur brute — jamais de `pending` silencieux. Un `statut` de tête à `false` lève `PaymentStatusException`. `PaymentDetails` lit `Montant`, `frais`, `moyen`, `numeroTransaction` de façon tolérante (champs absents → `null`).

### Documentation et version

La doc lue le 2026-11-24 est `https://docs.moneyfusion.net/fr/webapi` (création, statut, statuts, webhooks). Le contrat backend est documenté dans le README pour l'équipe serveur. La phase livre la version `0.1.0` : `version` du pubspec, constante `moneyFusionVersion` et `CHANGELOG.md` alignés.

## Context

Cette phase est la première qui touche MoneyFusion. Les pièges de la doc sont encodés une fois pour toutes : `numeroSend`, `nomclient`, `personal_Info`, `return_url` vs `callback_url`, `statut` booléen de tête vs `data.statut` textuel, et l'espace dans `no paid`. Aucun secret (lien API, clé PAYOUT) n'entre dans le package.

## Stakeholder Notes

- **Développeurs des apps** : après cette phase, ils créent une session via leur backend, affichent `MoneyFusionCheckout` et reçoivent un `PaymentResult` scellé.
- **Équipe backend** : le contrat est figé dans le README ; le backend relaie la création et renvoie la réponse MoneyFusion brute.
