class SavingsProduct {
  final String id;
  final String name;
  final double interestRate; // percent, e.g. 12
  final int? durationMonths; // null means flexible
  final String description;
  final int minDeposit;

  const SavingsProduct({
    required this.id,
    required this.name,
    required this.interestRate,
    required this.durationMonths,
    required this.description,
    required this.minDeposit,
  });

  String get durationLabel =>
      durationMonths == null ? 'Flexible' : '$durationMonths Months';

  // Equal by id, so a product passed in through a route still matches the
  // instance in a dropdown's item list.
  @override
  bool operator ==(Object other) =>
      other is SavingsProduct && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
