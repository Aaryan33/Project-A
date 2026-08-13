import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_app_bar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          authState.user?.email ?? AppConstants.defaultAdminEmail,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
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
                    title: const Text('Dark Industrial Theme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Toggle between dark and light UI theme', style: TextStyle(fontSize: 11)),
                    secondary: const Icon(Icons.dark_mode_rounded, color: AppColors.accentOrange),
                    value: isDark,
                    activeColor: AppColors.accentOrange,
                    onChanged: (val) => ref.read(themeModeProvider.notifier).toggleTheme(),
                  ),
                  const Divider(height: 1),
                  // const ListTile(
                  //   leading: Icon(Icons.notifications_active_rounded, color: AppColors.royalBlue),
                  //   title: Text('Push Notification Broadcasts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  //   subtitle: Text('FCM multi-device sync alerts active', style: TextStyle(fontSize: 11)),
                  //   trailing: Icon(Icons.check_circle_rounded, color: AppColors.statusDelivered, size: 20),
                  // ),
                  // const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.backup_rounded, color: AppColors.purpleAccent),
                    title: const Text('Backup Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Create local Hive snapshot backup', style: TextStyle(fontSize: 11)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Backup created successfully! All orders saved locally.')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

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

class _CompanyRow extends StatelessWidget {
  final String label;
  final String value;

  const _CompanyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
