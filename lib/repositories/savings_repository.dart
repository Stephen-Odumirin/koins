import '../models/savings_plan.dart';
import '../models/savings_product.dart';
import '../services/local_storage_service.dart';

class SavingsRepository {
  SavingsRepository(this._storage);

  final LocalStorageService _storage;

  // Seed data from the brief. Local, so the app works offline.
  static const products = [
    SavingsProduct(
      id: 'target',
      name: 'Target Savings',
      interestRate: 12,
      durationMonths: 12,
      description: 'Save towards a specific goal with fixed monthly contributions.',
      minDeposit: 5000,
    ),
    SavingsProduct(
      id: 'fixed',
      name: 'Fixed Deposit',
      interestRate: 18,
      durationMonths: 6,
      description: 'Lock funds for six months at a higher rate.',
      minDeposit: 50000,
    ),
    SavingsProduct(
      id: 'education',
      name: 'Education Savings',
      interestRate: 10,
      durationMonths: null,
      description: 'Build a fund for school fees, with withdrawals when you need them.',
      minDeposit: 5000,
    ),
    SavingsProduct(
      id: 'vacation',
      name: 'Vacation Savings',
      interestRate: 8,
      durationMonths: null,
      description: 'Plan your next trip with flexible withdrawals.',
      minDeposit: 2000,
    ),
  ];

  // Shown on the dashboard. In memory only, not persisted.
  static final _seedPlans = [
    SavingsPlan(
      id: 'seed-1',
      name: 'Emergency Fund',
      productType: 'Fixed Deposit',
      targetAmount: 120000,
      monthlyContribution: 10000,
      durationMonths: 12,
      createdAt: DateTime(2026, 1, 1),
    ),
    SavingsPlan(
      id: 'seed-2',
      name: 'School Fees 2027',
      productType: 'Education Savings',
      targetAmount: 350000,
      monthlyContribution: 25000,
      durationMonths: 14,
      createdAt: DateTime(2026, 3, 15),
    ),
    SavingsPlan(
      id: 'seed-3',
      name: 'New Laptop',
      productType: 'Target Savings',
      targetAmount: 480000,
      monthlyContribution: 40000,
      durationMonths: 12,
      createdAt: DateTime(2026, 5, 10),
    ),
  ];

  List<SavingsPlan> get seedPlansForDashboard => _seedPlans;

  Future<List<SavingsProduct>> getProducts() async => products;

  Future<List<SavingsPlan>> getUserPlans() async => _storage.loadPlans();

  Future<void> createPlan(SavingsPlan plan) async {
    final current = _storage.loadPlans();
    await _storage.savePlans([...current, plan]);
  }
}
