# Phase 2 Plan — Paiement de bout en bout

## Group 1 — Dépendances et structure

1. Ajouter `http` et `webview_flutter` aux `dependencies` (contraintes `^1.0.0` et `^4.0.0` compatibles Dart 3.14), sans autre dépendance
2. `flutter pub get` ; noter les versions résolues
3. Créer `lib/src/models/`, `lib/src/client/`, `lib/src/checkout/` ; n'exporter que l'API publique depuis `lib/money_fusion.dart`

## Group 2 — Erreurs typées

4. Définir une hiérarchie scellée `MoneyFusionException` : réseau, HTTP non 2xx, format/JSON, création refusée, statut indisponible, statut inconnu
5. Chaque sous-type porte les données utiles (code HTTP, valeur brute) et un `toString` lisible

## Group 3 — Modèles et sérialisation

6. `PaymentRequest` : `totalPrice` (`num`), `articles` (`List<Map<String, Object?>>` → clé `article`), `numeroSend`, `nomclient`, `personalInfo` (facultatif → `personal_Info`), `returnUrl` (requis → `return_url`), `webhookUrl` (facultatif → `webhook_url`) ; `toJson()` aux noms exacts
7. `PaymentSession` : `token`, `url` (`Uri`), `message` ; `fromJson()` avec validation et `MoneyFusionFormatException`
8. `PaymentStatus` : enum `pending`/`paid`/`failure`/`noPaid` et parsing normalisé (cf. requirements) ; `PaymentDetails` tolérant depuis `data`
9. `PaymentResult` scellé : `PaymentCompleted`, `PaymentCancelled`, `PaymentError`
10. Fixtures JSON recopiées de la doc ; tests de sérialisation (clés exactes, absence de `callback_url`), de `fromJson`, des quatre statuts, de `"no paid"` et du statut inconnu

## Group 4 — Client HTTP

11. `MoneyFusionClient` : `backendUrl` requis, `http.Client` injectable, timeout 30 s, `close()` si le client est possédé
12. `createPayment(PaymentRequest)` : `POST backendUrl`, corps `toJson()`, `Content-Type: application/json` ; `statut: false` → `PaymentCreationException` ; validations de réponse
13. `checkStatus(String token)` : `GET https://pay.moneyfusion.net/paiementNotif/{token}` ; `statut` de tête, `data.statut` → `PaymentStatus`, `data` → `PaymentDetails`
14. Tests avec `MockClient` : succès création/statut, 500, erreur réseau, timeout, JSON invalide, `statut: false`, `token`/`url` manquants

## Group 5 — Checkout

15. `matchesReturnUrl(Uri navigation, Uri returnUrl)` pure : égalité scheme/host/path, query et fragment ignorés ; tests des cas négatifs (host différent, chemin préfixe, sous-chemin)
16. `CheckoutFlow` : traite une navigation, déclenche un unique `checkStatus`, produit un `PaymentResult` ; compteur d'appels vérifié en test
17. Widget `MoneyFusionCheckout` : `WebViewController`, `NavigationDelegate` branché sur le flow, indicateur de chargement, erreurs de chargement → `PaymentError`, bouton de fermeture et retour système → `PaymentCancelled` (`PopScope`)

## Group 6 — Livraison

18. README : section « Utilisation » (client, widget) et section « Contrat backend » avec les JSON exacts et les statuts
19. `CHANGELOG.md` : entrée `0.1.0` ; bump `version` du pubspec et `moneyFusionVersion`
20. `flutter analyze`, `flutter test`, `dart format --output=none --set-exit-if-changed .` : tout vert
