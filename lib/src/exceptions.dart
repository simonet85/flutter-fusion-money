/// Erreurs publiques levées par le package.
sealed class MoneyFusionException implements Exception {
  const MoneyFusionException(this.message);

  /// Message lisible décrivant l'erreur.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Panne réseau ou délai dépassé.
final class MoneyFusionNetworkException extends MoneyFusionException {
  const MoneyFusionNetworkException(super.message, {this.cause});

  /// Exception d'origine, si disponible.
  final Object? cause;
}

/// Réponse HTTP dont le code n'est pas 2xx.
final class MoneyFusionHttpException extends MoneyFusionException {
  const MoneyFusionHttpException(this.statusCode, this.body)
    : super('Réponse HTTP inattendue');

  /// Code HTTP renvoyé.
  final int statusCode;

  /// Corps de la réponse, pour diagnostic.
  final String body;

  @override
  String toString() => 'MoneyFusionHttpException: HTTP $statusCode — $body';
}

/// Corps JSON absent, illisible ou de forme inattendue.
final class MoneyFusionFormatException extends MoneyFusionException {
  const MoneyFusionFormatException(super.message);
}

/// Création refusée par MoneyFusion (`statut: false`).
final class PaymentCreationException extends MoneyFusionException {
  const PaymentCreationException(super.message);
}

/// Statut de paiement indisponible (`statut: false` sur `paiementNotif`).
final class PaymentStatusException extends MoneyFusionException {
  const PaymentStatusException(super.message);
}

/// `data.statut` contient une valeur que le package ne connaît pas.
final class UnknownPaymentStatusException extends MoneyFusionException {
  UnknownPaymentStatusException(this.rawStatus)
    : super('Statut de paiement inconnu : "$rawStatus"');

  /// Valeur brute reçue, conservée pour le diagnostic.
  final String rawStatus;
}
