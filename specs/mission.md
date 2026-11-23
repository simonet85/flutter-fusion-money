# Mission

`money_fusion` existe pour qu'aucune de nos applications Flutter n'ait à réécrire, à sa manière et avec ses propres bugs, l'intégration du paiement MoneyFusion.

L'API MoneyFusion est simple, mais sa documentation comporte des pièges : noms de champs irréguliers (`numeroSend`, `nomclient`, `personal_Info`), statuts différents entre encaissement et retrait, `callback_url` évoqué alors que l'API attend `return_url`, webhooks envoyés en double. Le package encode une fois pour toutes la bonne lecture de cette documentation.

## Ce que fait le package

- Demander à **notre backend** de créer une session de paiement, et en récupérer `token` et `url`.
- Afficher la page de paiement MoneyFusion dans une WebView intégrée, détecter le retour vers `return_url`.
- Vérifier le statut d'un paiement (`GET https://pay.moneyfusion.net/paiementNotif/{token}`) et le traduire en type Dart fermé : `pending`, `paid`, `failure`, `noPaid`.
- Renvoyer à l'app appelante un résultat typé, sans qu'elle ait à connaître le JSON MoneyFusion.

## Ce que le package ne fait pas

- Il ne détient **jamais** le lien API MoneyFusion ni la clé privée de retrait : un téléphone n'a pas d'IP fixe et un binaire mobile se décompile.
- Il ne gère pas les retraits (PAYOUT), ni la réception des webhooks : c'est le rôle du backend.
- Il ne décide pas qu'une commande est payée : la source de vérité reste le webhook reçu par le backend. Le statut côté app sert à l'affichage.

## Pour qui

- **Les développeurs de nos applications Flutter**, qui veulent un écran de paiement en quelques lignes et un résultat fiable.
- **L'équipe backend**, qui doit connaître le contrat exact attendu par le package pour l'endpoint de création de paiement.

Le package est **interne** : consommé par dépendance git ou path, sans publication sur pub.dev. L'API publique peut évoluer librement tant que nos apps suivent.

## À quoi ressemble la réussite

Une app ajoute la dépendance, fournit l'URL de son endpoint backend, appelle un seul écran de paiement et reçoit un `PaymentStatus`. Aucune chaîne `"no paid"` ni aucun champ `nomclient` n'apparaît dans le code de l'app.
