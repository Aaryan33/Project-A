import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../providers/notification_providers.dart';
import '../widgets/custom_app_bar.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notification Center',
        showBackButton: true,
        extraActions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: Colors.white),
            onPressed: () {
              ref.read(notificationServiceProvider).markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read.')),
              );
            },
            tooltip: 'Mark All Read',
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('New trip updates will appear here in real-time.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return Dismissible(
                key: Key(notif.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  ref.read(notificationServiceProvider).deleteNotification(notif.id);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.redAccent,
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: notif.isRead
                        ? (isDark ? AppColors.darkCard : AppColors.lightSurface)
                        : AppColors.accentOrange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: notif.isRead
                          ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                          : AppColors.accentOrange.withOpacity(0.5),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getIconColor(notif.type).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getIcon(notif.type), color: _getIconColor(notif.type), size: 20),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notif.title,
                          style: TextStyle(
                            fontWeight: notif.isRead ? FontWeight.bold : FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          DateFormatter.formatDateTime(notif.timestamp),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        notif.body,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    onTap: () {
                      ref.read(notificationServiceProvider).markAsRead(notif.id);
                      if (notif.orderId != null) {
                        context.push('/order-details/${notif.orderId}');
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentOrange)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'order_created':
        return Icons.add_circle_outline_rounded;
      case 'order_updated':
        return Icons.edit_notifications_rounded;
      case 'order_deleted':
        return Icons.delete_outline_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'order_created':
        return AppColors.accentOrange;
      case 'order_updated':
        return AppColors.royalBlue;
      case 'order_deleted':
        return Colors.redAccent;
      default:
        return AppColors.statusDelivered;
    }
  }
}
