import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('auth_box');
  await Hive.openBox('new_order_details_box');
  runApp(const ProviderScope(child: UmiyaPnjApp()));
}

class UmiyaPnjApp extends ConsumerWidget {
  const UmiyaPnjApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'App Name',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        final mode = ref.watch(themeModeProvider);
        final isDark = mode == ThemeMode.dark;
        return AnimatedTheme(
          data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: router,
    );
  }
}



// -------------- old code version --------------

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'core/theme/app_theme.dart';
// import 'presentation/providers/theme_provider.dart';
// import 'presentation/routes/app_router.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const ProviderScope(child: UmiyaPnjApp()));
// }

// class UmiyaPnjApp extends ConsumerWidget {
//   const UmiyaPnjApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final router = ref.watch(routerProvider);
//     final themeMode = ref.watch(themeModeProvider);

//     return MaterialApp.router(
//       title: 'App Name',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       darkTheme: AppTheme.darkTheme,
//       themeMode: themeMode,
//       routerConfig: router,
//     );
//   }
// }
