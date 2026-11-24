import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../client/money_fusion_client.dart';
import '../exceptions.dart';
import '../models/payment_result.dart';
import '../models/payment_session.dart';
import 'checkout_flow.dart';

/// Page de paiement MoneyFusion dans une WebView.
///
/// Poussez-la avec `Navigator.push<PaymentResult>` : elle se ferme en
/// renvoyant un [PaymentCompleted], [PaymentCancelled] ou [PaymentError].
class MoneyFusionCheckout extends StatefulWidget {
  const MoneyFusionCheckout({
    super.key,
    required this.client,
    required this.session,
    required this.returnUrl,
  });

  /// Client utilisé pour vérifier le statut après le retour.
  final MoneyFusionClient client;

  /// Session créée par le backend.
  final PaymentSession session;

  /// URL qui marque la fin du paiement dans la WebView.
  final Uri returnUrl;

  @override
  State<MoneyFusionCheckout> createState() => _MoneyFusionCheckoutState();
}

class _MoneyFusionCheckoutState extends State<MoneyFusionCheckout> {
  late final CheckoutFlow _flow;
  late final WebViewController _controller;
  bool _loading = true;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _flow = CheckoutFlow(client: widget.client, returnUrl: widget.returnUrl);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _onNavigationRequest,
          onPageStarted: (_) => _setLoading(true),
          onPageFinished: (_) => _setLoading(false),
          onWebResourceError: _onWebResourceError,
        ),
      )
      ..loadRequest(widget.session.url);
  }

  void _setLoading(bool value) {
    if (!mounted || _loading == value) {
      return;
    }
    setState(() => _loading = value);
  }

  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri != null && _flow.isReturnUrl(uri)) {
      unawaited(_finishWith(_flow.handleReturn(widget.session.token)));
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  void _onWebResourceError(WebResourceError error) {
    if (error.isForMainFrame ?? true) {
      unawaited(
        _finishWith(
          Future<PaymentResult>.value(
            PaymentError(
              MoneyFusionNetworkException(
                'Chargement de la page impossible : ${error.description}',
              ),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _finishWith(Future<PaymentResult> result) async {
    if (_finishing) {
      return;
    }
    _finishing = true;
    final value = await result;
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(value);
  }

  void _cancel() {
    if (_finishing) {
      return;
    }
    _finishing = true;
    Navigator.of(context).pop(_flow.cancel());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _cancel();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Paiement'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Fermer',
            onPressed: _cancel,
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading) const LinearProgressIndicator(minHeight: 2),
          ],
        ),
      ),
    );
  }
}
