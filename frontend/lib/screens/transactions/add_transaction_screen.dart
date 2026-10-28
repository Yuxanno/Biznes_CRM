import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/app_segmented_control.dart';
import '../../models/category.dart';
import '../../providers/transaction_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/formatters.dart';
import '../../utils/l10n.dart';
import '../../utils/validators.dart';

// ─── Full-screen form (for edit mode) ─────────────────────────────────────────
class AddTransactionScreen extends StatelessWidget {
  final Map<String, dynamic>? initial;
  const AddTransactionScreen({super.key, this.initial});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.read<LangProvider>().t;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(title: Text(t.addTransaction)),
      body: SafeArea(child: _TransactionForm(initial: initial, isSheet: false)),
    );
  }
}

// ─── Sheet form (from FAB) ────────────────────────────────────────────────────
class AddTransactionSheet extends StatelessWidget {
  const AddTransactionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.watch<LangProvider>().t;
    final h = MediaQuery.of(context).size.height;
    final safePad = MediaQuery.of(context).padding.bottom;

    return Container(
      height: h * 0.62,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
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
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: c.primary.withValues(alpha: 0.12),
                    borderRadius: Radii.rMedium,
                  ),
                  child: Icon(Icons.swap_vert_rounded, color: c.primary, size: IconSize.medium),
                ),
                const SizedBox(width: Spacing.md),
                Text(t.addTransaction, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: c.textPrimary)),
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
          Expanded(child: _TransactionForm(isSheet: true)),
          SizedBox(height: safePad),
        ],
      ),
    );
  }
}

// ─── Shared form ─────────────────────────────────────────────────────────────
class _TransactionForm extends StatefulWidget {
  final Map<String, dynamic>? initial;
  final bool isSheet;
  const _TransactionForm({this.initial, required this.isSheet});

  @override
  State<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _type = 'income';
  String? _category;
  DateTime _date = DateTime.now();
  List<Category> _categories = [];
  bool _saving = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final d = widget.initial!;
      _type = d['type'] ?? 'income';
      _amountCtrl.text = d['amount']?.toString() ?? '';
      _category = d['category'];
      _descCtrl.text = d['description'] ?? '';
      _date = d['date'] != null ? DateTime.parse(d['date']) : DateTime.now();
    }
    _loadCategories();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await ApiService().get('/categories', query: {'type': _type});
      final list = (data['data'] as List? ?? data['categories'] as List? ?? [])
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
      if (mounted) setState(() {
        _categories = list;
        if (_category == null && list.isNotEmpty) _category = list.first.name;
      });
    } catch (_) {}
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _category == null) return;
    setState(() => _saving = true);
    final prov = context.read<TransactionProvider>();
    final amount = double.parse(_amountCtrl.text.trim());
    bool ok;
    if (_isEdit) {
      ok = await prov.update(widget.initial!['id'], {
        'type': _type, 'amount': amount, 'category': _category,
        'description': _descCtrl.text.trim(), 'date': _date.toIso8601String(),
      });
    } else {
      ok = await prov.create(
        type: _type, amount: amount, category: _category!,
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        date: _date.toIso8601String(),
      );
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(prov.error ?? 'Error'), backgroundColor: context.appColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LangProvider>().t;
    final c = context.appColors;
    final bot = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg,
          widget.isSheet ? bot + Spacing.lg : Spacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSegmentedControl(
              value: _type,
              label1: t.income, label2: t.expense,
              onChanged: (v) { setState(() { _type = v; _category = null; }); _loadCategories(); },
            ),
            const SizedBox(height: Spacing.md + 2),

            TextFormField(
              controller: _amountCtrl,
              decoration: InputDecoration(
                  labelText: t.amount,
                  prefixIcon: const Icon(Icons.attach_money_rounded)),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: Validators.amount,
              autofocus: widget.isSheet,
            ),
            const SizedBox(height: Spacing.md),

            _categories.isEmpty
                ? const SizedBox(height: 48,
                    child: Center(child: SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))))
                : DropdownButtonFormField<String>(
                    value: _category,
                    dropdownColor: c.surfaceVariant,
                    decoration: InputDecoration(
                        labelText: t.category,
                        prefixIcon: const Icon(Icons.category_outlined)),
                    items: _categories.map((c) => DropdownMenuItem(
                      value: c.name, child: Text(c.name),
                    )).toList(),
                    onChanged: (v) => setState(() => _category = v),
                    validator: (v) => v == null ? t.selectCategory : null,
                  ),
            const SizedBox(height: Spacing.md),

            TextFormField(
              controller: _descCtrl,
              decoration: InputDecoration(
                labelText: '${t.description} (${t.optional})',
                prefixIcon: const Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: Spacing.md),

            InkWell(
              onTap: _pickDate,
              borderRadius: Radii.rMedium,
              child: InputDecorator(
                decoration: InputDecoration(
                    labelText: t.date,
                    prefixIcon: const Icon(Icons.calendar_today_outlined)),
                child: Text(Formatters.dateShort(_date),
                    style: TextStyle(color: c.textPrimary)),
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
                    : Text(_isEdit ? t.save : t.addTransaction,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
