import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:money_fusion/money_fusion.dart';

const String paidStatusJson =
    '{"statut":true,"data":{"Montant":200,"frais":5,"statut":"paid",'
    '"moyen":"orange","numeroTransaction":"t1"},'
    '"message":"details paiement"}';

void main() {
  final backendUrl = Uri.parse('https://api.example.com/payments');
  final returnUrl = Uri.parse('https://app.example/callback');

  group('matchesReturnUrl', () {
    test('ignore la query et le fragment', () {
      expect(
        matchesReturnUrl(
          Uri.parse('https://app.example/callback?token=abc#ok'),
          returnUrl,
        ),
        isTrue,
      );
    });

    test('refuse un autre hôte', () {
      expect(
        matchesReturnUrl(Uri.parse('https://evil.example/callback'), returnUrl),
        isFalse,
      );
    });

    test('refuse un chemin seulement préfixé', () {
      expect(
        matchesReturnUrl(
          Uri.parse('https://app.example/callback/extra'),
          returnUrl,
        ),
        isFalse,
      );
    });
  });

  group('CheckoutFlow', () {
    test("ne vérifie le statut qu'une fois", () async {
      var calls = 0;
      final client = MoneyFusionClient(
        backendUrl: backendUrl,
        httpClient: MockClient((_) async {
          calls++;
          return http.Response(
            paidStatusJson,
            200,
            headers: const {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      final flow = CheckoutFlow(client: client, returnUrl: returnUrl);

      final first = flow.handleReturn('tok123');
      final second = flow.handleReturn('tok123');
      final results = await Future.wait([first, second]);

      expect(calls, 1);
      final completed = results.first as PaymentCompleted;
      expect(completed.status, PaymentStatus.paid);
      expect(completed.details?.transactionNumber, 't1');
    });

    test('transforme une erreur du client en PaymentError', () async {
      final client = MoneyFusionClient(
        backendUrl: backendUrl,
        httpClient: MockClient((_) async => http.Response('boom', 500)),
      );
      final flow = CheckoutFlow(client: client, returnUrl: returnUrl);

      final result = await flow.handleReturn('tok123');

      final error = (result as PaymentError).error;
      expect(error, isA<MoneyFusionHttpException>());
    });

    test("annule sans appeler le réseau", () {
      var calls = 0;
      final client = MoneyFusionClient(
        backendUrl: backendUrl,
        httpClient: MockClient((_) async {
          calls++;
          return http.Response(paidStatusJson, 200);
        }),
      );
      final flow = CheckoutFlow(client: client, returnUrl: returnUrl);

      final result = flow.cancel();

      expect(result, isA<PaymentCancelled>());
      expect(calls, 0);
    });
  });
}
