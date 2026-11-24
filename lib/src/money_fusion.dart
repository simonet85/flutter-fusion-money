import 'package:material_ui/material_ui.dart';

import 'checkout/money_fusion_checkout.dart';
import 'client/money_fusion_client.dart';
import 'exceptions.dart';
import 'models/payment_request.dart';
import 'models/payment_result.dart';
import 'models/payment_session.dart';

/// API de haut niveau du parcours de paiement.
abstract final class MoneyFusion {
  /// Crée le paiement, ouvre le checkout et renvoie un résultat non nul.
  ///
  /// Toute [MoneyFusionException] levée par la création est renvoyée dans
  /// [PaymentError] : l'appelant n'a rien à intercepter autour de cet appel.
  /// Si la route de checkout se ferme sans résultat, [PaymentCancelled] est
  /// renvoyé.
  static Future<PaymentResult> pay(
    BuildContext context,
    PaymentRequest request, {
    required MoneyFusionClient client,
  }) async {
    final PaymentSession session;
    try {
      session = await client.createPayment(request);
    } on MoneyFusionException catch (error) {
      return PaymentError(error);
    }
    if (!context.mounted) {
      return const PaymentCancelled();
    }
    final result = await Navigator.of(context).push<PaymentResult>(
      MaterialPageRoute(
        builder: (_) => MoneyFusionCheckout(
          client: client,
          session: session,
          returnUrl: request.returnUrl,
        ),
      ),
    );
    return result ?? const PaymentCancelled();
  }
}
