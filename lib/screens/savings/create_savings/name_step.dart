import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../widgets/app_text_field.dart';
import 'create_draft.dart';
import '../../../l10n/app_localizations.dart';

class NameStep extends ConsumerStatefulWidget {
  const NameStep({super.key});

  @override
  ConsumerState<NameStep> createState() => _NameStepState();
}

class _NameStepState extends ConsumerState<NameStep> {
  late final _name = TextEditingController(
    text: ref.read(createDraftProvider).name,
  );

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          AppLocalizations.of(context)!.nameStepTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _name,
          label: AppLocalizations.of(context)!.nameStepLabel,
          textInputAction: TextInputAction.done,
          inputFormatters: [LengthLimitingTextInputFormatter(40)],
          onChanged: ref.read(createDraftProvider.notifier).setName,
          onFieldSubmitted: (_) =>
              ref.read(createDraftProvider.notifier).next(),
        ),
      ],
    );
  }
}
