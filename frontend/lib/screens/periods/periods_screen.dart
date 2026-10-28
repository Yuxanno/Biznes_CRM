import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/app_loading_indicator.dart';
import '../../components/app_error_state.dart';
import '../../providers/period_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/formatters.dart';
import '../../utils/l10n.dart';

class PeriodsScreen extends StatefulWidget {
  const PeriodsScreen({super.key});
  @override
  State<PeriodsScreen> createState() => _PeriodsScreenState();
}

class _PeriodsScreenState extends State<PeriodsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<PeriodProvider>().load());
  }

  Future<void> _showNewPeriod() async {
    final t = context.read<LangProvider>().t;
    final c = context.appColors;
    final ctrl = TextEditingController();
    final safePad = MediaQuery.of(context).padding.bottom;

    final ok = await showModalBottomSheet<bool>(
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
            const SizedBox(height: Spacing.lg),
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: c.primary.withValues(alpha: 0.12),
                    borderRadius: Radii.rMedium,
                  ),
                  child: Icon(Icons.add_rounded, color: c.primary, size: IconSize.medium),
                ),
                const SizedBox(width: Spacing.md),
                Text(t.newPeriod, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: c.textPrimary)),
              ],
            ),
            const SizedBox(height: 6),
            Text(t.newPeriodSub, style: TextStyle(fontSize: 12, color: c.textMuted)),
            const SizedBox(height: Spacing.md),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: InputDecoration(labelText: t.periodName, hintText: t.periodNameHint),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: Spacing.xl),
            Row(
              children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(t.cancel),
                )),
                const SizedBox(width: 10),
                Expanded(child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(t.create),
                )),
              ],
            ),
          ],
        ),
      ),
    );
    if (ok != true || ctrl.text.trim().isEmpty || !mounted) return;
    await context.read<PeriodProvider>().createPeriod(ctrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PeriodProvider>();
    final t = context.watch<LangProvider>().t;
    final c = context.appColors;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(t.businessPeriods),
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded), onPressed: _showNewPeriod),
        ],
      ),
      body: prov.loading && prov.items.isEmpty
          ? const AppLoadingIndicator()
          : prov.error != null && prov.items.isEmpty
              ? AppErrorState(message: prov.error!, onRetry: () => prov.load())
              : RefreshIndicator(
                  onRefresh: () => prov.load(),
                  color: c.primary,
                  backgroundColor: c.surface,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(Spacing.lg),
                    itemCount: prov.items.length,
                    itemBuilder: (_, i) {
                      final p = prov.items[i];
                      final color = p.isActive ? c.income : c.textSecondary;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(Spacing.lg),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: Radii.rLarge,
                          border: Border.all(
                            color: p.isActive ? c.primary.withValues(alpha: 0.3) : c.border,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(p.name,
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.textPrimary))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: color.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(width: 6, height: 6,
                                          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                      const SizedBox(width: 5),
                                      Text(p.isActive ? t.active : t.closed,
                                          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.play_arrow_rounded, size: 13, color: c.textSecondary),
                                const SizedBox(width: 4),
                                Text('${t.started}: ${Formatters.dateShort(p.startDate)}',
                                    style: TextStyle(fontSize: 11, color: c.textMuted)),
                                if (p.endDate != null) ...[
                                  const SizedBox(width: 12),
                                  Icon(Icons.stop_rounded, size: 13, color: c.textSecondary),
                                  const SizedBox(width: 4),
                                  Text('${t.ended}: ${Formatters.dateShort(p.endDate!)}',
                                      style: TextStyle(fontSize: 11, color: c.textMuted)),
                                ],
                              ],
                            ),
                            if (p.totalIncome != null) ...[
                              const SizedBox(height: 10),
                              Divider(color: c.border, height: 1),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _Stat(label: t.income, value: p.totalIncome ?? 0, color: c.income, c: c),
                                  _Stat(label: t.expense, value: p.totalExpense ?? 0, color: c.expense, c: c),
                                  _Stat(label: t.profit, value: p.profit ?? 0,
                                      color: (p.profit ?? 0) >= 0 ? c.income : c.danger, c: c),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final AppColors c;

  const _Stat({required this.label, required this.value, required this.color, required this.c});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Formatters.currencyCompact(value),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: TextStyle(fontSize: 11, color: c.textMuted)),
      ],
    ),
  );
}
