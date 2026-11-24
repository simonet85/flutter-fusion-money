import 'package:flutter_test/flutter_test.dart';
import 'package:money_fusion/money_fusion.dart';

void main() {
  group('PaymentStatus.fromRaw', () {
    test('mappe les valeurs de la doc', () {
      expect(PaymentStatus.fromRaw('pending'), PaymentStatus.pending);
      expect(PaymentStatus.fromRaw('paid'), PaymentStatus.paid);
      expect(PaymentStatus.fromRaw('failure'), PaymentStatus.failure);
      expect(PaymentStatus.fromRaw('no paid'), PaymentStatus.noPaid);
    });

    test('tolère espaces et majuscules', () {
      expect(PaymentStatus.fromRaw(' PAID '), PaymentStatus.paid);
    });

    test('refuse une valeur inconnue plutôt que de la deviner', () {
      expect(
        () => PaymentStatus.fromRaw('rembourse'),
        throwsA(
          isA<UnknownPaymentStatusException>().having(
            (e) => e.rawStatus,
            'rawStatus',
            'rembourse',
          ),
        ),
      );
    });
  });

  group('PaymentDetails.fromJson', () {
    test('lit les champs de la doc', () {
      final details = PaymentDetails.fromJson(const {
        'Montant': 200,
        'frais': 5,
        'moyen': 'orange',
        'numeroTransaction': '0101010101',
      });

      expect(details.amount, 200);
      expect(details.fees, 5);
      expect(details.method, 'orange');
      expect(details.transactionNumber, '0101010101');
    });

    test('laisse null les champs absents', () {
      final details = PaymentDetails.fromJson(const {});

      expect(details.amount, isNull);
      expect(details.fees, isNull);
      expect(details.method, isNull);
      expect(details.transactionNumber, isNull);
    });
  });
}
