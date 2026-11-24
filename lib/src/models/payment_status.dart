import '../exceptions.dart';

/// Statut d'un paiement MoneyFusion.
enum PaymentStatus {
  /// Paiement en cours de traitement.
  pending,

  /// Paiement réussi.
  paid,

  /// Échec du paiement.
  failure,

  /// Paiement non effectué (`no paid` dans la doc).
  noPaid;

  /// Interprète la valeur brute de `data.statut`.
  ///
  /// Toute valeur inconnue lève [UnknownPaymentStatusException] plutôt que
  /// d'être devinée.
  static PaymentStatus fromRaw(Object? raw) {
    if (raw is String) {
      return switch (raw.trim().toLowerCase()) {
        'pending' => PaymentStatus.pending,
        'paid' => PaymentStatus.paid,
        'failure' => PaymentStatus.failure,
        'no paid' => PaymentStatus.noPaid,
        _ => throw UnknownPaymentStatusException(raw),
      };
    }
    throw UnknownPaymentStatusException(raw?.toString() ?? 'null');
  }
}
