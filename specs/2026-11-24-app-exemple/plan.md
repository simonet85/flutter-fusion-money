# Phase 4 Plan — App d'exemple

## Group 1 — `statusBaseUrl`

1. Ajouter `statusBaseUrl` facultatif à `MoneyFusionClient` : champ public, défaut `https://pay.moneyfusion.net`, utilisé par `checkStatus` via `statusBaseUrl.resolve('paiementNotif/{token}')`
2. Test : base locale → `GET http://10.0.2.2:8080/paiementNotif/{token}` exact ; le test de la phase 2 sur l'URL par défaut reste vert
3. Bump `0.3.0` : pubspec, `moneyFusionVersion`, `CHANGELOG.md`

## Group 2 — App `example/`

4. Générer l'app : `flutter create --template=app --project-name money_fusion_example --platforms=android example`
5. Dépendance `money_fusion: {path: ../}` ; supprimer le code de compteur généré
6. Écran unique : champs montant/téléphone/nom, bouton « Payer », aperçu du `PaymentResult` ; client créé en `initState`, fermé en `dispose`
7. Constantes locales : `backendUrl`, `statusBaseUrl`, `returnUrl` sur `http://10.0.2.2:8080` ; manifeste Android : `INTERNET` + `usesCleartextTraffic`
8. `flutter analyze` dans `example/` : propre

## Group 3 — Faux backend

9. `example/fake_backend/server.dart` en `dart:io` : `POST /payments`, `GET /pay/<token>`, `GET /pay/<token>/finish`, `GET /paiementNotif/<token>`, `GET /callback`
10. État en mémoire par token (montant, `return_url`, statut, moyen, numéro de transaction) ; réponses MoneyFusion exactes ; statut par défaut `pending`
11. Page HTML minimale « Payer » / « Annuler » ; retour vers `return_url` par `location.replace`, pas par redirection 302
12. Vérifier le serveur à la main avec `curl` (création, statut, finish) avant l'app

## Group 4 — Documentation

13. README : section « Exemple » (deux terminaux, `dart run example/fake_backend/server.dart`, `cd example && flutter run`), alias `10.0.2.2`, cleartext Android, iOS non vérifié
14. README prérequis : toolchain Android requise à partir de cette phase ; version du SDK inchangée
15. `specs/tech-stack.md` : mentionner Android Studio + émulateur comme outil de vérification, `statusBaseUrl` comme point d'extension

## Group 5 — Vérification et livraison

16. Installer Android Studio, le SDK et un appareil virtuel ; accepter les licences
17. Exécuter les quatre scénarios manuels du requirements (paid, failure, annulation, backend arrêté) et noter les comportements WebView observés
18. `flutter analyze` et `flutter test` à la racine, `flutter analyze` dans `example/`, `dart format --output=none --set-exit-if-changed .` : tout vert ; consigner dans `validation.md`
19. Commiter la spec puis l'implémentation sur `feature/app-exemple` ; ne pas fusionner avant la relecture de la phase
