/// Paiements MoneyFusion (PAYIN) pour nos apps Flutter.
library;

export 'src/checkout/checkout_flow.dart';
export 'src/checkout/money_fusion_checkout.dart';
export 'src/checkout/return_url.dart';
export 'src/client/money_fusion_client.dart';
export 'src/exceptions.dart';
export 'src/models/payment_details.dart';
export 'src/money_fusion.dart';
export 'src/models/payment_request.dart';
export 'src/models/payment_result.dart';
export 'src/models/payment_session.dart';
export 'src/models/payment_status.dart';
export 'src/models/payment_status_report.dart';

/// Version du package, à garder alignée sur `version` dans `pubspec.yaml`.
const String moneyFusionVersion = '0.3.0';
