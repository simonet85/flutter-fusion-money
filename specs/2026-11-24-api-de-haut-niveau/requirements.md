# Phase 3 Requirements — API de haut niveau

## Scope

Réduire le parcours de paiement à un seul appel pour les apps :

- Classe `MoneyFusion` avec une méthode statique `pay(context, request, client:)` qui enchaîne création de session, écran de checkout et résultat.
- Résultat `PaymentResult` toujours non nul : plus de `case null` côté appelant.
- Erreurs de création ramenées dans `PaymentError` : aucun `try/catch` applicatif autour de `pay`.
- README recentré sur `pay`, avec l'API de bas niveau (`MoneyFusionClient`, `MoneyFusionCheckout`) conservée en complément.
- Version `0.2.0` : pubspec, `moneyFusionVersion` et `CHANGELOG.md` alignés.

## Out of Scope

- Modification du contrat backend ou des modèles et de la sérialisation : figés par la phase 2.
- Webhooks, PAYOUT, polling du statut : backend ou phases ultérieures.
- Personnalisation de la navigation (route, animation, plein écran), du thème ou de la localisation du checkout.
- Retries, détection de connectivité, gestion d'état de l'app.
- App `example/`, émulateur, simulateur, vérification sur appareil : phase 4.
- Nouvelles dépendances.
- CI.

## Decisions

### Signature

```dart
final class MoneyFusion {
  static Future<PaymentResult> pay(
    BuildContext context,
    PaymentRequest request, {
    required MoneyFusionClient client,
  });
}
```

Le client et son `backendUrl` sont fournis explicitement : aucun état global ni configuration statique, conformément à la décision de la phase 2. `returnUrl` est celui de `request` ; le widget et le flow de la phase 2 sont réutilisés tels quels.

### Erreurs de création dans `PaymentError`

`pay` entoure uniquement `client.createPayment(request)`. Toute `MoneyFusionException` (création refusée, réseau, HTTP non 2xx, format) est renvoyée dans `PaymentError` : `pay` ne lève jamais d'exception applicative et l'appelant fait un seul `switch` exhaustif sur `PaymentResult`. Les erreurs du checkout suivent le même chemin, déjà en place dans `PaymentCompleted`/`PaymentCancelled`/`PaymentError`.

### Résultat non nul

`Navigator.push<PaymentResult>` peut renvoyer `null` si la route est fermée sans résultat. `pay` normalise ce cas en `const PaymentCancelled()` : la signature est `Future<PaymentResult>`, et l'app n'a plus de cas `null` à traiter. Une annulation utilisateur produit déjà `PaymentCancelled` via le widget. Si le contexte n'est plus monté au retour de la création, `pay` renvoie également `PaymentCancelled` sans ouvrir de route (garde `use_build_context_synchronously`).

### Documentation

Le README présente `MoneyFusion.pay` comme parcours principal (client, requête, `switch` à trois cas). L'ancien parcours bas niveau (`createPayment` + `Navigator.push<MoneyFusionCheckout>`) reste documenté dans une sous-section, avec son `case null`. Le contrat backend de la phase 2 est inchangé. La méthode `pay` est documentée en dartdoc, comme le reste de l'API publique.

### Version `0.2.0`

Ajout d'API sans rupture : `version` du pubspec, constante `moneyFusionVersion` et entrée `0.2.0` du CHANGELOG passent ensemble. Le test de fumée de la phase 1 vérifie l'alignement.

## Context

La phase 2 a livré toutes les briques (client, modèles, widget, résultat scellé) mais impose à chaque app de répéter la création, le `push`, le `case null` et le `try/catch`. Cette phase ne change aucune de ces briques : elle ajoute une façade mince, testable sur ses chemins d'erreur, et recentre la documentation.

Les rappels du parcours restent valables : la création passe par notre backend, la vérification de statut est un unique appel après le retour, et le webhook reste la source de vérité. Aucun secret n'entre dans le package.

## Stakeholder Notes

- **Développeurs des apps** : un seul appel `MoneyFusion.pay(...)` et un `switch` à trois cas ; plus de gestion de route ni de `try/catch` pour le parcours nominal.
- **Équipe backend** : aucun changement ; le contrat documenté en phase 2 reste la référence.
