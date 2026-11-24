import 'payment_details.dart';
import 'payment_status.dart';

/// Résultat d'une vérification de statut.
class PaymentStatusReport {
  const PaymentStatusReport({required this.status, this.details});

  /// Statut fermé du paiement.
  final PaymentStatus status;

  /// Détails de la transaction, si présents.
  final PaymentDetails? details;
}
