import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/app_avatar.dart';
import '../../components/app_confirm_sheet.dart';
import '../../components/app_empty_state.dart';
import '../../components/app_error_state.dart';
import '../../components/app_search_bar.dart';
import '../../components/app_skeleton.dart';
import '../../providers/customer_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/l10n.dart';
import 'customer_detail_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});
  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _load() {
    final prov = context.read<CustomerProvider>();
    prov.setSearch(_searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim());
    prov.load();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<CustomerProvider>().loadMore();
    }
  }

  Future<void> _delete(String id) async {
    final t = context.read<LangProvider>().t;
    final ok = await AppConfirmSheet.show(context,
        title: t.deleteCustomer, message: t.deleteCustomerConfirm,
        confirmLabel: t.delete, cancelLabel: t.cancel);
    if (!ok || !mounted) return;
    await context.read<CustomerProvider>().delete(id);
  }

  void _showAddSheet() {
    final t = context.read<LangProvider>().t;
    final c = context.appColors;
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final safePad = MediaQuery.of(context).padding.bottom;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          left: Spacing.xl, right: Spacing.xl, top: Spacing.md,
          bottom: MediaQuery.of(_).viewInsets.bottom + safePad + Spacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: c.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: c.income.withValues(alpha: 0.12),
                    borderRadius: Radii.rMedium,
                  ),
                  child: Icon(Icons.person_add_outlined, color: c.income, size: IconSize.medium),
                ),
                const SizedBox(width: Spacing.md),
                Text(t.addCustomer, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: c.textPrimary)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: c.textSecondary, size: IconSize.medium),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: InputDecoration(labelText: '${t.name} *'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneCtrl,
              decoration: InputDecoration(labelText: t.phone),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _doSave(),
            ),
            const SizedBox(height: Spacing.xl),
            SizedBox(
              width: double.infinity, height: 48,
              child: FilledButton(
                onPressed: _doSave,
                child: Text(t.addCustomer, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );

    void _doSave() async {
      if (nameCtrl.text.trim().isEmpty) return;
      Navigator.pop(context);
      await context.read<CustomerProvider>().create(
        name: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
      );
      _load();
    }
  }

  void _doSave() {}

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CustomerProvider>();
    final t = context.watch<LangProvider>().t;
    final c = context.appColors;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(t.customers),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, 10),
            child: AppSearchBar(
              controller: _searchCtrl,
              hintText: t.searchCustomers,
              onChanged: (_) => _load(),
            ),
          ),
          Divider(height: 1, color: c.border),
          Expanded(child: _buildList(prov, t, c)),
        ],
      ),
    );
  }

  Widget _buildList(CustomerProvider prov, L10n t, AppColors c) {
    if (prov.loading && prov.items.isEmpty) return const AppSkeletonList();
    if (prov.error != null && prov.items.isEmpty) {
      return AppErrorState(message: prov.error!, onRetry: _load);
    }
    if (prov.items.isEmpty) {
      return AppEmptyState(
        icon: Icons.people_outline,
        title: t.noCustomers,
        subtitle: t.noCustomersSub,
        actionLabel: t.addCustomer,
        onAction: _showAddSheet,
      );
    }
    return RefreshIndicator(
      onRefresh: () async => _load(),
      color: c.primary,
      backgroundColor: c.surface,
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.only(top: 6, bottom: 120),
        itemCount: prov.items.length + (prov.hasMore ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == prov.items.length) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final cust = prov.items[i];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: 4),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: Radii.rLarge,
              border: Border.all(color: c.border),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              leading: AppAvatar(name: cust.name, radius: 20, color: c.primary),
              title: Text(cust.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
              subtitle: cust.phone != null && cust.phone!.isNotEmpty
                  ? Text(cust.phone!, style: TextStyle(fontSize: 12, color: c.textSecondary)) : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 18, color: c.textMuted),
                    onPressed: () => _delete(cust.id),
                    padding: EdgeInsets.zero,
                  ),
                  Icon(Icons.chevron_right, color: c.textMuted, size: IconSize.small),
                ],
              ),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => CustomerDetailScreen(customerId: cust.id))),
            ),
          );
        },
      ),
    );
  }
}
