# Phase 3 Plan — API de haut niveau

## Group 1 — API `MoneyFusion.pay`

1. Créer `lib/src/money_fusion.dart` : classe `MoneyFusion` avec `static Future<PaymentResult> pay(BuildContext context, PaymentRequest request, {required MoneyFusionClient client})`
2. Enchaînement : `client.createPayment(request)` → `PaymentError(error)` sur `MoneyFusionException` ; sinon `Navigator.of(context).push<PaymentResult>` d'un `MaterialPageRoute` vers `MoneyFusionCheckout(client, session, returnUrl: request.returnUrl)`
3. Normalisation : `result ?? const PaymentCancelled()` ; dartdoc sur la classe et la méthode
4. Exporter `src/money_fusion.dart` depuis `lib/money_fusion.dart`, sans autre changement d'API

## Group 2 — Tests

5. Test de `pay` avec un `MockClient` en échec de création (`statut: false`, réseau, HTTP non 2xx, JSON invalide) : `PaymentError` portant l'erreur typée, aucune exception levée, aucune navigation tentée
6. Vérifier que le chemin nominal (création réussie puis checkout) n'est pas testé en widget : la WebView n'existe pas en test ; la vérification sur appareil reste en phase 4

## Group 3 — Documentation et version

7. README : parcours principal avec `MoneyFusion.pay` et `switch` à trois cas ; sous-section « API de bas niveau » reprenant `createPayment` + `MoneyFusionCheckout` avec `case null` ; contrat backend inchangé
8. `CHANGELOG.md` : entrée `0.2.0` ; bump `version` du pubspec et `moneyFusionVersion`
9. `flutter analyze`, `flutter test`, `dart format --output=none --set-exit-if-changed .` : tout vert ; consigner les résultats dans `validation.md`

## Group 4 — Livraison de la branche

10. Commiter la spec puis l'implémentation sur `feature/api-de-haut-niveau` ; ne pas fusionner avant la relecture de la phase
