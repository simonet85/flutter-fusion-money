import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../exceptions.dart';
import '../models/payment_request.dart';
import '../models/payment_session.dart';
import '../models/payment_status.dart';
import '../models/payment_status_report.dart';
import '../models/payment_details.dart';

/// Client HTTP du parcours de paiement MoneyFusion.
///
/// La création passe par notre backend (le lien API ne quitte jamais le
/// serveur) ; la vérification de statut interroge MoneyFusion directement.
class MoneyFusionClient {
  MoneyFusionClient({
    required this.backendUrl,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 30),
  }) : _httpClient = httpClient ?? http.Client(),
       _ownsClient = httpClient == null;

  /// Endpoint backend qui relaie la création vers MoneyFusion.
  final Uri backendUrl;

  final http.Client _httpClient;
  final bool _ownsClient;

  /// Délai maximal appliqué à chaque requête.
  final Duration timeout;

  /// Crée une session de paiement via l'endpoint backend.
  Future<PaymentSession> createPayment(PaymentRequest request) async {
    final response = await _send(
      () => _httpClient.post(
        backendUrl,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ),
    );
    _ensureSuccess(response);
    final json = _decodeObject(response.body);
    if (json['statut'] == false) {
      final message = json['message'];
      throw PaymentCreationException(
        message is String && message.isNotEmpty
            ? message
            : 'Création refusée par MoneyFusion.',
      );
    }
    return PaymentSession.fromJson(json);
  }

  /// Vérifie le statut d'un paiement auprès de MoneyFusion.
  Future<PaymentStatusReport> checkStatus(String token) async {
    if (token.isEmpty) {
      throw ArgumentError.value(
        token,
        'token',
        'Le token de paiement est vide.',
      );
    }
    final url = Uri.parse(
      'https://pay.moneyfusion.net/paiementNotif/${Uri.encodeComponent(token)}',
    );
    final response = await _send(() => _httpClient.get(url));
    _ensureSuccess(response);
    final json = _decodeObject(response.body);
    if (json['statut'] == false) {
      final message = json['message'];
      throw PaymentStatusException(
        message is String && message.isNotEmpty
            ? message
            : 'Statut de paiement indisponible.',
      );
    }
    final data = json['data'];
    if (data is! Map<String, Object?>) {
      throw const MoneyFusionFormatException(
        'Champ "data" manquant ou invalide.',
      );
    }
    return PaymentStatusReport(
      status: PaymentStatus.fromRaw(data['statut']),
      details: PaymentDetails.fromJson(data),
    );
  }

  /// Ferme le client HTTP lorsque le package l'a créé.
  void close() {
    if (_ownsClient) {
      _httpClient.close();
    }
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(timeout);
    } on TimeoutException catch (error) {
      throw MoneyFusionNetworkException(
        'Délai dépassé (${timeout.inSeconds} s).',
        cause: error,
      );
    } on http.ClientException catch (error) {
      throw MoneyFusionNetworkException(
        'Erreur réseau : ${error.message}',
        cause: error,
      );
    }
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MoneyFusionHttpException(response.statusCode, response.body);
    }
  }

  Map<String, Object?> _decodeObject(String body) {
    final Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException catch (error) {
      throw MoneyFusionFormatException('JSON illisible : ${error.message}');
    }
    if (decoded is! Map<String, Object?>) {
      throw const MoneyFusionFormatException('Objet JSON attendu.');
    }
    return decoded;
  }
}
