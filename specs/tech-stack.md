# Tech Stack

`money_fusion` est un **package Flutter pur** : du Dart uniquement, sans code Kotlin/Swift ni `MethodChannel`. MoneyFusion n'offre aucun SDK natif ; tout passe par HTTP et une page web.

## Cœur

| Couche | Choix | Justification |
|---|---|---|
| Langage | Dart 3 | Types scellés et `switch` exhaustifs pour les statuts |
| Type de projet | `flutter create --template=package` | Pas de code natif à écrire, donc pas de template `plugin` |
| Client HTTP | **`package:http`** | Officiel, léger, `MockClient` intégré pour les tests |
| Page de paiement | **`webview_flutter`** | Paiement dans l'app ; `NavigationDelegate` intercepte `return_url` |
| Widgets Material | **`material_ui`** | Depuis Flutter 3.47, `flutter/material` est déprécié au profit de ce paquet officiel |
| Plateformes | Android, iOS | Seules plateformes supportées par `webview_flutter` |

## Contrat avec MoneyFusion (lu dans la doc)

- Création (appelée **par le backend**, pas par le package) : `POST <lien API>` avec `totalPrice`, `article` (tableau), `numeroSend`, `nomclient`, `personal_Info` (tableau, facultatif), `return_url`, `webhook_url`. Réponse : `statut`, `token`, `message`, `url`.
- Statut (appelable par le package) : `GET https://pay.moneyfusion.net/paiementNotif/{token}`. Réponse : `statut`, `message`, `data` (dont `data.statut` ∈ `pending` | `paid` | `failure` | `no paid`, `Montant`, `frais`, `moyen`, `numeroTransaction`).

## Contrat avec notre backend

- Le package appelle un endpoint backend configurable, qui relaie la création vers MoneyFusion et renvoie `token` et `url`.
- Le format de cet endpoint est fixé par la spec de la phase concernée et documenté pour l'équipe backend.

## Tests

- `flutter_test` pour les tests unitaires et de widgets.
- `MockClient` de `package:http/testing.dart` pour simuler MoneyFusion et le backend : aucun appel réseau réel dans les tests.

## Outillage

- `flutter_lints` pour l'analyse statique (`flutter analyze` sans avertissement).
- `dart format`.
- Une app `example/` pour la vérification manuelle sur appareil.
- Prérequis poste : SDK Flutter 3.50.1 (Dart 3.14.0) installé dans `C:\dev\flutter`, `C:\dev\flutter\bin` dans le PATH utilisateur ; version exacte notée dans le README.

## Ce que nous n'utilisons pas

- Pas de `dio` : `package:http` suffit et impose moins de dépendances à nos apps.
- Pas de code natif ni de `MethodChannel`.
- Pas de `url_launcher` ni de deep links : la WebView suffit pour Android/iOS.
- Pas de gestion d'état imposée (Provider, Riverpod, Bloc) : le package renvoie des `Future`, l'app choisit.
- Pas de stockage du lien API ni de la clé PAYOUT, sous aucune forme.
