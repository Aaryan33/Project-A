import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../providers/notification_providers.dart';
import '../providers/theme_provider.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? extraActions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.extraActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  void _safeNavigate(BuildContext context, String targetLocation) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    if (currentLocation == targetLocation) return;
    context.push(targetLocation);
  }

  void _showLeftDrawerMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Menu',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.78,
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(4, 0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Business name',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.accentOrange,
                          letterSpacing: 0.5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Navigation Menu',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Menu Item 1: New order details
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    tileColor: AppColors.accentOrange.withOpacity(0.12),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.accentOrange,
                      child: Icon(Icons.assignment_add, color: Colors.white, size: 20),
                    ),
                    title: const Text('New order details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.accentOrange),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/new-order-details');
                    },
                  ),
                  const SizedBox(height: 14),

                  // Menu Item 2: Parsing details reminder
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    tileColor: AppColors.royalBlue.withOpacity(0.12),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.royalBlue,
                      child: Icon(Icons.alarm_rounded, color: Colors.white, size: 20),
                    ),
                    title: const Text('Parsing details reminder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.royalBlue),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/parsing-reminders');
                    },
                  ),
                  const Spacer(),
                  
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.slateNavy,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/dashboard');
                }
              },
            )
          : IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
              onPressed: () => _showLeftDrawerMenu(context),
              tooltip: 'Menu',
            ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              AppConstants.appTitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: AppColors.accentOrange,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        if (extraActions != null) ...extraActions!,
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
          tooltip: 'Toggle Theme',
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
              onPressed: () => _safeNavigate(context, '/notifications'),
              tooltip: 'Notifications',
            ),
            if (unreadCount > 0)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.accentOrange,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
          onPressed: () => _safeNavigate(context, '/settings'),
          tooltip: 'Settings',
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}





// ------------ old code version ------------

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../../core/theme/app_colors.dart';
// import '../../core/constants/app_constants.dart';
// import '../providers/notification_providers.dart';
// import '../providers/theme_provider.dart';

// class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
//   final String title;
//   final bool showBackButton;
//   final List<Widget>? extraActions;

//   const CustomAppBar({
//     super.key,
//     required this.title,
//     this.showBackButton = false,
//     this.extraActions,
//   });

//   @override
//   Size get preferredSize => const Size.fromHeight(64);

//   void _safeNavigate(BuildContext context, String targetLocation) {
//     final currentLocation = GoRouterState.of(context).matchedLocation;
//     if (currentLocation == targetLocation) return;
//     context.push(targetLocation);
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final unreadCount = ref.watch(unreadNotificationCountProvider);
//     final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

//     return AppBar(
//       elevation: 0,
//       backgroundColor: AppColors.slateNavy,
//       leading: showBackButton
//           ? IconButton(
//               icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
//               onPressed: () => context.pop(),
//             )
//           : null,
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           FittedBox(
//             fit: BoxFit.scaleDown,
//             alignment: Alignment.centerLeft,
//             child: Text(
//               AppConstants.appTitle,
//               style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w800,
//                 letterSpacing: 0.3,
//                 color: AppColors.accentOrange,
//               ),
//             ),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w400,
//               color: Colors.white70,
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//       actions: [
//         if (extraActions != null) ...extraActions!,
//         IconButton(
//           icon: Icon(
//             isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
//             color: Colors.white,
//             size: 20,
//           ),
//           onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
//           tooltip: 'Toggle Theme',
//         ),
//         Stack(
//           alignment: Alignment.center,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
//               onPressed: () => _safeNavigate(context, '/notifications'),
//               tooltip: 'Notifications',
//             ),
//             if (unreadCount > 0)
//               Positioned(
//                 top: 10,
//                 right: 10,
//                 child: Container(
//                   padding: const EdgeInsets.all(3),
//                   decoration: const BoxDecoration(
//                     color: AppColors.accentOrange,
//                     shape: BoxShape.circle,
//                   ),
//                   constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
//                   child: Text(
//                     unreadCount > 9 ? '9+' : unreadCount.toString(),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 9,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         IconButton(
//           icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
//           onPressed: () => _safeNavigate(context, '/settings'),
//           tooltip: 'Settings',
//         ),
//         const SizedBox(width: 4),
//       ],
//     );
//   }
// }
