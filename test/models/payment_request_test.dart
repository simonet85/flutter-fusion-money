import 'package:flutter_test/flutter_test.dart';
import 'package:money_fusion/money_fusion.dart';

void main() {
  group('PaymentRequest.toJson', () {
    test('utilise les noms exacts de la doc', () {
      final request = PaymentRequest(
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
        webhookUrl: Uri.parse('https://backend.example/hooks/moneyfusion'),
      );

      final json = request.toJson();

      expect(json, {
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
        'webhook_url': 'https://backend.example/hooks/moneyfusion',
      });
      expect(json.containsKey('callback_url'), isFalse);
    });

    test('omet personal_Info et webhook_url quand ils sont absents', () {
      final json = PaymentRequest(
        totalPrice: 200,
        articles: [
          {'sac': 100},
        ],
        numeroSend: '01010101',
        nomclient: 'John Doe',
        returnUrl: Uri.parse('https://app.example/callback'),
      ).toJson();

      expect(json.containsKey('personal_Info'), isFalse);
      expect(json.containsKey('webhook_url'), isFalse);
      expect(json['return_url'], 'https://app.example/callback');
    });
  });
}
