/// Requête de création de paiement, aux noms de champs MoneyFusion.
class PaymentRequest {
  PaymentRequest({
    required this.totalPrice,
    required this.articles,
    required this.numeroSend,
    required this.nomclient,
    this.personalInfo,
    required this.returnUrl,
    this.webhookUrl,
  });

  /// Montant total à payer (`totalPrice`), en XAF.
  final num totalPrice;

  /// Articles et prix, sérialisés tels quels sous `article`.
  final List<Map<String, Object?>> articles;

  /// Numéro de téléphone du client (`numeroSend`).
  final String numeroSend;

  /// Nom du client (`nomclient`).
  final String nomclient;

  /// Informations libres du client (`personal_Info`), facultatives.
  final List<Map<String, Object?>>? personalInfo;

  /// URL de retour de l'app (`return_url`), requise par notre parcours.
  final Uri returnUrl;

  /// URL de webhook côté backend (`webhook_url`), facultative.
  final Uri? webhookUrl;

  /// Convertit la requête au format exact attendu par MoneyFusion.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{
      'totalPrice': totalPrice,
      'article': articles,
      'numeroSend': numeroSend,
      'nomclient': nomclient,
      'return_url': returnUrl.toString(),
    };
    final info = personalInfo;
    if (info != null) {
      json['personal_Info'] = info;
    }
    final hook = webhookUrl;
    if (hook != null) {
      json['webhook_url'] = hook.toString();
    }
    return json;
  }
}
