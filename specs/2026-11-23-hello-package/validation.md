# Phase 1 Validation — Hello package

## Definition of Done

Tout ce qui suit doit être vrai avant de fusionner `feature/hello-package` dans `main`.

### 1. Le SDK est installé et sur le PATH

```
flutter --version
```

Dans un nouveau terminal, doit afficher un canal `stable`. La version affichée correspond à celle notée dans le `README.md`.

### 2. L'analyse est propre

```
flutter analyze
```

Doit afficher `No issues found!` et sortir avec le code 0.

### 3. Les tests passent

```
flutter test
```

Doit sortir avec le code 0, au moins un test exécuté.

### 4. Le formatage est respecté

```
dart format --output=none --set-exit-if-changed .
```

Doit sortir avec le code 0.

### 5. L'analyse stricte est active

`analysis_options.yaml` inclut `package:flutter_lints/flutter.yaml` et contient `strict-casts: true`, `strict-inference: true` et `strict-raw-types: true`.

### 6. Le package est interne

`pubspec.yaml` contient `name: money_fusion` et `publish_to: none`, et aucune entrée dans `dependencies` hormis `flutter`.

### 7. Le template est nettoyé

Aucune occurrence de `Calculator` dans `lib/` ni `test/`.

### 8. La constitution est intacte

`specs/mission.md`, `specs/tech-stack.md` et `specs/roadmap.md` sont inchangés par rapport à `main` ; le `README.md` est complété, pas remplacé.

## Not Required

- `flutter doctor` entièrement vert : seules les sections Android/iOS peuvent être en erreur
- Aucun émulateur ni appareil
- Aucune CI
