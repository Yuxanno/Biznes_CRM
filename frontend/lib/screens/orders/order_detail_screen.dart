import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../components/app_confirm_sheet.dart';
import '../../components/app_loading_indicator.dart';
import '../../components/app_error_state.dart';
import '../../config/app_config.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/formatters.dart';
import '../../utils/l10n.dart';
import '../../utils/storage.dart';
import 'add_order_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});
  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<OrderProvider>().loadOne(widget.orderId));
  }

  Future<void> _pickPhoto() async {
    final xfile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xfile == null || !mounted) return;
    final file = File(xfile.path);
    if (file.lengthSync() > AppConfig.maxPhotoSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File too large (max 10MB)')));
      return;
    }
    await context.read<OrderProvider>().uploadPhoto(widget.orderId, file);
  }

  Future<void> _changeStatus(Order order) async {
    final t = context.read<LangProvider>().t;
    final c = context.appColors;
    final statuses = ['new', 'in_progress', 'waiting', 'completed', 'cancelled'];
    final labels = [t.statusNew, t.statusInProgress, t.statusWaiting, t.statusCompleted, t.statusCancelled];
    final icons = [Icons.fiber_new_rounded, Icons.autorenew_rounded, Icons.hourglass_empty_rounded, Icons.check_circle_rounded, Icons.cancel_rounded];

    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(Spacing.xl, Spacing.md, Spacing.xl, MediaQuery.of(context).padding.bottom + Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: c.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: Spacing.lg),
            Text(t.changeStatus, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: c.textPrimary)),
            const SizedBox(height: Spacing.sm + 2),
            ...List.generate(statuses.length, (i) {
              final s = statuses[i];
              final color = c.orderStatus(s);
              final isActive = s == order.status;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isActive ? 0.2 : 0.1),
                    borderRadius: Radii.rMedium,
                  ),
                  child: Icon(icons[i], color: color, size: 18),
                ),
                title: Text(labels[i], style: TextStyle(
                  color: isActive ? color : c.textPrimary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                )),
                trailing: isActive ? Icon(Icons.check_rounded, color: color, size: 18) : null,
                onTap: () => Navigator.pop(context, s),
              );
            }),
          ],
        ),
      ),
    );
    if (picked != null && picked != order.status && mounted) {
      await context.read<OrderProvider>().update(widget.orderId, {'status': picked});
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<OrderProvider>();
    final order = prov.selected;
    final t = context.watch<LangProvider>().t;
    final c = context.appColors;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(order?.title ?? ''),
        actions: [
          if (order != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddOrderScreen(initial: {
                    'id': order.id, 'title': order.title, 'clientName': order.clientName,
                    'clientPhone': order.clientPhone, 'description': order.description,
                    'amount': order.amount, 'status': order.status,
                    'deadline': order.deadline?.toIso8601String(),
                  }),
                );
                if (mounted) context.read<OrderProvider>().loadOne(widget.orderId);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: c.danger),
              onPressed: () async {
                final ok = await AppConfirmSheet.show(context,
                    title: t.deleteOrder, message: t.deleteOrderConfirm,
                    confirmLabel: t.delete, cancelLabel: t.cancel);
                if (!ok || !mounted) return;
                await context.read<OrderProvider>().delete(widget.orderId);
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ],
      ),
      body: _buildBody(prov, order, t, c),
    );
  }

  Widget _buildBody(OrderProvider prov, Order? order, L10n t, AppColors c) {
    if (prov.loading && order == null) return const AppLoadingIndicator();
    if (prov.error != null && order == null) {
      return AppErrorState(message: prov.error!, onRetry: () => prov.loadOne(widget.orderId));
    }
    if (order == null) return const SizedBox.shrink();

    final statusColor = c.orderStatus(order.status);

    return ListView(
      padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, 40),
      children: [
        // Info card
        Container(
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: Radii.rLarge,
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(order.title,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: c.textPrimary))),
                  GestureDetector(
                    onTap: () => _changeStatus(order),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon(order.status), size: 13, color: statusColor),
                          const SizedBox(width: 4),
                          Text(Formatters.orderStatus(order.status),
                              style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 3),
                          Icon(Icons.expand_more_rounded, size: 14, color: statusColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              _InfoRow(icon: Icons.person_outline, label: t.client, value: order.clientName, c: c),
              if (order.clientPhone != null)
                _InfoRow(icon: Icons.phone_outlined, label: t.phone, value: order.clientPhone!, c: c),
              if (order.amount != null)
                _InfoRow(icon: Icons.attach_money_rounded, label: t.amount,
                    value: Formatters.currency(order.amount!), c: c),
              if (order.deadline != null)
                _InfoRow(
                  icon: Icons.event_rounded, label: t.deadline,
                  value: '${Formatters.dateShort(order.deadline!)} · ${Formatters.timeUntil(order.deadline!)}',
                  c: c,
                  valueColor: order.isOverdue ? c.danger : null,
                ),
              _InfoRow(icon: Icons.calendar_today_outlined, label: t.created,
                  value: Formatters.dateShort(order.createdDate), c: c),
              if (order.description?.isNotEmpty == true) ...[
                Divider(color: c.border),
                Text(order.description!, style: TextStyle(fontSize: 14, color: c.textPrimary)),
              ],
            ],
          ),
        ),
        const SizedBox(height: Spacing.md + 2),

        // Photos
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: Radii.rLarge,
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(t.photo, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.textPrimary)),
                  const Spacer(),
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: c.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: c.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, color: c.primary, size: 14),
                          const SizedBox(width: 4),
                          Text(t.add, style: TextStyle(fontSize: 12, color: c.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              order.photos.isEmpty
                  ? Center(child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(t.noPhotos, style: TextStyle(fontSize: 11, color: c.textMuted))))
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, crossAxisSpacing: 6, mainAxisSpacing: 6),
                      itemCount: order.photos.length,
                      itemBuilder: (_, i) => _PhotoTile(
                        fileId: order.photos[i],
                        onDelete: () async {
                          final ok = await AppConfirmSheet.show(context,
                              title: t.deletePhoto, message: t.deletePhotoConfirm,
                              confirmLabel: t.delete, cancelLabel: t.cancel);
                          if (ok && mounted) {
                            context.read<OrderProvider>().deletePhoto(widget.orderId, order.photos[i]);
                          }
                        },
                      ),
                    ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.md + 2),

        // Audio
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: Radii.rLarge,
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.voiceNote, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.textPrimary)),
              const SizedBox(height: 10),
              order.audioId == null
                  ? Center(child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(t.noRecording, style: TextStyle(fontSize: 11, color: c.textMuted))))
                  : ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: c.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
                        child: Icon(Icons.mic_rounded, color: c.primary),
                      ),
                      title: Text(t.voiceNote, style: TextStyle(fontSize: 14, color: c.textPrimary)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: c.danger),
                        onPressed: () async {
                          final ok = await AppConfirmSheet.show(context,
                              title: t.deleteRecording, message: t.deleteRecordingConfirm,
                              confirmLabel: t.delete, cancelLabel: t.cancel);
                          if (ok && mounted) {
                            context.read<OrderProvider>().deleteAudio(widget.orderId);
                          }
                        },
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'new': return Icons.fiber_new_rounded;
      case 'in_progress': return Icons.autorenew_rounded;
      case 'waiting': return Icons.hourglass_empty_rounded;
      case 'completed': return Icons.check_circle_rounded;
      case 'cancelled': return Icons.cancel_rounded;
      default: return Icons.circle_outlined;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final AppColors c;
  final Color? valueColor;

  const _InfoRow({required this.icon, required this.label, required this.value, required this.c, this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Icon(icon, size: 14, color: c.textSecondary),
        const SizedBox(width: Spacing.sm),
        Text('$label: ', style: TextStyle(fontSize: 11, color: c.textMuted)),
        Expanded(child: Text(value, style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, color: valueColor ?? c.textPrimary))),
      ],
    ),
  );
}

class _PhotoTile extends StatelessWidget {
  final String fileId;
  final VoidCallback onDelete;
  const _PhotoTile({required this.fileId, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return FutureBuilder<String?>(
      future: Storage.getToken(),
      builder: (_, snap) {
        final token = snap.data;
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: Radii.rMedium,
              child: token != null
                  ? CachedNetworkImage(
                      imageUrl: '${AppConfig.baseUrl}/files/$fileId',
                      fit: BoxFit.cover,
                      httpHeaders: {'Authorization': 'Bearer $token'},
                      placeholder: (_, __) => ColoredBox(color: c.surfaceVariant,
                          child: Center(child: SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: c.primary)))),
                      errorWidget: (_, __, ___) => ColoredBox(color: c.surfaceVariant,
                          child: Icon(Icons.broken_image_outlined, color: c.textMuted)),
                    )
                  : ColoredBox(color: c.surfaceVariant),
            ),
            Positioned(
              top: 3, right: 3,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(color: c.danger, shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, size: 11, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
