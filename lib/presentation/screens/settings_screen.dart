import 'dart:io';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/services/firestore_service.dart';
import '../../domain/models/order_model.dart';
import '../providers/auth_provider.dart';
import '../providers/order_providers.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_app_bar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isExporting = false;
  bool _isSyncing = false;

  // Future<void> _forceSyncFirebase(BuildContext context) async {
  //   setState(() => _isSyncing = true);
  //   try {
  //     final count = await FirestoreService().uploadAllSeedDataToFirestore(force: true);
  //     if (mounted) {
  //       setState(() => _isSyncing = false);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Successfully synced $count historical trip records & 5 admin accounts to Cloud Firestore!'),
  //           backgroundColor: AppColors.statusDelivered,
  //           duration: const Duration(seconds: 4),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() => _isSyncing = false);
  //       final String errMsg = e.toString().contains('permission-denied')
  //           ? 'Firestore Rules Locked: Go to Firebase Console -> Firestore -> Rules and set allow read, write: if true;'
  //           : 'Firebase Sync Note: Verify credentials in firebase_options.dart ($e)';
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(errMsg),
  //           backgroundColor: Colors.red,
  //           duration: const Duration(seconds: 6),
  //         ),
  //       );
  //     }
  //   }
  // }

  Future<void> _exportCloudDataToExcel(BuildContext context) async {
    setState(() => _isExporting = true);

    try {
      final repo = ref.read(orderRepositoryProvider);
      final List<OrderModel> orders = await repo.getOrders();

      final excel = Excel.createExcel();
      final Sheet sheet = excel['Trip Orders Backup'];
      excel.setDefaultSheet('Trip Orders Backup');

      // Add Headers
      final headers = [
        'Order ID',
        'Date',
        'Company',
        'Vehicle Number',
        'From Location',
        'To Customer',
        'Material',
        'Gross Qty (MT)',
        'Net Weight UKAI (MT)',
        'Expenses (Rs)',
        'Status',
        'Remarks',
        'Created By',
      ];

      sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

      // Add Data Rows
      for (final o in orders) {
        sheet.appendRow([
          TextCellValue(o.id),
          TextCellValue(DateFormatter.formatDate(o.date)),
          TextCellValue(o.company),
          TextCellValue(o.vehicleNumber),
          TextCellValue(o.fromLocation),
          TextCellValue(o.toLocation),
          TextCellValue(o.material),
          DoubleCellValue(o.quantity),
          DoubleCellValue(o.netWeightUkai ?? 0.0),
          DoubleCellValue(o.totalExpense),
          TextCellValue(o.status),
          TextCellValue(o.remarks ?? ''),
          TextCellValue(o.createdBy),
        ]);
      }

      final directory = await getApplicationDocumentsDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filePath = '${directory.path}/UMIYA_PNJ_Orders_Backup_$timestamp.xlsx';
      final fileBytes = excel.encode();

      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);

        if (mounted) {
          setState(() => _isExporting = false);
          _showBackupSuccessDialog(context, filePath, orders.length);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showBackupSuccessDialog(BuildContext context, String filePath, int totalRecords) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.statusDelivered, size: 28),
            SizedBox(width: 10),
            Text('Backup Complete', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Successfully exported $totalRecords trip records from database into an Excel file format.',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SelectableText(
                'File Saved At:\n$filePath',
                style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.black87),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await OpenFilex.open(filePath);
            },
            icon: const Icon(Icons.file_open_rounded, size: 18),
            label: const Text('OPEN EXCEL FILE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'System Settings',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accentOrange.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.accentOrange,
                    child: Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.user?.name ?? 'Admin User',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Mobile: ${authState.user?.mobileNumber ?? '9876543210'}',
                          style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('PREFERENCES & CONTROLS'),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Change Theme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Select between dark and light theme', style: TextStyle(fontSize: 11)),
                    secondary: const Icon(Icons.dark_mode_rounded, color: AppColors.accentOrange),
                    value: isDark,
                    activeColor: AppColors.accentOrange,
                    onChanged: (val) => ref.read(themeModeProvider.notifier).toggleTheme(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cloud_download_rounded, color: AppColors.statusDelivered),
                    title: const Text('Backup Cloud Data to Excel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Export all trips into an Excel file', style: TextStyle(fontSize: 11)),
                    trailing: _isExporting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentOrange))
                        : const Icon(Icons.download_for_offline_rounded, color: AppColors.accentOrange),
                    onTap: _isExporting ? null : () => _exportCloudDataToExcel(context),
                  ),
                  // const Divider(height: 1),
                  // ListTile(
                  //   leading: const Icon(Icons.cloud_upload_rounded, color: AppColors.royalBlue),
                  //   title: const Text('Sync All Data to Firebase', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  //   subtitle: const Text('Upload all historical trips (126 August trips + July + June) & admins to Cloud Firestore', style: TextStyle(fontSize: 11)),
                  //   trailing: _isSyncing
                  //       ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.royalBlue))
                  //       : const Icon(Icons.sync_rounded, color: AppColors.royalBlue),
                  //   onTap: _isSyncing ? null : () => _forceSyncFirebase(context),
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/login');
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('LOGOUT', style: TextStyle(fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.accentOrange, letterSpacing: 0.8),
      ),
    );
  }
}




