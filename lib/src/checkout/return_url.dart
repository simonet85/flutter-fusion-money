/// Indique si [navigation] correspond au retour vers [returnUrl].
///
/// Seuls le schéma, l'hôte et le chemin sont comparés ; query et fragment
/// sont ignorés car MoneyFusion peut y ajouter ses propres paramètres.
bool matchesReturnUrl(Uri navigation, Uri returnUrl) {
  return navigation.scheme == returnUrl.scheme &&
      navigation.host == returnUrl.host &&
      navigation.path == returnUrl.path;
}
