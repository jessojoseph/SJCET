import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:ui';
import '../widgets/glass_card.dart';
import '../theme/app_theme.dart';
import '../blocs/auth_bloc.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Start auth check
    context.read<AuthBloc>().add(CheckAuthStatusEvent());

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _startNavigationTimer();
  }

  void _startNavigationTimer() {
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        final authState = context.read<AuthBloc>().state;

        if (authState is AuthSuccess) {
          _navigateTo(HomeScreen(user: authState.user));
        } else {
          _navigateTo(const OnboardingScreen());
        }
      }
    });
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {},
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppTheme.mainBackgroundGradient,
                  stops: AppTheme.mainBackgroundStops,
                ),
              ),
            ),

            // 2. Academic Atmospheric Elements (Matching Authentication Screens)
            _buildBackdropElements(),

            // 3. Central Content
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_controller.value * 0.02), // Subtle pulse
                    child: Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Premium Logo Presentation
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Decorative outer glass ring
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryRed.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        // Inner glow - intensified
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryRed.withValues(
                                  alpha: 0.15,
                                ),
                                blurRadius: 60,
                                spreadRadius: 15,
                              ),
                            ],
                          ),
                        ),
                        // The Glass Logo Card - Larger
                        GlassCard(
                          borderRadius: 120, // Spherical look
                          blur: 35,
                          opacity: 0.12,
                          child: Container(
                            width: 200,
                            height: 200,
                            padding: const EdgeInsets.all(35),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.primaryRed.withValues(alpha: 0.05),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/college_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    // App Title
                    Text("CAMPUS NOTES", style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 12),
                    // College Name
                    Text(
                      "SJCET PALAI",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.charcoal.withValues(alpha: 0.4),
                        letterSpacing: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Integrated Loading & Footer
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Custom minimalist loader
                  SizedBox(
                    width: 50,
                    height: 2,
                    child: LinearProgressIndicator(
                      backgroundColor: AppTheme.charcoal.withValues(
                        alpha: 0.05,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryRed.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Smart Notes for Smart Students",
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackdropElements() {
    return Stack(
      children: [
        // Academic Atmospheric Elements
        Positioned(
          bottom: -80,
          right: -80,
          child: Opacity(
            opacity: 0.1,
            child: const Icon(
              Icons.history_edu,
              size: 400,
              color: AppTheme.charcoal,
            ),
          ),
        ),
        Positioned(
          top: 100,
          left: -40,
          child: Opacity(
            opacity: 0.08,
            child: const Icon(
              Icons.account_balance,
              size: 250,
              color: AppTheme.primaryRed,
            ),
          ),
        ),
      ],
    );
  }
}
