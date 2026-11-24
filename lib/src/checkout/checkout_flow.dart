import '../client/money_fusion_client.dart';
import '../exceptions.dart';
import '../models/payment_result.dart';
import 'return_url.dart';

/// Logique du checkout, indépendante de la WebView pour rester testable.
class CheckoutFlow {
  CheckoutFlow({required this.client, required this.returnUrl});

  /// Client utilisé pour vérifier le statut.
  final MoneyFusionClient client;

  /// URL qui marque la fin du paiement dans la WebView.
  final Uri returnUrl;

  Future<PaymentResult>? _pending;

  /// Vrai si la navigation correspond au `return_url` attendu.
  bool isReturnUrl(Uri navigation) => matchesReturnUrl(navigation, returnUrl);

  /// Vérifie le statut une seule fois, même si plusieurs retours arrivent.
  Future<PaymentResult> handleReturn(String token) {
    final pending = _pending;
    if (pending != null) {
      return pending;
    }
    final future = _check(token);
    _pending = future;
    return future;
  }

  /// Résultat d'une fermeture par l'utilisateur.
  PaymentCancelled cancel() => const PaymentCancelled();

  Future<PaymentResult> _check(String token) async {
    try {
      final report = await client.checkStatus(token);
      return PaymentCompleted(status: report.status, details: report.details);
    } on MoneyFusionException catch (error) {
      return PaymentError(error);
    }
  }
}
