/// Détails d'une transaction, lus depuis `data`.
class PaymentDetails {
  const PaymentDetails({
    this.amount,
    this.fees,
    this.method,
    this.transactionNumber,
  });

  /// Lit `Montant`, `frais`, `moyen` et `numeroTransaction` de façon tolérante.
  factory PaymentDetails.fromJson(Map<String, Object?> json) {
    final amount = json['Montant'];
    final fees = json['frais'];
    final method = json['moyen'];
    final transaction = json['numeroTransaction'];
    return PaymentDetails(
      amount: amount is num ? amount : null,
      fees: fees is num ? fees : null,
      method: method is String ? method : null,
      transactionNumber: transaction is String ? transaction : null,
    );
  }

  /// Montant de la transaction (`Montant`).
  final num? amount;

  /// Frais de transaction (`frais`).
  final num? fees;

  /// Moyen de paiement (`moyen`), par exemple `orange`.
  final String? method;

  /// Numéro de transaction MoneyFusion (`numeroTransaction`).
  final String? transactionNumber;
}
