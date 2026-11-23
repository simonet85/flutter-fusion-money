# Roadmap

Les phases sont volontairement petites : chacune est une tranche livrable, relisible et testable indépendamment.

---

## Phase 1 — Hello package
- Installer le SDK Flutter sur le poste
- `flutter create --template=package money_fusion` dans ce dossier
- `flutter analyze` et `flutter test` passent sur le squelette

## Phase 2 — Modèles
- `PaymentRequest` (montant, articles, téléphone, nom client, infos personnelles, `return_url`, `webhook_url`) avec `toJson()` aux noms exacts MoneyFusion
- `PaymentSession` (`token`, `url`, `message`) avec `fromJson()`
- Tests de sérialisation à partir des exemples JSON de la doc

## Phase 3 — Statut de paiement
- Type fermé `PaymentStatus` : `pending`, `paid`, `failure`, `noPaid`
- `PaymentDetails` (montant, frais, moyen, numéro de transaction) lu depuis `data`
- Conversion tolérante : statut inconnu → erreur explicite, pas `pending` silencieux

## Phase 4 — Client HTTP
- `MoneyFusionClient.checkStatus(token)` sur `paiementNotif/{token}`
- `MoneyFusionClient.createPayment(request)` via l'endpoint backend configurable
- Erreurs typées (réseau, HTTP non 2xx, `statut: false`, JSON inattendu), testées avec `MockClient`

## Phase 5 — Écran de paiement
- Widget `MoneyFusionCheckout` : ouvre `session.url` dans `webview_flutter`
- Interception de `return_url`, puis `checkStatus` et retour du `PaymentStatus` à l'appelant
- Fermeture par l'utilisateur → résultat « annulé » distinct d'un échec

## Phase 6 — API de haut niveau
- Une fonction unique type `MoneyFusion.pay(context, request)` qui enchaîne création, écran et statut
- Doc du package (README, dartdoc) et contrat de l'endpoint backend pour l'équipe serveur

## Phase 7 — App d'exemple
- `example/` avec un faux backend configurable
- Vérification manuelle sur émulateur Android et simulateur iOS

---

Plus tard (non planifié) : retraits PAYOUT côté backend, réception des webhooks, mode navigateur externe, publication pub.dev.
