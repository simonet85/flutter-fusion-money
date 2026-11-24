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
- Toolchain Android/iOS non requise avant la phase 4 (vérification sur appareil de l'app d'exemple).

## Commandes

```
flutter pub get
flutter analyze
flutter test
dart format --output=none --set-exit-if-changed .
```

## Constitution

- [specs/mission.md](specs/mission.md)
- [specs/tech-stack.md](specs/tech-stack.md)
- [specs/roadmap.md](specs/roadmap.md)
