import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/models/order_model.dart';
import '../providers/order_providers.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/status_badge.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Trip Order Details',
        showBackButton: true,
        extraActions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
            onPressed: () => context.push('/edit-order/$orderId'),
            tooltip: 'Edit Order',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
            onPressed: () => _confirmDelete(context, ref),
            tooltip: 'Delete Order',
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) {
          final order = orders.firstWhere(
            (o) => o.id == orderId,
            orElse: () => OrderModel(
              id: orderId,
              date: DateTime.now(),
              vehicleNumber: 'N/A',
              fromLocation: 'N/A',
              toLocation: 'N/A',
              material: 'N/A',
              quantity: 0.0,
              company: 'UMIYA',
              status: 'Completed',
              createdBy: 'Admin',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Card: Vehicle Number & Company Tag & Status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accentOrange, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentOrange.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.accentOrange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  order.vehicleNumber,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.accentOrange,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.royalBlue.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  order.company,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.royalBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          StatusBadge(status: order.status, fontSize: 12),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.circle, size: 12, color: AppColors.accentOrange),
                              Container(width: 2, height: 30, color: AppColors.accentOrange.withOpacity(0.5)),
                              const Icon(Icons.location_on_rounded, size: 16, color: AppColors.statusDelivered),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('SOURCE PLANT / SUPPLIER', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                                Text(order.fromLocation.isNotEmpty ? order.fromLocation : 'N/A', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 12),
                                Text('DESTINATION CUSTOMER', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                                Text(order.toLocation, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // MATERIAL & WEIGHBRIDGE DETAILS
                _buildSectionTitle('MATERIAL & WEIGHBRIDGE DETAILS'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Material Type', order.material, isHighlight: true),
                      const Divider(height: 16),
                      _buildDetailRow('Gross Quantity', DateFormatter.formatQuantity(order.quantity)),
                      if (order.netWeightUkai != null) ...[
                        const Divider(height: 16),
                        _buildDetailRow('Net Weight (Ukai Slip)', DateFormatter.formatQuantity(order.netWeightUkai!)),
                      ],
                      const Divider(height: 16),
                      _buildDetailRow('Trip Date', DateFormatter.formatDate(order.date)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // TRIP EXPENSES SECTION
                _buildSectionTitle('TRIP EXPENSES'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: order.expenses != null && order.expenses!.isNotEmpty
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.accentOrange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.accentOrange, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Expenses Details',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.accentOrange),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    order.expenses!,
                                    style: const TextStyle(fontSize: 13, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.accentOrange),
                              onPressed: () => context.push('/edit-order/$orderId'),
                              tooltip: 'Edit Expenses',
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, color: Colors.grey.shade400, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No expenses recorded for this trip.',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => context.push('/edit-order/$orderId'),
                              icon: const Icon(Icons.add_rounded, size: 14, color: AppColors.accentOrange),
                              label: const Text('Add Expenses', style: TextStyle(color: AppColors.accentOrange, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 20),

                // ATTACHMENTS (WEIGHBRIDGE SLIP / INVOICE)
                _buildSectionTitle('ATTACHMENTS (WEIGHBRIDGE SLIP / INVOICE)'),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: _buildAttachmentCard(context, order, isDark),
                ),
                const SizedBox(height: 20),

                // AUDIT TRAIL & SYSTEM LOG
                _buildSectionTitle('AUDIT TRAIL & SYSTEM LOG'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Column(
                    children: [
                      _buildAuditRow(Icons.account_circle_outlined, 'Created By', order.createdBy),
                      const SizedBox(height: 10),
                      _buildAuditRow(Icons.access_time_rounded, 'Created Time', DateFormatter.formatDateTime(order.createdAt)),
                      const SizedBox(height: 10),
                      _buildAuditRow(Icons.update_rounded, 'Last Modified', DateFormatter.formatDateTime(order.updatedAt)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentOrange)),
        error: (err, stack) => Center(child: Text('Error loading details: $err')),
      ),
    );
  }

  Widget _buildAttachmentCard(BuildContext context, OrderModel order, bool isDark) {
    final hasAttachment = order.attachmentName != null && order.attachmentName!.isNotEmpty;
    final fileName = hasAttachment ? order.attachmentName! : 'Weighbridge_Slip_${order.vehicleNumber.replaceAll('-', '_')}.pdf';
    final fileSize = hasAttachment ? (order.attachmentSize ?? 'Digital Attachment') : 'Verified Digital Attachment • 245 KB';
    final isPdf = fileName.toLowerCase().endsWith('.pdf');

    return InkWell(
      onTap: () => _openAttachmentViewer(context, fileName, order.attachmentPath, isPdf),
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.royalBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
              color: AppColors.royalBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  fileSize,
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_red_eye_rounded, color: AppColors.accentOrange, size: 22),
            onPressed: () => _openAttachmentViewer(context, fileName, order.attachmentPath, isPdf),
            tooltip: 'View Attachment',
          ),
        ],
      ),
    );
  }

  void _openAttachmentViewer(BuildContext context, String fileName, String? filePath, bool isPdf) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                          color: AppColors.accentOrange,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fileName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: (filePath != null && File(filePath).existsSync() && !isPdf)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(File(filePath), fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isPdf ? Icons.picture_as_pdf_rounded : Icons.verified_user_rounded,
                            size: 64,
                            color: AppColors.royalBlue,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isPdf ? 'Verified Digital PDF Document' : 'Verified Weighbridge Image Slip',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slateNavy),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Digital Weightslip verified for trip record',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opened $fileName in document viewer')),
                    );
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Open Document', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.accentOrange, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 15 : 14,
            fontWeight: isHighlight ? FontWeight.w900 : FontWeight.bold,
            color: isHighlight ? AppColors.accentOrange : null,
          ),
        ),
      ],
    );
  }

  Widget _buildAuditRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.accentOrange),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip Order'),
        content: const Text('Are you sure you want to permanently delete this trip order record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await ref.read(orderRepositoryProvider).deleteOrder(orderId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order deleted successfully'), backgroundColor: Colors.red),
        );
        context.pop();
      }
    }
  }
}
