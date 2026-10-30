import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
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
import '../../l10n/app_localizations.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final plans = ref.watch(savingsPlansProvider);
    final total = ref.watch(totalSavingsProvider);
    // Newest first, so a plan the user just created shows up here.
    final sorted = ref.watch(recentPlansProvider);

    return Scaffold(
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
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.dashboardGreeting(
                                    AppConstants.greetingName,
                                  ),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.heading,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  l10n.dashboardSubtitle,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.body,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            key: const Key('dashboard-profile'),
                            tooltip: l10n.dashboardProfileTooltip,
                            icon: const Icon(Icons.account_circle_outlined),
                            onPressed: () =>
                                Navigator.of(context).pushNamed('/profile'),
                          ),
                        ],
                      ),
                    ),
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
                          label: Text(l10n.createSavings),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/products'),
                          icon: const Icon(Icons.grid_view_rounded),
                          label: Text(l10n.dashboardViewProducts),
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
                        l10n.dashboardRecentSavings,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    if (sorted.isNotEmpty)
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AllPlansScreen(),
                          ),
                        ),
                        child: Text(l10n.dashboardSeeAll),
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
                      message: l10n.savingsLoadError,
                      onRetry: () => ref.invalidate(savingsPlansProvider),
                    ),
                  ),
                  data: (_) {
                    if (sorted.isEmpty) {
                      return SizedBox(
                        height: 200,
                        child: EmptyView(
                          icon: Icons.savings_outlined,
                          message: l10n.savingsEmpty,
                        ),
                      );
                    }
                    final recent = sorted.take(3).toList();
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

class _BalanceCard extends StatefulWidget {
  const _BalanceCard({required this.total});

  final int total;

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard> {
  // Display only; not persisted and never touches the stored total.
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onPrimary = scheme.onPrimary;
    final amountStyle = theme.textTheme.headlineMedium?.copyWith(
      color: onPrimary,
      fontWeight: FontWeight.w800,
    );

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
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.dashboardTotalSavings,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ),
              IconButton(
                key: const Key('total-visibility'),
                tooltip: _hidden
                    ? l10n.dashboardShowAmount
                    : l10n.dashboardHideAmount,
                color: onPrimary,
                icon: Icon(
                  _hidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => setState(() => _hidden = !_hidden),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (_hidden)
            Text('₦ ••••••', style: amountStyle)
          else
            CountUpText(value: widget.total, style: amountStyle),
        ],
      ),
    );
  }
}
