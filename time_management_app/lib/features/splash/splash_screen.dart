import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      init: SplashController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFF0D0D1A),
          body: Stack(
            children: [
              // --- Background animated circles ---
              _AnimatedBackground(),

              // --- Center content ---
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    AnimatedBuilder(
                      animation: controller.logoAnimation,
                      builder: (_, __) => Transform.scale(
                        scale: controller.logoAnimation.value,
                        child: Opacity(
                          opacity: controller.logoAnimation.value.clamp(0.0, 1.0),
                          child: _LogoWidget(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // App name
                    AnimatedBuilder(
                      animation: controller.textAnimation,
                      builder: (_, __) => Opacity(
                        opacity: controller.textAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, 20.0 * (1 - controller.textAnimation.value)),
                          child: Column(
                            children: [
                              Text(
                                'TimeWise',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Quản lý thời gian thông minh',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white54,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- Loading indicator ở dưới ---
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: controller.textAnimation,
                  builder: (_, __) => Opacity(
                    opacity: controller.textAnimation.value,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 120,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFF6C63FF),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(() => Text(
                          controller.statusText.value,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Logo Widget ──────────────────────────────────────────────────────────────

class _LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C63FF), Color(0xFF3D5AFE)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.timer_rounded,
        color: Colors.white,
        size: 52,
      ),
    );
  }
}

// ─── Animated Background ──────────────────────────────────────────────────────

class _AnimatedBackground extends StatefulWidget {
  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        size: size,
        painter: _BackgroundPainter(_controller.value),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double progress;
  _BackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Circle 1 — top left
    paint.color = const Color(0xFF6C63FF).withOpacity(0.12 + 0.06 * progress);
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.15),
      120 + 20 * progress,
      paint,
    );

    // Circle 2 — top right
    paint.color = const Color(0xFF3D5AFE).withOpacity(0.10 + 0.05 * progress);
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.1),
      90 + 15 * progress,
      paint,
    );

    // Circle 3 — bottom center
    paint.color = const Color(0xFF6C63FF).withOpacity(0.08 + 0.07 * (1 - progress));
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.9),
      140 + 25 * (1 - progress),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) => old.progress != progress;
}