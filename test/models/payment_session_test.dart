import 'package:flutter_test/flutter_test.dart';
import 'package:money_fusion/money_fusion.dart';

void main() {
  group('PaymentSession.fromJson', () {
    test('lit la réponse de création de la doc', () {
      final session = PaymentSession.fromJson(const {
        'statut': true,
        'token': 'xxxxxxxx',
        'message': 'paiement en cours',
        'url': 'https://payin.moneyfusion.net/payment/xxxxxxxx/Marchand',
      });

      expect(session.token, 'xxxxxxxx');
      expect(session.message, 'paiement en cours');
      expect(
        session.url,
        Uri.parse('https://payin.moneyfusion.net/payment/xxxxxxxx/Marchand'),
      );
    });

    test('rejette un token manquant', () {
      expect(
        () => PaymentSession.fromJson(const {
          'url': 'https://payin.moneyfusion.net/payment/x',
        }),
        throwsA(isA<MoneyFusionFormatException>()),
      );
    });

    test('rejette une url manquante', () {
      expect(
        () => PaymentSession.fromJson(const {'token': 'abc'}),
        throwsA(isA<MoneyFusionFormatException>()),
      );
    });

    test('rejette une url invalide', () {
      expect(
        () =>
            PaymentSession.fromJson(const {'token': 'abc', 'url': 'http://['}),
        throwsA(isA<MoneyFusionFormatException>()),
      );
    });
  });
}