// ------------- old code version ------------------

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../../core/theme/app_colors.dart';
// import '../../core/constants/app_constants.dart';
// import '../providers/auth_provider.dart';
// import '../providers/theme_provider.dart';
// import '../widgets/custom_app_bar.dart';

// class SettingsScreen extends ConsumerWidget {
//   const SettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authProvider);
//     final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

//     return Scaffold(
//       appBar: const CustomAppBar(
//         title: 'System Settings',
//         showBackButton: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: isDark ? AppColors.darkCard : AppColors.lightSurface,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: AppColors.accentOrange.withOpacity(0.5)),
//               ),
//               child: Row(
//                 children: [
//                   const CircleAvatar(
//                     radius: 28,
//                     backgroundColor: AppColors.accentOrange,
//                     child: Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 30),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           authState.user?.name ?? 'Admin User',
//                           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           authState.user?.email ?? AppConstants.defaultAdminEmail,
//                           style: const TextStyle(fontSize: 12, color: Colors.grey),
//                         ),
//                         const SizedBox(height: 4),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),


//             _buildSectionHeader('PREFERENCES & CONTROLS'),
//             Container(
//               decoration: BoxDecoration(
//                 color: isDark ? AppColors.darkCard : AppColors.lightSurface,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
//               ),
//               child: Column(
//                 children: [
//                   SwitchListTile(
//                     title: const Text('Dark Industrial Theme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                     subtitle: const Text('Toggle between dark and light UI theme', style: TextStyle(fontSize: 11)),
//                     secondary: const Icon(Icons.dark_mode_rounded, color: AppColors.accentOrange),
//                     value: isDark,
//                     activeColor: AppColors.accentOrange,
//                     onChanged: (val) => ref.read(themeModeProvider.notifier).toggleTheme(),
//                   ),
//                   const Divider(height: 1),
//                   // const ListTile(
//                   //   leading: Icon(Icons.notifications_active_rounded, color: AppColors.royalBlue),
//                   //   title: Text('Push Notification Broadcasts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                   //   subtitle: Text('FCM multi-device sync alerts active', style: TextStyle(fontSize: 11)),
//                   //   trailing: Icon(Icons.check_circle_rounded, color: AppColors.statusDelivered, size: 20),
//                   // ),
//                   // const Divider(height: 1),
//                   ListTile(
//                     leading: const Icon(Icons.backup_rounded, color: AppColors.purpleAccent),
//                     title: const Text('Backup Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                     subtitle: const Text('Create local Hive snapshot backup', style: TextStyle(fontSize: 11)),
//                     onTap: () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Backup created successfully! All orders saved locally.')),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),

//             const SizedBox(height: 32),

//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   ref.read(authProvider.notifier).logout();
//                   context.go('/login');
//                 },
//                 icon: const Icon(Icons.logout_rounded),
//                 label: const Text('LOGOUT', style: TextStyle(fontWeight: FontWeight.w800)),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.redAccent,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10, top: 4),
//       child: Text(
//         title,
//         style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.accentOrange, letterSpacing: 0.8),
//       ),
//     );
//   }
// }

// class _CompanyRow extends StatelessWidget {
//   final String label;
//   final String value;

//   const _CompanyRow({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
//         Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
//       ],
//     );
//   }
// }
