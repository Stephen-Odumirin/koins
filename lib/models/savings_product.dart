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
}
