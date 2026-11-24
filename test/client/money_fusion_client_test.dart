import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:money_fusion/money_fusion.dart';

const String creationResponseJson =
    '{"statut":true,"token":"xxxxxxxx","message":"paiement en cours",'
    '"url":"https://payin.moneyfusion.net/payment/xxxxxxxx/Marchand"}';

const String statusResponseJson =
    '{"statut":true,"data":{"Montant":200,"frais":5,"statut":"paid",'
    '"moyen":"orange","numeroTransaction":"0101010101"},'
    '"message":"details paiement"}';

void main() {
  final backendUrl = Uri.parse('https://api.example.com/payments');

  PaymentRequest buildRequest() => PaymentRequest(
    totalPrice: 200,
    articles: [
      {'sac': 100, 'chaussure': 100},
    ],
    numeroSend: '01010101',
    nomclient: 'John Doe',
    personalInfo: [
      {'userId': 1, 'orderId': 123},
    ],
    returnUrl: Uri.parse('https://app.example/callback'),
  );

  MoneyFusionClient clientReturning(String body, {int statusCode = 200}) {
    return MoneyFusionClient(
      backendUrl: backendUrl,
      httpClient: MockClient(
        (_) async => http.Response(
          body,
          statusCode,
          headers: const {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );
  }

  group('createPayment', () {
    test("envoie le corps brut à l'endpoint backend", () async {
      late http.Request captured;
      final client = MoneyFusionClient(
        backendUrl: backendUrl,
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response(
            creationResponseJson,
            200,
            headers: const {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );

      final session = await client.createPayment(buildRequest());

      expect(captured.method, 'POST');
      expect(captured.url, backendUrl);
      expect(captured.headers['content-type'], contains('application/json'));
      expect(jsonDecode(captured.body), {
        'totalPrice': 200,
        'article': [
          {'sac': 100, 'chaussure': 100},
        ],
        'numeroSend': '01010101',
        'nomclient': 'John Doe',
        'personal_Info': [
          {'userId': 1, 'orderId': 123},
        ],
        'return_url': 'https://app.example/callback',
      });
      expect(session.token, 'xxxxxxxx');
      expect(
        session.url,
        Uri.parse('https://payin.moneyfusion.net/payment/xxxxxxxx/Marchand'),
      );
    });

    test('refuse une création statut:false avec le message MoneyFusion', () {
      final client = clientReturning(
        '{"statut":false,"message":"Numero invalide"}',
      );

      expect(
        client.createPayment(buildRequest()),
        throwsA(
          isA<PaymentCreationException>().having(
            (e) => e.message,
            'message',
            'Numero invalide',
          ),
        ),
      );
    });

    test('rejette une réponse sans token', () {
      final client = clientReturning(
        '{"statut":true,"message":"ok",'
        '"url":"https://payin.moneyfusion.net/payment/x"}',
      );

      expect(
        client.createPayment(buildRequest()),
        throwsA(isA<MoneyFusionFormatException>()),
      );
    });

    test('traduit un HTTP 500', () {
      final client = clientReturning('boom', statusCode: 500);

      expect(
        client.createPayment(buildRequest()),
        throwsA(
          isA<MoneyFusionHttpException>().having(
            (e) => e.statusCode,
            'statusCode',
            500,
          ),
        ),
      );
    });

    test('traduit une coupure réseau', () {
      final client = MoneyFusionClient(
        backendUrl: backendUrl,
        httpClient: MockClient(
          (_) async => throw http.ClientException('coupure'),
        ),
      );

      expect(
        client.createPayment(buildRequest()),
        throwsA(isA<MoneyFusionNetworkException>()),
      );
    });

    test('traduit un délai dépassé', () {
      final client = MoneyFusionClient(
        backendUrl: backendUrl,
        timeout: const Duration(milliseconds: 20),
        httpClient: MockClient((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return http.Response(creationResponseJson, 200);
        }),
      );

      expect(
        client.createPayment(buildRequest()),
        throwsA(isA<MoneyFusionNetworkException>()),
      );
    });

    test('traduit un JSON illisible', () {
      final client = clientReturning('pas du json');

      expect(
        client.createPayment(buildRequest()),
        throwsA(isA<MoneyFusionFormatException>()),
      );
    });
  });

  group('checkStatus', () {
    test('appelle paiementNotif et lit le statut', () async {
      late http.Request captured;
      final client = MoneyFusionClient(
        backendUrl: backendUrl,
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response(
            statusResponseJson,
            200,
            headers: const {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );

      final report = await client.checkStatus('tok123');

      expect(captured.method, 'GET');
      expect(
        captured.url.toString(),
        'https://pay.moneyfusion.net/paiementNotif/tok123',
      );
      expect(report.status, PaymentStatus.paid);
      expect(report.details?.amount, 200);
      expect(report.details?.fees, 5);
      expect(report.details?.method, 'orange');
      expect(report.details?.transactionNumber, '0101010101');
    });

    test('refuse un statut de tête à false', () {
      final client = clientReturning(
        '{"statut":false,"message":"Token inconnu"}',
      );

      expect(
        client.checkStatus('tok123'),
        throwsA(
          isA<PaymentStatusException>().having(
            (e) => e.message,
            'message',
            'Token inconnu',
          ),
        ),
      );
    });

    test('rejette une réponse sans data', () {
      final client = clientReturning('{"statut":true,"message":"ok"}');

      expect(
        client.checkStatus('tok123'),
        throwsA(isA<MoneyFusionFormatException>()),
      );
    });

    test('refuse un statut inconnu', () {
      final client = clientReturning(
        '{"statut":true,"data":{"statut":"refunded"},"message":"ok"}',
      );

      expect(
        client.checkStatus('tok123'),
        throwsA(isA<UnknownPaymentStatusException>()),
      );
    });

    test('traduit un HTTP 502', () {
      final client = clientReturning('bad gateway', statusCode: 502);

      expect(
        client.checkStatus('tok123'),
        throwsA(
          isA<MoneyFusionHttpException>().having(
            (e) => e.statusCode,
            'statusCode',
            502,
          ),
        ),
      );
    });
  });
}
