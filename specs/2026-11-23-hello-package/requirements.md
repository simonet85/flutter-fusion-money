# Phase 1 Requirements — Hello package

## Scope

Installer le SDK Flutter sur le poste, générer le squelette du package `money_fusion` dans ce dossier et prouver que la boucle de développement fonctionne : `flutter analyze` et `flutter test` passent, avec une analyse statique stricte dès le premier commit.

## Out of Scope

- Aucun modèle MoneyFusion (`PaymentRequest`, `PaymentSession`) : phase 2
- Aucune dépendance `http` ni `webview_flutter` : phase 2
- Pas de toolchain Android/iOS (Android Studio, SDK Android, émulateur, Xcode) : repoussée à la phase 4
- Pas d'app `example/` : phase 4
- Pas de CI

## Decisions

### Dépôt git dédié
`FlutterFusionMoney` est son propre dépôt git (branche `main` avec la constitution, branche `feature/hello-package` pour cette phase), à l'image des modules imbriqués de `Projets`. Il ne dépend pas de l'état du dépôt racine.

### SDK Flutter par zip officiel stable
Archive stable téléchargée depuis flutter.dev, décompressée dans `C:\dev\flutter`, `C:\dev\flutter\bin` ajouté au PATH **utilisateur**. Pas de FVM. La version exacte installée (Flutter et Dart) est notée dans le README pour que les phases suivantes ne changent pas de version sans le décider.

### Template `package`, nom `money_fusion`
`flutter create --template=package --project-name money_fusion .` : package Dart pur, pas de template `plugin` (aucun code natif, cf. tech-stack). Le nom du dossier (`FlutterFusionMoney`) n'est pas un nom de package Dart valide, d'où `--project-name`.

### Package interne
`publish_to: none` dans `pubspec.yaml` : empêche une publication accidentelle sur pub.dev (cf. mission).

### Analyse statique stricte
`analysis_options.yaml` inclut `package:flutter_lints/flutter.yaml` et active :

```yaml
analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
```

Non négociable dès le premier commit : le package parsera du JSON (`dynamic`) dès la phase 2, et ces modes empêchent les casts implicites silencieux.

### Code d'exemple du template supprimé
La classe `Calculator` générée est remplacée par une bibliothèque minimale `lib/money_fusion.dart` (doc de bibliothèque) et un unique test de fumée, juste assez pour que `flutter test` ait quelque chose à exécuter.

Ajusté pendant l'implémentation : une bibliothèque vide rend l'import du test inutilisé (`unused_import`), ce qui casse `flutter analyze`. La bibliothèque expose donc une seule constante `moneyFusionVersion`, et le test de fumée vérifie qu'elle est égale au champ `version` de `pubspec.yaml`.

## Context

Cette phase sert uniquement à prouver la base : le SDK est là, le package se génère, l'analyse stricte est en place et les tests tournent. Rien de MoneyFusion n'est encore codé.

`flutter create` ne réécrit pas les fichiers existants : le `README.md` et `specs/` de la constitution doivent rester intacts ; le README est complété (prérequis, version du SDK), pas remplacé.

## Stakeholder Notes

- **Développeurs des apps** : rien de visible encore ; la phase garantit qu'ils récupéreront un package qui s'analyse sans avertissement.
- **Équipe backend** : non concernée par cette phase.
