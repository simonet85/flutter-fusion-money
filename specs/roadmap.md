# Roadmap

Les phases sont volontairement ciblées : chacune est une tranche livrable, relisible et testable indépendamment.

---

## Phase 1 — Hello package — terminée (2026-11-23)
- Installer le SDK Flutter sur le poste
- `flutter create --template=package money_fusion` dans ce dossier
- `flutter analyze` et `flutter test` passent sur le squelette

## Phase 2 — Paiement de bout en bout — terminée (2026-11-24)
- `PaymentRequest` (montant, articles, téléphone, nom client, infos personnelles, `return_url`, `webhook_url`) avec `toJson()` aux noms exacts MoneyFusion
- `PaymentSession` (`token`, `url`, `message`) avec `fromJson()`
- Tests de sérialisation à partir des exemples JSON de la doc
- Type fermé `PaymentStatus` : `pending`, `paid`, `failure`, `noPaid`
- `PaymentDetails` (montant, frais, moyen, numéro de transaction) lu depuis `data`
- Conversion tolérante : statut inconnu → erreur explicite, pas `pending` silencieux
- `MoneyFusionClient.createPayment(request)` via l'endpoint backend configurable
- `MoneyFusionClient.checkStatus(token)` sur `paiementNotif/{token}`
- Erreurs typées (réseau, HTTP non 2xx, `statut: false`, JSON inattendu), testées avec `MockClient`
- Widget `MoneyFusionCheckout` : ouvre `session.url` dans `webview_flutter`
- Interception de `return_url`, puis `checkStatus` et retour du `PaymentStatus` à l'appelant
- Fermeture par l'utilisateur → résultat « annulé » distinct d'un échec

## Phase 3 — API de haut niveau — terminée (2026-11-24)
- Une fonction unique type `MoneyFusion.pay(context, request)` qui enchaîne création, écran et statut
- Doc du package (README, dartdoc) et contrat de l'endpoint backend pour l'équipe serveur

## Phase 4 — App d'exemple — terminée (2026-11-25)
- `MoneyFusionClient.statusBaseUrl` facultatif pour vérifier le statut contre un backend de test
- `example/` avec un faux backend configurable
- Vérification manuelle sur émulateur Android ; iOS non vérifié (pas de Mac)

---

Plus tard (non planifié) : retraits PAYOUT côté backend, réception des webhooks, mode navigateur externe, publication pub.dev.
