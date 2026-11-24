import '../exceptions.dart';
import 'payment_details.dart';
import 'payment_status.dart';

/// Issue du parcours de paiement.
sealed class PaymentResult {
  const PaymentResult();
}

/// Parcours terminé : le statut MoneyFusion est porté par [status].
///
/// Le statut peut être `pending` : le webhook côté backend reste la source
/// de vérité.
final class PaymentCompleted extends PaymentResult {
  const PaymentCompleted({required this.status, this.details});

  /// Statut renvoyé par MoneyFusion.
  final PaymentStatus status;

  /// Détails de la transaction, si présents.
  final PaymentDetails? details;
}

/// L'utilisateur a fermé l'écran de paiement.
final class PaymentCancelled extends PaymentResult {
  const PaymentCancelled();
}

/// Le parcours a échoué hors statut MoneyFusion (réseau, HTTP, format).
final class PaymentError extends PaymentResult {
  const PaymentError(this.error);

  /// Erreur typée à présenter ou journaliser.
  final MoneyFusionException error;
}
