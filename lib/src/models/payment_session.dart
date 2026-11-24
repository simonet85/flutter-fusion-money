import '../exceptions.dart';

/// Session de paiement créée par le backend.
class PaymentSession {
  const PaymentSession({
    required this.token,
    required this.url,
    required this.message,
  });

  /// Lit la réponse de création MoneyFusion.
  factory PaymentSession.fromJson(Map<String, Object?> json) {
    final token = json['token'];
    if (token is! String || token.isEmpty) {
      throw const MoneyFusionFormatException(
        'Champ "token" manquant ou invalide.',
      );
    }
    final rawUrl = json['url'];
    final url = rawUrl is String ? Uri.tryParse(rawUrl) : null;
    if (url == null || !url.hasScheme || url.host.isEmpty) {
      throw const MoneyFusionFormatException(
        'Champ "url" manquant ou invalide.',
      );
    }
    final message = json['message'];
    return PaymentSession(
      token: token,
      url: url,
      message: message is String ? message : '',
    );
  }

  /// Jeton de paiement, utilisé pour vérifier le statut.
  final String token;

  /// URL de la page de paiement MoneyFusion.
  final Uri url;

  /// Message de MoneyFusion, éventuellement vide.
  final String message;
}
