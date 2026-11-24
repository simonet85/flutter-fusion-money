# money_fusion

Package Flutter interne pour encaisser des paiements MoneyFusion (PAYIN) depuis nos applications mobiles.

## Contexte (entrées)

- Documentation MoneyFusion : https://docs.moneyfusion.net/fr (pages lues : aperçu, `/webapi`, `/payout`, `/php`, `/python`, `/dotnet`).
- MoneyFusion n'expose que du HTTP et une page de paiement web : aucun SDK natif à encapsuler.
- Le « lien API » du tableau de bord est le seul secret du PAYIN, et l'IP de l'appelant doit être enregistrée dans le tableau de bord. La création de paiement passe donc obligatoirement par **notre backend** ; l'app ne détient jamais le lien API.
- Décisions prises : package **interne** (pas de publication pub.dev), page de paiement en **WebView intégrée**, client **`package:http`**, périmètre **PAYIN côté app uniquement**.

## Prérequis

- Flutter **3.50.1** (canal stable), Dart **3.14.0**, installé depuis l'archive officielle dans `C:\dev\flutter` (`C:\dev\flutter\bin` dans le PATH utilisateur).
- Ne pas changer de version de SDK sans le décider dans une spec de phase.
- Toolchain Android requise pour l'app d'exemple (Android Studio, SDK, émulateur). iOS n'est pas vérifié : pas de Mac sur le poste.

## Commandes

```
flutter pub get
flutter analyze
flutter test
dart format --output=none --set-exit-if-changed .
```

## Utilisation

```dart
final client = MoneyFusionClient(
  backendUrl: Uri.parse('https://api.notre-backend.example/payments'),
);

final result = await MoneyFusion.pay(
  context,
  PaymentRequest(
    totalPrice: 200,
    articles: [
      {'sac': 100, 'chaussure': 100},
    ],
    numeroSend: '01010101',
    nomclient: 'John Doe',
    returnUrl: Uri.parse('https://app.notre-service.example/callback'),
  ),
  client: client,
);

switch (result) {
  case PaymentCompleted(:final status, :final details):
    // status : pending, paid, failure ou noPaid
  case PaymentCancelled():
    // l'utilisateur a fermé la page de paiement
  case PaymentError(:final error):
    // erreur de création, réseau, HTTP ou format de réponse
}
```

`MoneyFusion.pay` enchaîne création, checkout et vérification : le résultat est
toujours non nul et aucune exception n'est levée. Appelez `client.close()` quand
vous n'utilisez plus le client. Le statut renvoyé sert à l'affichage : la source
de vérité reste le webhook reçu par le backend.

### API de bas niveau

Pour contrôler la navigation vous-même, utilisez le client et le widget
directement :

```dart
final session = await client.createPayment(request);

final result = await Navigator.of(context).push<PaymentResult>(
  MaterialPageRoute(
    builder: (_) => MoneyFusionCheckout(
      client: client,
      session: session,
      returnUrl: request.returnUrl,
    ),
  ),
);

switch (result) {
  case PaymentCompleted(:final status, :final details):
    // status et détails de la transaction
  case PaymentCancelled():
    // fermeture par l'utilisateur
  case PaymentError(:final error):
    // erreur vérifiée par le checkout
  case null:
    // route fermée sans résultat
}
```

## Exemple

`example/` est une app Android minimale branchée sur un faux backend local.
Deux terminaux :

```sh
# Terminal 1, depuis la racine du dépôt
dart run example/fake_backend/server.dart

# Terminal 2
cd example
flutter run
```

L'app cible `http://10.0.2.2:8090`, alias de la machine hôte vu depuis
l'émulateur Android. Le manifeste de l'exemple autorise le HTTP en clair et
l'accès Internet pour ce backend local. Le faux backend propose « Payer »
(statut `paid`) et « Annuler » (statut `failure`) ; la croix de fermeture du
checkout renvoie `PaymentCancelled`.

## Contrat backend

Le package envoie le corps MoneyFusion brut à `backendUrl`, en `POST`, avec
`Content-Type: application/json` :

```json
{
  "totalPrice": 200,
  "article": [{"sac": 100, "chaussure": 100}],
  "personal_Info": [{"userId": 1, "orderId": 123}],
  "numeroSend": "01010101",
  "nomclient": "John Doe",
  "return_url": "https://app.notre-service.example/callback",
  "webhook_url": "https://api.notre-backend.example/hooks/moneyfusion"
}
```

`article` et `personal_Info` sont des objets libres (`Array<Object>` dans la
doc) : le package ne les interprète pas. Le backend ajoute le lien API
(secret, IP enregistrée) et relaie la réponse MoneyFusion brute :

```json
{
  "statut": true,
  "token": "xxxxxxxx",
  "message": "paiement en cours",
  "url": "https://payin.moneyfusion.net/payment/xxxxxxxx/Marchand"
}
```

Si `statut` vaut `false`, le package lève `PaymentCreationException`. Le lien
API et la clé PAYOUT ne doivent jamais quitter le backend.

Statuts de `data.statut` sur `paiementNotif/{token}` : `pending`, `paid`,
`failure`, `no paid` (exposé en Dart comme `PaymentStatus.noPaid`). Toute
autre valeur lève `UnknownPaymentStatusException`.

## Constitution

- [specs/mission.md](specs/mission.md)
- [specs/tech-stack.md](specs/tech-stack.md)
- [specs/roadmap.md](specs/roadmap.md)
