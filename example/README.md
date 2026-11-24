# money_fusion_example

Démo Android du package `money_fusion` avec un faux backend local. Aucun
paiement réel n'est effectué.

## Lancement

```sh
# Terminal 1, depuis la racine du dépôt
dart run example/fake_backend/server.dart

# Terminal 2
cd example
flutter run
```

L'app cible `10.0.2.2:8090`, alias de la machine hôte vu depuis l'émulateur
Android. Le manifeste autorise le HTTP en clair pour ce faux backend.

Voir le [README principal](../README.md) pour le contrat backend et l'API.
