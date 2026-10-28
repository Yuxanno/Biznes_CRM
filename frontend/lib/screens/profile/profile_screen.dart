import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/app_avatar.dart';
import '../../components/app_confirm_sheet.dart';
import '../../components/app_segmented_control.dart';
import '../../providers/auth_provider.dart';
import '../../providers/period_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/theme_provider.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/l10n.dart';

import '../debts/debts_screen.dart';
import '../customers/customers_screen.dart';
import '../periods/periods_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final periods = context.watch<PeriodProvider>();
    final langProv = context.watch<LangProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final t = langProv.t;
    final c = context.appColors;

    final username = auth.user?.username ?? '';

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(t.profile),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, 100),
        children: [
          // ── Profile card ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(Spacing.xl),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: Radii.rLarge,
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                AppAvatar(name: username, radius: 28, color: c.primary),
                const SizedBox(width: Spacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                        ),
                      ),
                      if (periods.active != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                  color: c.income, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 5),
                            Text(periods.active!.name,
                                style: TextStyle(
                                    fontSize: 12, color: c.textSecondary)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xxl),

          // ── Appearance / Theme ────────────────────────────────────────
          _SectionLabel(label: t.appearance, color: c),
          _Card(color: c, child: Column(
            children: [
              Row(
                children: [
                  _SectionIcon(icon: Icons.dark_mode_outlined, color: c.primary, bg: c.primary),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.appearance, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: c.textPrimary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              _ThemeSelector(color: c, t: t, themeProv: themeProv),
            ],
          )),

          const SizedBox(height: Spacing.xl),

          // ── Language ──────────────────────────────────────────────────
          _SectionLabel(label: t.language, color: c),
          _Card(color: c, child: Column(
            children: [
              _LangTile(
                flag: '🇷🇺',
                label: 'Русский',
                selected: langProv.lang == 'ru',
                c: c,
                onTap: () => langProv.setLang('ru'),
              ),
              Divider(color: c.border, height: 1, indent: 56),
              _LangTile(
                flag: '🇬🇧',
                label: 'English',
                selected: langProv.lang == 'en',
                c: c,
                onTap: () => langProv.setLang('en'),
              ),
            ],
          )),

          const SizedBox(height: Spacing.xl),

          // ── Sections ──────────────────────────────────────────────────
          _SectionLabel(label: t.sections, color: c),
          _Card(color: c, child: Column(
            children: [
              _MenuTile(
                icon: Icons.account_balance_wallet_rounded,
                color: c.warning,
                title: t.debts,
                sub: t.noDebtsSub.split('.').first,
                c: c,
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const DebtsScreen())),
              ),
              Divider(color: c.border, height: 1, indent: 56),
              _MenuTile(
                icon: Icons.people_rounded,
                color: c.income,
                title: t.customers,
                sub: t.noCustomersSub.split('.').first,
                c: c,
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const CustomersScreen())),
              ),
              Divider(color: c.border, height: 1, indent: 56),
              _MenuTile(
                icon: Icons.bookmark_rounded,
                color: c.primary,
                title: t.periods,
                sub: t.managePeriodsDesc,
                c: c,
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const PeriodsScreen())),
              ),
            ],
          )),

          const SizedBox(height: Spacing.xl),

          // ── About ─────────────────────────────────────────────────────
          _SectionLabel(label: t.about, color: c),
          _Card(color: c, child: Column(
            children: [
              _MenuTile(
                icon: Icons.info_outline_rounded,
                color: c.textSecondary,
                title: t.version,
                sub: '1.0.0',
                c: c,
              ),
              Divider(color: c.border, height: 1, indent: 56),
              _MenuTile(
                icon: Icons.code_rounded,
                color: c.textSecondary,
                title: t.stack,
                sub: 'Flutter + Next.js + MongoDB',
                c: c,
              ),
            ],
          )),

          const SizedBox(height: Spacing.xl),

          // ── Logout ────────────────────────────────────────────────────
          _Card(
            color: c,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c.danger.withValues(alpha: 0.12),
                  borderRadius: Radii.rMedium,
                ),
                child: Icon(Icons.logout_rounded, color: c.danger, size: IconSize.medium),
              ),
              title: Text(t.logout,
                  style: TextStyle(
                      color: c.danger, fontWeight: FontWeight.w600, fontSize: 15)),
              onTap: () async {
                final ok = await AppConfirmSheet.show(context,
                    title: t.logout,
                    message: t.logoutConfirm,
                    confirmLabel: t.logout,
                    cancelLabel: t.cancel,
                    isDanger: true);
                if (ok && context.mounted) {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Theme selector ────────────────────────────────────────────────────────────
class _ThemeSelector extends StatelessWidget {
  final AppColors c;
  final L10n t;
  final ThemeProvider themeProv;

  const _ThemeSelector({required this.c, required this.t, required this.themeProv});

  @override
  Widget build(BuildContext context) {
    final modes = [
      (ThemeMode.light, t.themeLight),
      (ThemeMode.dark, t.themeDark),
      (ThemeMode.system, t.themeSystem),
    ];

    return Row(
      children: modes.map((mode) {
        final selected = themeProv.mode == mode.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => themeProv.setMode(mode.$1),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? c.primary.withValues(alpha: 0.12) : c.surfaceVariant,
                borderRadius: Radii.rMedium,
                border: selected
                    ? Border.all(color: c.primary.withValues(alpha: 0.5))
                    : null,
              ),
              child: Center(
                child: Text(
                  mode.$2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected ? c.primary : c.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Helper widgets ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final AppColors c;
  const _SectionLabel({required this.label, required this.c});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: Spacing.sm),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: c.textSecondary,
          ),
        ),
      );
}

class _Card extends StatelessWidget {
  final Widget child;
  final AppColors c;
  const _Card({required this.child, required this.c});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: Radii.rLarge,
          border: Border.all(color: c.border),
        ),
        child: child,
      );
}

class _SectionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  const _SectionIcon({required this.icon, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: Radii.rMedium,
        ),
        child: Icon(icon, color: color, size: IconSize.medium),
      );
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? sub;
  final VoidCallback? onTap;
  final AppColors c;

  const _MenuTile({
    required this.icon,
    required this.color,
    required this.title,
    this.sub,
    this.onTap,
    required this.c,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: Radii.rMedium,
          ),
          child: Icon(icon, color: color, size: IconSize.medium),
        ),
        title: Text(title,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, color: c.textPrimary)),
        subtitle: sub != null
            ? Text(sub!, style: TextStyle(fontSize: 12, color: c.textSecondary))
            : null,
        trailing: onTap != null
            ? Icon(Icons.chevron_right, color: c.textSecondary, size: IconSize.small)
            : null,
        onTap: onTap,
      );
}

class _LangTile extends StatelessWidget {
  final String flag;
  final String label;
  final bool selected;
  final AppColors c;
  final VoidCallback onTap;

  const _LangTile({
    required this.flag,
    required this.label,
    required this.selected,
    required this.c,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: selected
                ? c.primary.withValues(alpha: 0.12)
                : c.surfaceVariant,
            borderRadius: Radii.rMedium,
          ),
          child: Center(child: Text(flag, style: const TextStyle(fontSize: 18))),
        ),
        title: Text(label,
            style: TextStyle(
                fontSize: 15,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? c.primary : c.textPrimary)),
        trailing: selected
            ? Icon(Icons.check_rounded, color: c.primary, size: IconSize.medium)
            : null,
        onTap: onTap,
      );
}
