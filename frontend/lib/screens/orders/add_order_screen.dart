import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/formatters.dart';
import '../../utils/l10n.dart';
import '../../utils/validators.dart';

// ─── Sheet ────────────────────────────────────────────────────────────────────
class AddOrderSheet extends StatelessWidget {
  const AddOrderSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.watch<LangProvider>().t;
    final h = MediaQuery.of(context).size.height;
    final safePad = MediaQuery.of(context).padding.bottom;

    return Container(
      height: h * 0.75,
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
                    color: c.income.withValues(alpha: 0.12),
                    borderRadius: Radii.rMedium,
                  ),
                  child: Icon(Icons.assignment_add, color: c.income, size: IconSize.medium),
                ),
                const SizedBox(width: Spacing.md),
                Text(t.addOrder, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: c.textPrimary)),
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
          Expanded(child: _OrderForm(isSheet: true)),
          SizedBox(height: safePad),
        ],
      ),
    );
  }
}

// ─── Full screen (edit) ───────────────────────────────────────────────────────
class AddOrderScreen extends StatelessWidget {
  final Map<String, dynamic>? initial;
  const AddOrderScreen({super.key, this.initial});

  @override
  Widget build(BuildContext context) {
    final t = context.read<LangProvider>().t;
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(title: Text(initial != null ? t.editOrder : t.addOrder)),
      body: SafeArea(child: _OrderForm(initial: initial, isSheet: false)),
    );
  }
}

// ─── Form ─────────────────────────────────────────────────────────────────────
class _OrderForm extends StatefulWidget {
  final Map<String, dynamic>? initial;
  final bool isSheet;
  const _OrderForm({this.initial, required this.isSheet});

  @override
  State<_OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<_OrderForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _clientCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _status = 'new';
  DateTime? _deadline;
  bool _saving = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final d = widget.initial!;
      _titleCtrl.text = d['title'] ?? '';
      _clientCtrl.text = d['clientName'] ?? '';
      _phoneCtrl.text = d['clientPhone'] ?? '';
      _descCtrl.text = d['description'] ?? '';
      _amountCtrl.text = d['amount']?.toString() ?? '';
      _status = d['status'] ?? 'new';
      _deadline = d['deadline'] != null ? DateTime.parse(d['deadline']) : null;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _clientCtrl.dispose(); _phoneCtrl.dispose();
    _descCtrl.dispose(); _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final prov = context.read<OrderProvider>();
    final amount = _amountCtrl.text.trim().isNotEmpty
        ? double.tryParse(_amountCtrl.text.trim()) : null;
    bool ok;
    if (_isEdit) {
      ok = await prov.update(widget.initial!['id'], {
        'title': _titleCtrl.text.trim(),
        'clientName': _clientCtrl.text.trim(),
        if (_phoneCtrl.text.trim().isNotEmpty) 'clientPhone': _phoneCtrl.text.trim(),
        if (_descCtrl.text.trim().isNotEmpty) 'description': _descCtrl.text.trim(),
        if (amount != null) 'amount': amount,
        'status': _status,
        if (_deadline != null) 'deadline': _deadline!.toIso8601String(),
      });
    } else {
      ok = await prov.create(
        title: _titleCtrl.text.trim(),
        clientName: _clientCtrl.text.trim(),
        clientPhone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        amount: amount,
        deadline: _deadline?.toIso8601String(),
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
          TextFormField(
            controller: _titleCtrl,
            decoration: InputDecoration(labelText: '${t.orderTitle} *',
                prefixIcon: const Icon(Icons.title_rounded)),
            validator: (v) => Validators.required(v, t.orderTitle),
            textInputAction: TextInputAction.next,
            autofocus: widget.isSheet,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _clientCtrl,
            decoration: InputDecoration(labelText: '${t.clientName} *',
                prefixIcon: const Icon(Icons.person_outline)),
            validator: (v) => Validators.required(v, t.clientName),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _phoneCtrl,
            decoration: InputDecoration(labelText: t.clientPhone,
                prefixIcon: const Icon(Icons.phone_outlined)),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _amountCtrl,
            decoration: InputDecoration(labelText: t.amount,
                prefixIcon: const Icon(Icons.attach_money_rounded)),
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
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          if (_isEdit) ...[
            DropdownButtonFormField<String>(
              value: _status,
              dropdownColor: c.surfaceVariant,
              decoration: InputDecoration(labelText: t.status,
                  prefixIcon: const Icon(Icons.flag_outlined)),
              items: [
                DropdownMenuItem(value: 'new', child: Text(t.statusNew)),
                DropdownMenuItem(value: 'in_progress', child: Text(t.statusInProgress)),
                DropdownMenuItem(value: 'waiting', child: Text(t.statusWaiting)),
                DropdownMenuItem(value: 'completed', child: Text(t.statusCompleted)),
                DropdownMenuItem(value: 'cancelled', child: Text(t.statusCancelled)),
              ],
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
            const SizedBox(height: 10),
          ],
          InkWell(
            onTap: _pickDeadline,
            borderRadius: Radii.rMedium,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: '${t.deadline} (${t.optional})',
                prefixIcon: const Icon(Icons.event_outlined),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _deadline != null ? Formatters.dateShort(_deadline!) : t.noDeadline,
                    style: TextStyle(color: c.textPrimary),
                  ),
                  if (_deadline != null)
                    GestureDetector(
                      onTap: () => setState(() => _deadline = null),
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
                  : Text(_isEdit ? t.save : t.createOrder,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      )),
    );
  }
}
