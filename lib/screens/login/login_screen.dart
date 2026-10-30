import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../models/app_notification.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/providers.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/brand_mark.dart';
import '../../l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _argumentShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentShown) return;
    _argumentShown = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showMessage(arg));
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).login(_email.text, _password.text);
      ref.read(notificationsProvider.notifier).deliver(
            AppNotification(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              title: l10n.welcomeNotificationTitle,
              body: l10n.welcomeNotificationBody,
              receivedAt: DateTime.now(),
            ),
          );
      if (!mounted) return;
      final hasPin = await ref.read(pinStoreProvider).hasPin();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        hasPin ? '/dashboard' : '/pin-setup',
      );
    } on AppException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage(l10n.loginGenericError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _comingSoon() => _showMessage(AppLocalizations.of(context)!.loginComingSoon);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: reduceMotion ? 1 : 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, t, child) => Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, (1 - t) * 16),
                    child: child,
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: BrandMark(size: 72)),
                      const SizedBox(height: 24),
                      Text(
                        l10n.loginWelcomeBack,
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.loginSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      AppTextField(
                        key: const Key('login-email'),
                        controller: _email,
                        label: l10n.loginEmailLabel,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: Validators.email,
                        enabled: !_loading,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        key: const Key('login-password'),
                        controller: _password,
                        label: l10n.loginPasswordLabel,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        validator: Validators.password,
                        onFieldSubmitted: (_) => _submit(),
                        enabled: !_loading,
                        suffixIcon: IconButton(
                          tooltip: _obscure ? l10n.loginShowPassword : l10n.loginHidePassword,
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        key: const Key('login-submit'),
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.loginSubmit),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: _comingSoon,
                            child: Text(l10n.loginForgotPassword),
                          ),
                          TextButton(
                            onPressed: _comingSoon,
                            child: Text(l10n.loginCreateAccount),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
