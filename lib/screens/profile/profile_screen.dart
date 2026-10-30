import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/staggered_reveal.dart';
import '../../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: profile.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(
          message: l10n.profileLoadError,
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (user) => _ProfileBody(user: user),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            StaggeredReveal(
              index: 0,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      user.fullName.isNotEmpty ? user.fullName[0] : '?',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(user.fullName, style: theme.textTheme.headlineSmall),
                ],
              ),
            ),
            const SizedBox(height: 24),
            StaggeredReveal(
              index: 1,
              child: _InfoTile(icon: Icons.mail_outline, label: l10n.profileEmail, value: user.email),
            ),
            StaggeredReveal(
              index: 2,
              child: _InfoTile(icon: Icons.phone_outlined, label: l10n.profilePhone, value: user.phone),
            ),
            StaggeredReveal(
              index: 3,
              child: const _NotificationsTile(),
            ),
            const SizedBox(height: 32),
            StaggeredReveal(
              index: 4,
              child: FilledButton.tonalIcon(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (_) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: Text(l10n.profileLogout),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(label, style: theme.textTheme.bodySmall),
        subtitle: Text(value, style: theme.textTheme.titleMedium),
      ),
    );
  }
}

class _NotificationsTile extends ConsumerWidget {
  const _NotificationsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final unread = ref.watch(unreadCountProvider);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        leading: Icon(Icons.notifications_outlined, color: theme.colorScheme.primary),
        title: Text(l10n.notificationsTitle, style: theme.textTheme.titleMedium),
        trailing: unread > 0
            ? Badge(label: Text('$unread'), child: const Icon(Icons.chevron_right))
            : const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).pushNamed('/notifications'),
      ),
    );
  }
}
