import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../providers/savings_provider.dart';
import '../../providers/savings_totals_provider.dart';
import '../../widgets/brand_loader.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/savings_plan_tile.dart';
import 'saved_plan_details_screen.dart';
import '../../l10n/app_localizations.dart';

/// Every saved plan, newest first.
class AllPlansScreen extends ConsumerWidget {
  const AllPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(savingsPlansProvider);
    final plans = ref.watch(recentPlansProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.allSavingsTitle)),
      body: state.when(
        loading: () => Center(
          child: BrandLoader(
            size: 48,
            reduceMotion: MediaQuery.disableAnimationsOf(context),
          ),
        ),
        error: (_, _) => ErrorView(
          message: l10n.savingsLoadError,
          onRetry: () => ref.invalidate(savingsPlansProvider),
        ),
        data: (_) {
          if (plans.isEmpty) {
            return EmptyView(
              icon: Icons.savings_outlined,
              message: l10n.savingsEmpty,
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  for (final plan in plans)
                    SavingsPlanTile(
                      plan: plan,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => SavedPlanDetailsScreen(plan: plan),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
