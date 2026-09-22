import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _roadDashAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _logoOpacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _roadDashAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen();
      }
    });
  }

  void _navigateToNextScreen() {
    if (!mounted) return;
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      context.go('/');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      body: Stack(
        children: [
          // 1. Ambient Background Radial Glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.3),
                  radius: 1.15,
                  colors: [
                    Color(0xFF1C2541),
                    Color(0xFF0B132B),
                    Color(0xFF070B19),
                  ],
                ),
              ),
            ),
          ),

          // Ambient Cyan & Orange soft glow circles
          Positioned(
            top: screenSize.height * 0.20,
            left: screenSize.width * 0.5 - 130,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentOrange.withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withValues(alpha: 0.14),
                    blurRadius: 110,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          // 2. Center Branding (MTT Logo & Title)
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoOpacityAnimation.value,
                  child: Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // MTT Logo Frame
                        Container(
                          width: 110,
                          height: 110,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withValues(alpha: 0.35),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                              BoxShadow(
                                color: AppColors.accentOrange.withValues(alpha: 0.25),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/app_icon.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        // Main Title: UMIYA IMPEX & PNJ VENTURES
                        const Text(
                          'Business Name',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. Highway Road Track at Bottom
          Positioned(
            bottom: screenSize.height * 0.16,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Top Road Accent Line (Cyan Glow)
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.cyanAccent.withValues(alpha: 0.8),
                        AppColors.accentOrange.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Asphalt Road Bed
                Container(
                  height: 38,
                  color: const Color(0xFF151D33),
                  child: AnimatedBuilder(
                    animation: _roadDashAnimation,
                    builder: (context, child) {
                      final offset = _roadDashAnimation.value * 60;
                      return CustomPaint(
                        painter: RoadDashesPainter(dashOffset: offset),
                        size: Size(screenSize.width, 38),
                      );
                    },
                  ),
                ),
                // Bottom Guard Rail Line
                Container(
                  height: 2,
                  color: Colors.white10,
                ),
              ],
            ),
          ),

          // 4. Static Centered Realistic Truck 
          Positioned(
            bottom: screenSize.height * 0.16 + 6,
            left: (screenSize.width - 270) / 2,
            child: SizedBox(
              width: 270,
              height: 142,
              child: Image.asset(
                'assets/images/tanker_truck.png',
                width: 270,
                height: 142,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Highway Animated Dashes
class RoadDashesPainter extends CustomPainter {
  final double dashOffset;

  RoadDashesPainter({required this.dashOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const dashWidth = 24.0;
    const dashSpace = 24.0;

    double startX = -dashOffset % (dashWidth + dashSpace);

    while (startX < size.width + dashWidth) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant RoadDashesPainter oldDelegate) {
    return oldDelegate.dashOffset != dashOffset;
  }
}

