import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/app_avatar.dart';
import '../../components/app_confirm_sheet.dart';
import '../../components/app_error_state.dart';
import '../../components/app_loading_indicator.dart';
import '../../models/order.dart';
import '../../models/debt.dart';
import '../../providers/customer_provider.dart';
import '../../services/customer_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/l10n.dart';
import '../../widgets/debt_card.dart';
import '../../widgets/order_card.dart';
import '../orders/order_detail_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;
  const CustomerDetailScreen({super.key, required this.customerId});
  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final _service = CustomerService();
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.getCustomer(widget.customerId);
      setState(() { _data = data; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LangProvider>().t;
    final c = context.appColors;

    if (_loading) return Scaffold(backgroundColor: c.background, body: const AppLoadingIndicator());
    if (_error != null) return Scaffold(backgroundColor: c.background,
        body: AppErrorState(message: _error!, onRetry: _load));

    final raw = _data?['customer'] ?? _data ?? {};
    final customer = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
    final orders = (_data?['recentOrders'] as List? ?? [])
        .map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
    final debts = (_data?['recentDebts'] as List? ?? [])
        .map((e) => Debt.fromJson(e as Map<String, dynamic>)).toList();
    final name = customer['name'] as String? ?? '';

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: c.danger),
            onPressed: () async {
              final ok = await AppConfirmSheet.show(context,
                  title: t.deleteCustomer, message: t.deleteCustomerConfirm,
                  confirmLabel: t.delete, cancelLabel: t.cancel);
              if (ok && context.mounted) {
                await context.read<CustomerProvider>().delete(widget.customerId);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, 40),
        children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(Spacing.xl),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: Radii.rLarge,
              border: Border.all(color: c.border),
            ),
            child: Column(
              children: [
                AppAvatar(name: name, radius: 34, color: c.primary),
                const SizedBox(height: Spacing.md),
                Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: c.textPrimary)),
                if ((customer['phone'] as String? ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone_outlined, size: 13, color: c.textSecondary),
                      const SizedBox(width: 4),
                      Text(customer['phone'] as String, style: TextStyle(fontSize: 13, color: c.textSecondary)),
                    ],
                  ),
                ],
                if ((customer['notes'] as String? ?? '').isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Divider(color: c.border),
                  Text(customer['notes'] as String,
                      style: TextStyle(fontSize: 13, color: c.textSecondary), textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),

          // Orders
          Text(t.recentOrdersCust, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.textPrimary)),
          const SizedBox(height: Spacing.sm),
          if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(child: Text(t.noOrders, style: TextStyle(fontSize: 12, color: c.textMuted))),
            )
          else
            ...orders.map((o) => OrderCard(
              order: o,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: o.id))),
            )),

          const SizedBox(height: Spacing.xl),
          Text(t.debts, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.textPrimary)),
          const SizedBox(height: Spacing.sm),
          if (debts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(child: Text(t.noDebts, style: TextStyle(fontSize: 12, color: c.textMuted))),
            )
          else
            DebtCardLabels(
              owedLabel: t.owedToMeTab,
              iOweLabel: t.iOweTab,
              child: Column(
                children: debts.map((d) => DebtCard(debt: d)).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
