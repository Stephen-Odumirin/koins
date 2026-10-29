import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/savings_provider.dart';
import '../../widgets/count_up_text.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/savings_plan_tile.dart';
import '../../widgets/staggered_reveal.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final plans = ref.watch(savingsPlansProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings'),
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
              padding: const EdgeInsets.all(16),
              children: [
                StaggeredReveal(
                  index: 0,
                  child: Text(
                    'Good Morning, ${AppConstants.greetingName}',
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 16),
                StaggeredReveal(
                  index: 1,
                  child: _BalanceCard(),
                ),
                const SizedBox(height: 16),
                StaggeredReveal(
                  index: 2,
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/create-savings'),
                          icon: const Icon(Icons.add),
                          label: const Text('Create Savings'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/products'),
                          icon: const Icon(Icons.grid_view_rounded),
                          label: const Text('View Products'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text('Recent savings', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                plans.when(
                  loading: () => const SizedBox(
                    height: 200,
                    child: LoadingView(),
                  ),
                  error: (_, _) => SizedBox(
                    height: 240,
                    child: ErrorView(
                      message: 'Could not load your savings.',
                      onRetry: () => ref.invalidate(savingsPlansProvider),
                    ),
                  ),
                  data: (list) {
                    if (list.isEmpty) {
                      return const SizedBox(
                        height: 200,
                        child: EmptyView(
                          icon: Icons.savings_outlined,
                          message: 'No savings plans yet. Create your first one.',
                        ),
                      );
                    }
                    final recent = list.take(3).toList();
                    return Column(
                      children: [
                        for (var i = 0; i < recent.length; i++)
                          StaggeredReveal(
                            index: i + 3,
                            child: SavingsPlanTile(plan: recent[i]),
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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onPrimary = scheme.onPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
            value: AppConstants.totalSavings,
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
