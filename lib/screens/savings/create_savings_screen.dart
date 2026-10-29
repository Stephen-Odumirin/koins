import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/savings_plan.dart';
import '../../models/savings_product.dart';
import '../../providers/savings_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/app_text_field.dart';

class CreateSavingsScreen extends ConsumerStatefulWidget {
  const CreateSavingsScreen({super.key, this.initialProduct});

  final SavingsProduct? initialProduct;

  @override
  ConsumerState<CreateSavingsScreen> createState() => _CreateSavingsScreenState();
}

class _CreateSavingsScreenState extends ConsumerState<CreateSavingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _target = TextEditingController();
  final _monthly = TextEditingController();
  final _duration = TextEditingController();

  late SavingsProduct? _product = widget.initialProduct;
  bool _saving = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _monthly.dispose();
    _duration.dispose();
    super.dispose();
  }

  static int _parse(String value) =>
      num.parse(value.replaceAll(',', '').trim()).round();

  Future<void> _submit() async {
    if (_saving) return;
    setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final plan = SavingsPlan(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _name.text.trim(),
        productType: _product!.name,
        targetAmount: _parse(_target.text),
        monthlyContribution: _parse(_monthly.text),
        durationMonths: _parse(_duration.text),
        createdAt: DateTime.now(),
      );
      await ref.read(savingsPlansProvider.notifier).createPlan(plan);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Savings Created Successfully')),
      );
      // Back to whichever screen is first in the stack (the dashboard)
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save your savings. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider).value ?? const <SavingsProduct>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Create savings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidate,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                AppTextField(
                  controller: _name,
                  label: 'Savings name',
                  textInputAction: TextInputAction.next,
                  enabled: !_saving,
                  validator: (v) => Validators.requiredField(v, 'Savings name'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<SavingsProduct>(
                  value: _product,
                  decoration: const InputDecoration(labelText: 'Product type'),
                  items: [
                    for (final p in products)
                      DropdownMenuItem(value: p, child: Text(p.name)),
                  ],
                  onChanged: _saving ? null : (p) => setState(() => _product = p),
                  validator: (v) => v == null ? 'Choose a product type' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _target,
                  label: 'Target amount',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  enabled: !_saving,
                  validator: (v) => Validators.positiveNumber(v, 'Target amount'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _monthly,
                  label: 'Monthly contribution',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  enabled: !_saving,
                  validator: (v) =>
                      Validators.positiveNumber(v, 'Monthly contribution'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _duration,
                  label: 'Duration (months)',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  enabled: !_saving,
                  validator: (v) => Validators.positiveNumber(v, 'Duration (months)'),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
