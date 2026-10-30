import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/savings_provider.dart';
import '../../providers/savings_totals_provider.dart';
import '../../widgets/brand_loader.dart';
import '../../widgets/count_up_text.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/savings_plan_tile.dart';
import '../../widgets/staggered_reveal.dart';
import '../savings/all_plans_screen.dart';
import '../savings/saved_plan_details_screen.dart';

const _recentCount = 3;

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final plans = ref.watch(savingsPlansProvider);
    final total = ref.watch(totalSavingsProvider);
    // Newest first, so a plan the user just created shows up here.
    final sorted = ref.watch(recentPlansProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('KoinsMFB'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(savingsPlansProvider);
          await ref.read(savingsPlansProvider.future);
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                StaggeredReveal(
                  index: 0,
                  child: Text(
                    'Good Morning, ${AppConstants.greetingName}',
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                StaggeredReveal(index: 1, child: _BalanceCard(total: total)),
                const SizedBox(height: AppSpacing.md),
                StaggeredReveal(
                  index: 2,
                  child: Row(
                    children: [
                      // The theme's pill buttons are full width, so a Row
                      // needs Expanded to give them a bounded width.
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => Navigator.of(
                            context,
                          ).pushNamed('/create-savings'),
                          icon: const Icon(Icons.add),
                          label: const Text('Create savings'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/products'),
                          icon: const Icon(Icons.grid_view_rounded),
                          label: const Text('View products'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Recent savings',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    if (sorted.length > _recentCount)
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AllPlansScreen(),
                          ),
                        ),
                        child: const Text('See all'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                plans.when(
                  loading: () => SizedBox(
                    height: 200,
                    child: Center(
                      child: BrandLoader(
                        size: 48,
                        reduceMotion: MediaQuery.disableAnimationsOf(context),
                      ),
                    ),
                  ),
                  error: (_, _) => SizedBox(
                    height: 240,
                    child: ErrorView(
                      message: 'Could not load your savings.',
                      onRetry: () => ref.invalidate(savingsPlansProvider),
                    ),
                  ),
                  data: (_) {
                    if (sorted.isEmpty) {
                      return const SizedBox(
                        height: 200,
                        child: EmptyView(
                          icon: Icons.savings_outlined,
                          message:
                              'No savings plans yet. Create your first one.',
                        ),
                      );
                    }
                    final recent = sorted.take(_recentCount).toList();
                    return Column(
                      children: [
                        for (var i = 0; i < recent.length; i++)
                          StaggeredReveal(
                            index: i + 3,
                            child: SavingsPlanTile(
                              plan: recent[i],
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      SavedPlanDetailsScreen(plan: recent[i]),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onPrimary = scheme.onPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, scheme.tertiary, 0.35)!,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total savings',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: onPrimary.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 8),
          CountUpText(
            value: total,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
