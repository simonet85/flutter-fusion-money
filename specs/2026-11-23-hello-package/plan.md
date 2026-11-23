# Phase 1 Plan — Hello package

## Group 1 — SDK Flutter

1. Télécharger la dernière archive **stable** Windows depuis flutter.dev
2. La décompresser dans `C:\dev\flutter`
3. Ajouter `C:\dev\flutter\bin` au PATH utilisateur ; ouvrir un nouveau terminal
4. `flutter --version` : noter les versions exactes de Flutter et Dart
5. `flutter config --no-analytics` (facultatif) et `flutter doctor` : seule la section Flutter doit être verte, les autres sections sont ignorées pour cette phase

## Group 2 — Squelette du package

6. Dans ce dossier : `flutter create --template=package --project-name money_fusion .`
7. Vérifier que `README.md` et `specs/` n'ont pas été modifiés (`git diff --stat` ne doit montrer que des fichiers nouveaux)
8. Vérifier que le `.gitignore` généré exclut `.dart_tool/` et `build/`

## Group 3 — pubspec

9. `pubspec.yaml` : `name: money_fusion`, description en une ligne reprenant la mission, `publish_to: none`
10. Garder la contrainte `environment.sdk` générée (Dart 3) ; ne rien ajouter dans `dependencies`
11. `flutter pub get` sans erreur

## Group 4 — Analyse stricte

12. `analysis_options.yaml` : garder `include: package:flutter_lints/flutter.yaml`
13. Ajouter `strict-casts`, `strict-inference`, `strict-raw-types` sous `analyzer.language`

## Group 5 — Code minimal

14. Remplacer le contenu de `lib/money_fusion.dart` (classe `Calculator`) par une doc de bibliothèque `/// Paiements MoneyFusion (PAYIN) pour nos apps Flutter.`, une directive `library;` et une constante `moneyFusionVersion`
15. Remplacer `test/money_fusion_test.dart` par un test de fumée qui importe `package:money_fusion/money_fusion.dart` et vérifie que `moneyFusionVersion` égale la `version` du `pubspec.yaml`

## Group 6 — Documentation

16. Compléter le `README.md` : section « Prérequis » (Flutter stable, version exacte notée au point 4, chemin `C:\dev\flutter`) et commandes `flutter analyze` / `flutter test`
17. Mettre à jour `CHANGELOG.md` généré : entrée `0.0.1` « Squelette du package »

## Group 7 — Vérification

18. `flutter analyze` : `No issues found!`
19. `flutter test` : tous les tests passent
20. `dart format --output=none --set-exit-if-changed .` : code 0
