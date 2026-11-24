import 'dart:convert';
import 'dart:io';

const int _port = 8090;
const String _emulatorBase = 'http://10.0.2.2:8090';

final Map<String, _Payment> _payments = <String, _Payment>{};
int _counter = 0;

class _Payment {
  _Payment({
    required this.token,
    required this.amount,
    required this.returnUrl,
  });

  final String token;
  final num amount;
  final String returnUrl;
  String status = 'pending';

  String get method => 'orange';

  String get transactionNumber => 'demo-txn-$token';
}

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, _port);
  stdout.writeln(
    'Faux backend MoneyFusion sur http://localhost:$_port '
    '(émulateur Android : $_emulatorBase)',
  );
  await for (final request in server) {
    try {
      await _handle(request);
    } catch (error) {
      stderr.writeln('Erreur : $error');
      request.response.statusCode = HttpStatus.internalServerError;
      await request.response.close();
    }
  }
}

Future<void> _handle(HttpRequest request) async {
  final segments = request.uri.pathSegments;
  if (request.method == 'POST' && request.uri.path == '/payments') {
    await _createPayment(request);
  } else if (request.method == 'GET' &&
      segments.length == 2 &&
      segments[0] == 'pay') {
    await _paymentPage(request.response, segments[1]);
  } else if (request.method == 'GET' &&
      segments.length == 3 &&
      segments[0] == 'pay' &&
      segments[2] == 'finish') {
    await _finish(request, segments[1]);
  } else if (request.method == 'GET' &&
      segments.length == 2 &&
      segments[0] == 'paiementNotif') {
    await _status(request.response, segments[1]);
  } else if (request.method == 'GET' && request.uri.path == '/callback') {
    await _html(
      request.response,
      'Retour à l’app',
      '<h1>Retour à l’app</h1>'
          '<p>Cette page est normalement interceptée par le checkout.</p>',
    );
  } else {
    request.response.statusCode = HttpStatus.notFound;
    await request.response.close();
  }
}

Future<void> _createPayment(HttpRequest request) async {
  final body = await utf8.decoder.bind(request).join();
  Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException {
    await _json(request.response, {
      'statut': false,
      'message': 'Corps JSON illisible.',
    });
    return;
  }
  if (decoded is! Map<String, Object?>) {
    await _json(request.response, {
      'statut': false,
      'message': 'Objet JSON attendu.',
    });
    return;
  }

  final rawAmount = decoded['totalPrice'];
  final rawReturnUrl = decoded['return_url'];
  final num? amount = rawAmount is num ? rawAmount : null;
  final String? returnUrl = rawReturnUrl is String && rawReturnUrl.isNotEmpty
      ? rawReturnUrl
      : null;
  final errors = <String>[
    if (amount == null) 'totalPrice',
    if (decoded['article'] is! List<Object?>) 'article',
    if (decoded['numeroSend'] is! String) 'numeroSend',
    if (decoded['nomclient'] is! String) 'nomclient',
    if (returnUrl == null) 'return_url',
  ];
  if (amount == null || returnUrl == null || errors.isNotEmpty) {
    await _json(request.response, {
      'statut': false,
      'message': 'Champs manquants ou invalides : ${errors.join(', ')}',
    });
    return;
  }

  _counter++;
  final token = 'demo-$_counter';
  _payments[token] = _Payment(
    token: token,
    amount: amount,
    returnUrl: returnUrl,
  );
  stdout.writeln('Création $token : $amount pour $returnUrl');

  await _json(request.response, {
    'statut': true,
    'token': token,
    'message': 'paiement en cours',
    'url': '$_emulatorBase/pay/$token',
  });
}

Future<void> _paymentPage(HttpResponse response, String token) async {
  final payment = _payments[token];
  if (payment == null) {
    response.statusCode = HttpStatus.notFound;
    await _html(response, 'Paiement inconnu', '<h1>Paiement inconnu</h1>');
    return;
  }

  await _html(response, 'Paiement de démonstration', '''
<h1>Paiement de démonstration</h1>
<p>Montant : ${payment.amount} XAF</p>
<p>
  <a href="/pay/$token/finish?result=paid">Payer</a>
  &nbsp;|&nbsp;
  <a href="/pay/$token/finish?result=failure">Annuler</a>
</p>
''');
}

Future<void> _finish(HttpRequest request, String token) async {
  final payment = _payments[token];
  if (payment == null) {
    request.response.statusCode = HttpStatus.notFound;
    await _html(
      request.response,
      'Paiement inconnu',
      '<h1>Paiement inconnu</h1>',
    );
    return;
  }

  final paid = request.uri.queryParameters['result'] == 'paid';
  payment.status = paid ? 'paid' : 'failure';
  stdout.writeln('Statut $token : ${payment.status}');

  final returnUrl = Uri.parse(payment.returnUrl)
      .replace(queryParameters: {'token': token, 'result': payment.status});
  await _html(request.response, 'Retour à l’app', '''
<h1>${paid ? 'Paiement accepté' : 'Paiement annulé'}</h1>
<p>Retour vers l’application…</p>
<p><a href="$returnUrl">Continuer</a></p>
<script>location.replace(${jsonEncode(returnUrl.toString())});</script>
''');
}

Future<void> _status(HttpResponse response, String token) async {
  final payment = _payments[token];
  if (payment == null) {
    await _json(response, {'statut': false, 'message': 'Paiement inconnu.'});
    return;
  }

  await _json(response, {
    'statut': true,
    'message': 'ok',
    'data': {
      'Montant': payment.amount,
      'frais': 0,
      'statut': payment.status,
      'moyen': payment.method,
      'numeroTransaction': payment.transactionNumber,
    },
  });
}

Future<void> _json(HttpResponse response, Map<String, Object?> body) async {
  response.headers.contentType = ContentType.json;
  response.write(jsonEncode(body));
  await response.close();
}

Future<void> _html(HttpResponse response, String title, String body) async {
  response.headers.contentType = ContentType.html;
  response.write(
    '<!doctype html><html lang="fr"><head><meta charset="utf-8">'
    '<meta name="viewport" content="width=device-width, initial-scale=1">'
    '<title>$title</title></head><body>$body</body></html>',
  );
  await response.close();
}
