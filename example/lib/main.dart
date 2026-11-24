import 'package:material_ui/material_ui.dart';
import 'package:money_fusion/money_fusion.dart';

const String _backendUrl = 'http://10.0.2.2:8090/payments';
const String _statusBaseUrl = 'http://10.0.2.2:8090';
const String _returnUrl = 'http://10.0.2.2:8090/callback';

void main() {
  runApp(const MoneyFusionExampleApp());
}

class MoneyFusionExampleApp extends StatelessWidget {
  const MoneyFusionExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'money_fusion exemple',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const PaymentScreen(),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _amount = TextEditingController(text: '200');
  final TextEditingController _phone = TextEditingController(text: '01010101');
  final TextEditingController _name = TextEditingController(text: 'John Doe');
  late final MoneyFusionClient _client;
  String? _result;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _client = MoneyFusionClient(
      backendUrl: Uri.parse(_backendUrl),
      statusBaseUrl: Uri.parse(_statusBaseUrl),
    );
  }

  @override
  void dispose() {
    _client.close();
    _amount.dispose();
    _phone.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final amount = num.tryParse(_amount.text);
    if (amount == null) {
      setState(() => _result = 'Montant invalide.');
      return;
    }
    setState(() {
      _busy = true;
      _result = null;
    });
    final result = await MoneyFusion.pay(
      context,
      PaymentRequest(
        totalPrice: amount,
        articles: [
          {'paiement': amount},
        ],
        numeroSend: _phone.text,
        nomclient: _name.text,
        returnUrl: Uri.parse(_returnUrl),
      ),
      client: _client,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      _result = _describe(result);
    });
  }

  String _describe(PaymentResult result) {
    switch (result) {
      case PaymentCompleted(:final status, :final details):
        final lines = <String>['Statut : ${status.name}'];
        if (details != null) {
          final amount = details.amount;
          if (amount != null) {
            lines.add('Montant : $amount');
          }
          final fees = details.fees;
          if (fees != null) {
            lines.add('Frais : $fees');
          }
          final method = details.method;
          if (method != null) {
            lines.add('Moyen : $method');
          }
          final transaction = details.transactionNumber;
          if (transaction != null) {
            lines.add('Transaction : $transaction');
          }
        }
        return lines.join('\n');
      case PaymentCancelled():
        return 'Paiement annulé.';
      case PaymentError(:final error):
        return 'Erreur : ${error.message}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('money_fusion exemple')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Faux backend attendu sur 10.0.2.2:8090. Android uniquement.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amount,
            enabled: !_busy,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Montant (XAF)'),
          ),
          TextField(
            controller: _phone,
            enabled: !_busy,
            decoration: const InputDecoration(labelText: 'Téléphone'),
          ),
          TextField(
            controller: _name,
            enabled: !_busy,
            decoration: const InputDecoration(labelText: 'Nom du client'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _pay,
            child: Text(_busy ? 'Paiement en cours…' : 'Payer'),
          ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            Text(_result!, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ],
      ),
    );
  }
}
