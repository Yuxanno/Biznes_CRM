import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/app_segmented_control.dart';
import '../../providers/debt_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/formatters.dart';
import '../../utils/l10n.dart';
import '../../utils/validators.dart';

// ─── Sheet ────────────────────────────────────────────────────────────────────
class AddDebtSheet extends StatelessWidget {
  const AddDebtSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.watch<LangProvider>().t;
    final h = MediaQuery.of(context).size.height;
    final safePad = MediaQuery.of(context).padding.bottom;

    return Container(
      height: h * 0.72,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: Spacing.md),
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: c.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: c.warning.withValues(alpha: 0.12),
                    borderRadius: Radii.rMedium,
                  ),
                  child: Icon(Icons.account_balance_wallet_rounded, color: c.warning, size: IconSize.medium),
                ),
                const SizedBox(width: Spacing.md),
                Text(t.addDebt, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: c.textPrimary)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: c.textSecondary, size: IconSize.medium),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                ),
              ],
            ),
          ),
          Expanded(child: _DebtForm(isSheet: true)),
          SizedBox(height: safePad),
        ],
      ),
    );
  }
}

// ─── Full screen (edit) ───────────────────────────────────────────────────────
class AddDebtScreen extends StatelessWidget {
  final Map<String, dynamic>? initial;
  const AddDebtScreen({super.key, this.initial});

  @override
  Widget build(BuildContext context) {
    final t = context.read<LangProvider>().t;
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(title: Text(initial != null ? t.editDebt : t.addDebt)),
      body: SafeArea(child: _DebtForm(initial: initial, isSheet: false)),
    );
  }
}

// ─── Form ─────────────────────────────────────────────────────────────────────
class _DebtForm extends StatefulWidget {
  final Map<String, dynamic>? initial;
  final bool isSheet;
  const _DebtForm({this.initial, required this.isSheet});

  @override
  State<_DebtForm> createState() => _DebtFormState();
}

class _DebtFormState extends State<_DebtForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _paidCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _type = 'owed';
  DateTime? _dueDate;
  bool _saving = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final d = widget.initial!;
      _type = d['type'] ?? 'owed';
      _nameCtrl.text = d['personName'] ?? '';
      _phoneCtrl.text = d['phone'] ?? '';
      _amountCtrl.text = d['amount']?.toString() ?? '';
      _paidCtrl.text = d['paidAmount']?.toString() ?? '';
      _descCtrl.text = d['description'] ?? '';
      _dueDate = d['dueDate'] != null ? DateTime.parse(d['dueDate']) : null;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _amountCtrl.dispose();
    _paidCtrl.dispose(); _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final prov = context.read<DebtProvider>();
    final amount = double.parse(_amountCtrl.text.trim());
    final paidAmount = _paidCtrl.text.trim().isNotEmpty
        ? double.tryParse(_paidCtrl.text.trim()) : null;
    bool ok;
    if (_isEdit) {
      ok = await prov.update(widget.initial!['id'], {
        'type': _type,
        'personName': _nameCtrl.text.trim(),
        if (_phoneCtrl.text.trim().isNotEmpty) 'phone': _phoneCtrl.text.trim(),
        'amount': amount,
        'paidAmount': paidAmount ?? 0,
        if (_descCtrl.text.trim().isNotEmpty) 'description': _descCtrl.text.trim(),
        if (_dueDate != null) 'dueDate': _dueDate!.toIso8601String(),
      });
    } else {
      ok = await prov.create(
        type: _type,
        personName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        amount: amount,
        paidAmount: paidAmount,
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        dueDate: _dueDate?.toIso8601String(),
      );
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context, true);
    else ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(prov.error ?? 'Error'), backgroundColor: context.appColors.danger));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LangProvider>().t;
    final c = context.appColors;
    final bot = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(Spacing.lg, 4, Spacing.lg, widget.isSheet ? bot + Spacing.lg : Spacing.lg),
      child: Form(key: _formKey, child: Column(
        children: [
          AppSegmentedControl(
            value: _type,
            value1: 'owed', value2: 'owe',
            label1: t.owedToMeTab, label2: t.iOweTab,
            color1: c.income, color2: c.expense,
            onChanged: (v) => setState(() => _type = v),
          ),
          const SizedBox(height: Spacing.md),
          TextFormField(
            controller: _nameCtrl,
            decoration: InputDecoration(labelText: '${t.personCompany} *',
                prefixIcon: const Icon(Icons.person_outline)),
            validator: (v) => Validators.required(v, t.personCompany),
            textInputAction: TextInputAction.next,
            autofocus: widget.isSheet,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _phoneCtrl,
            decoration: InputDecoration(labelText: t.phone,
                prefixIcon: const Icon(Icons.phone_outlined)),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _amountCtrl,
            decoration: InputDecoration(labelText: '${t.totalAmount} *',
                prefixIcon: const Icon(Icons.attach_money_rounded)),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: Validators.amount,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _paidCtrl,
            decoration: InputDecoration(
              labelText: '${t.paidAmount} (${t.optional})',
              prefixIcon: const Icon(Icons.paid_outlined),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: Validators.optionalAmount,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _descCtrl,
            decoration: InputDecoration(
              labelText: '${t.description} (${t.optional})',
              prefixIcon: const Icon(Icons.notes_outlined),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _pickDate,
            borderRadius: Radii.rMedium,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: '${t.dueDate} (${t.optional})',
                prefixIcon: const Icon(Icons.event_outlined),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dueDate != null ? Formatters.dateShort(_dueDate!) : t.noDueDate,
                    style: TextStyle(color: c.textPrimary),
                  ),
                  if (_dueDate != null)
                    GestureDetector(
                      onTap: () => setState(() => _dueDate = null),
                      child: Icon(Icons.clear_rounded, size: IconSize.small, color: c.textSecondary),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.xl),
          SizedBox(
            width: double.infinity, height: 50,
            child: FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text(_isEdit ? t.save : t.addDebt,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      )),
    );
  }
}
