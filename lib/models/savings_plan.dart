class SavingsPlan {
  final String id;
  final String name;
  final String productType;
  final int targetAmount;
  final int monthlyContribution;
  final int durationMonths;
  final DateTime createdAt;
  final int savedAmount;

  const SavingsPlan({
    required this.id,
    required this.name,
    required this.productType,
    required this.targetAmount,
    required this.monthlyContribution,
    required this.durationMonths,
    required this.createdAt,
    this.savedAmount = 0,
  });

  factory SavingsPlan.fromJson(Map<String, dynamic> json) => SavingsPlan(
    id: json['id'] as String,
    name: json['name'] as String,
    productType: json['productType'] as String,
    targetAmount: json['targetAmount'] as int,
    monthlyContribution: json['monthlyContribution'] as int,
    durationMonths: json['durationMonths'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
    savedAmount: (json['savedAmount'] as int?) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'productType': productType,
    'targetAmount': targetAmount,
    'monthlyContribution': monthlyContribution,
    'durationMonths': durationMonths,
    'createdAt': createdAt.toIso8601String(),
    'savedAmount': savedAmount,
  };
}
