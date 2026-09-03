import 'dart:async';

import 'package:flutter/material.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.15, 0.7, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.72, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0, 0.75, curve: Curves.elasticOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.35, 1, curve: Curves.easeOutCubic),
      ),
    );
    _entryController.forward();
    _navigationTimer = Timer(const Duration(milliseconds: 2300), _openHome);
  }

  void _openHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 550),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0B1736);
    const blue = Color(0xFF2563EB);
    const cyan = Color(0xFF38BDF8);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [navy, Color(0xFF123C82), blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -70,
              child: _Glow(size: 250, color: cyan.withValues(alpha: 0.14)),
            ),
            Positioned(
              bottom: -120,
              left: -80,
              child: _Glow(
                size: 280,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_entryController, _pulseController]),
                builder: (context, child) => FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(
                        scale: _scaleAnimation.value +
                            (_pulseController.value * 0.025),
                        child: child,
                      ),
                      const SizedBox(height: 28),
                      SlideTransition(
                        position: _slideAnimation,
                        child: const Column(
                          children: [
                            Text(
                              'FITTRACK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 4,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'TRAIN WITH PURPOSE',
                              style: TextStyle(
                                color: Color(0xFFBAE6FD),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                child: Container(
                  width: 126,
                  height: 126,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(38),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: blue,
                    size: 66,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 42,
              child: Text(
                'YOUR STRONGER ROUTINE STARTS HERE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}