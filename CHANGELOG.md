## 0.3.0

* `MoneyFusionClient.statusBaseUrl` facultatif pour vérifier le statut contre un
  backend de test ; app d'exemple Android avec faux backend local.

## 0.2.0

* API de haut niveau `MoneyFusion.pay` : création, checkout et résultat non nul
  en un seul appel ; les erreurs de création sont renvoyées dans `PaymentError`.

## 0.1.0

* Parcours de paiement de bout en bout : modèles MoneyFusion, client HTTP
  (création via le backend, vérification du statut), widget de checkout WebView,
  résultat scellé et erreurs typées.

## 0.0.1

* Squelette du package (phase 1) : analyse stricte, `publish_to: none`, test de fumée.
