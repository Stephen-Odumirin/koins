import '../models/savings_plan.dart';
import '../models/savings_product.dart';
import '../services/plan_database.dart';

class SavingsRepository {
  SavingsRepository(this._planDb);

  final PlanDatabase _planDb;

  // Seed data from the brief. Local, so the app works offline.
  static const products = [
    SavingsProduct(
      id: 'target',
      name: 'Target Savings',
      interestRate: 12,
      durationMonths: 12,
      description:
          'Save towards a specific goal with fixed monthly contributions.',
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
      description:
          'Build a fund for school fees, with withdrawals when you need them.',
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

  Future<List<SavingsProduct>> getProducts() async => products;

  Future<List<SavingsPlan>> getUserPlans() => _planDb.loadPlans();

  Future<void> createPlan(SavingsPlan plan) => _planDb.insertPlan(plan);
}
