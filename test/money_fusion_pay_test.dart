import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_fusion/money_fusion.dart';

void main() {
  late BuildContext context;

  Future<void> pumpContext(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  PaymentRequest buildRequest() => PaymentRequest(
    totalPrice: 200,
    articles: const [
      {'sac': 100, 'chaussure': 100},
    ],
    numeroSend: '01010101',
    nomclient: 'John Doe',
    returnUrl: Uri.parse('https://app.notre-service.example/callback'),
  );

  MoneyFusionClient buildClient(
    Future<http.Response> Function(http.Request) handler,
  ) {
    return MoneyFusionClient(
      backendUrl: Uri.parse('https://api.notre-backend.example/payments'),
      httpClient: MockClient(handler),
    );
  }

  testWidgets('pay renvoie PaymentError quand la création est refusée', (
    tester,
  ) async {
    await pumpContext(tester);
    final client = buildClient(
      (_) async =>
          http.Response('{"statut":false,"message":"Montant invalide"}', 200),
    );

    final result = await MoneyFusion.pay(
      context,
      buildRequest(),
      client: client,
    );

    expect(result, isA<PaymentError>());
    final error = (result as PaymentError).error;
    expect(error, isA<PaymentCreationException>());
    expect(error.message, 'Montant invalide');
    expect(find.byType(MoneyFusionCheckout), findsNothing);
  });

  testWidgets('pay renvoie PaymentError sur une coupure réseau', (
    tester,
  ) async {
    await pumpContext(tester);
    final client = buildClient(
      (_) async => throw http.ClientException('Coupure'),
    );

    final result = await MoneyFusion.pay(
      context,
      buildRequest(),
      client: client,
    );

    expect(result, isA<PaymentError>());
    expect((result as PaymentError).error, isA<MoneyFusionNetworkException>());
    expect(find.byType(MoneyFusionCheckout), findsNothing);
  });

  testWidgets('pay renvoie PaymentError sur un HTTP non 2xx', (tester) async {
    await pumpContext(tester);
    final client = buildClient((_) async => http.Response('Erreur', 500));

    final result = await MoneyFusion.pay(
      context,
      buildRequest(),
      client: client,
    );

    expect(result, isA<PaymentError>());
    final error = (result as PaymentError).error;
    expect(error, isA<MoneyFusionHttpException>());
    expect((error as MoneyFusionHttpException).statusCode, 500);
    expect(find.byType(MoneyFusionCheckout), findsNothing);
  });

  testWidgets('pay renvoie PaymentError sur un JSON invalide', (tester) async {
    await pumpContext(tester);
    final client = buildClient((_) async => http.Response('pas du JSON', 200));

    final result = await MoneyFusion.pay(
      context,
      buildRequest(),
      client: client,
    );

    expect(result, isA<PaymentError>());
    expect((result as PaymentError).error, isA<MoneyFusionFormatException>());
    expect(find.byType(MoneyFusionCheckout), findsNothing);
  });
}
