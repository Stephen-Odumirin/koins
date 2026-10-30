class SavingsProduct {
  final String id;

  /// The stable catalogue key, stored on saved plans. Not shown to the user:
  /// the UI reads the localized name through `AppLocalizations.productName`.
  final String name;
  final double interestRate; // percent, e.g. 12
  final int? durationMonths; // null means flexible
  final int minDeposit;

  const SavingsProduct({
    required this.id,
    required this.name,
    required this.interestRate,
    required this.durationMonths,
    required this.minDeposit,
  });

  // Equal by id, so a product passed in through a route still matches the
  // instance in a dropdown's item list.
  @override
  bool operator ==(Object other) => other is SavingsProduct && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
