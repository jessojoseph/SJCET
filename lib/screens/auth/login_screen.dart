import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/glass_card.dart';
import '../../theme/app_theme.dart';
import '../../blocs/auth_bloc.dart';
import '../../utils/responsive.dart';
import '../home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginUserEvent(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text(
            //       'Access Granted. Welcome back, ${state.user.name}!',
            //     ),
            //     backgroundColor: Colors.indigo,
            //   ),
            // );
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomeScreen(user: state.user),
              ),
              (route) => false,
            );
          } else if (state is AuthFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Stack(
            children: [
              // 1. Base Gradient Background
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

              // 2. Academic Atmospheric Elements
              Positioned(
                bottom: -context.hp(10),
                right: -context.wp(20),
                child: Opacity(
                  opacity: 0.05,
                  child: Icon(
                    Icons.history_edu,
                    size: context.wp(100),
                    color: AppTheme.charcoal,
                  ),
                ),
              ),
              Positioned(
                top: context.hp(10),
                left: -context.wp(10),
                child: Opacity(
                  opacity: 0.08,
                  child: Icon(
                    Icons.account_balance,
                    size: context.wp(60),
                    color: AppTheme.primaryRed,
                  ),
                ),
              ),

              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),

                          // Hero Section with Logo
                          Hero(
                            tag: 'college_logo',
                            child: Container(
                              padding: EdgeInsets.all(
                                context.isSmallScreen ? 15 : 20,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.primaryRed.withValues(
                                  alpha: 0.03,
                                ),
                                border: Border.all(
                                  color: AppTheme.primaryRed.withValues(
                                    alpha: 0.05,
                                  ),
                                ),
                              ),
                              child: Image.asset(
                                'assets/images/college_logo.png',
                                height: context.isSmallScreen
                                    ? 60
                                    : context.sp(80),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Text(
                            "CAMPUS PORTAL",
                            style: GoogleFonts.outfit(
                              fontSize: context.sp(14),
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryRed,
                              letterSpacing: 6,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Welcome back to\nyour smart workspace",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: context.sp(26),
                              fontWeight: FontWeight.w300,
                              color: AppTheme.charcoal,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 35),

                          _buildAcademicGlassInput(
                            controller: _emailController,
                            label: "IDENTIFICATION EMAIL",
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => !v!.contains('@')
                                ? "Enter valid campus ID"
                                : null,
                            enabled: !isLoading,
                          ),
                          const SizedBox(height: 20),
                          _buildAcademicGlassInput(
                            controller: _passwordController,
                            label: "SECURE ACCESS KEY",
                            icon: Icons.lock_open_rounded,
                            isPassword: true,
                            validator: (v) =>
                                v!.isEmpty ? "Access key required" : null,
                            enabled: !isLoading,
                          ),
                          const SizedBox(height: 14),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgotPasswordScreen(),
                                      ),
                                    ),
                              child: Text(
                                "Forgot Password",
                                style: GoogleFonts.outfit(
                                  color: AppTheme.primaryRed.withValues(
                                    alpha: 0.8,
                                  ),
                                  fontSize: context.sp(12),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 35),

                          // Signature Button
                          GestureDetector(
                            onTap: isLoading ? null : _handleLogin,
                            child: Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryRed.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.primaryRed,
                                    AppTheme.secondaryRed,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        "Login",
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 2,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 35),
                          Text(
                            "SJCET PALAI • SMART NOTES",
                            style: GoogleFonts.outfit(
                              color: AppTheme.charcoal.withValues(alpha: 0.3),
                              fontSize: context.sp(11),
                              letterSpacing: 4,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen(
                                            selectedRole: 'Student',
                                          ),
                                    ),
                                  ),
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.outfit(
                                  color: AppTheme.charcoal,
                                  fontSize: context.sp(15),
                                ),
                                children: [
                                  const TextSpan(
                                    text: "New to Campus? ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Join Now",
                                    style: TextStyle(
                                      color: AppTheme.primaryRed,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 35),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAcademicGlassInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: AppTheme.charcoal.withValues(alpha: 0.4),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ),
        GlassCard(
          borderRadius: 18,
          blur: 20,
          opacity: 0.05,
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            validator: validator,
            enabled: enabled,
            style: GoogleFonts.outfit(color: AppTheme.charcoal, fontSize: 15),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: AppTheme.primaryRed.withValues(alpha: 0.8),
                size: 18,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.02),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: AppTheme.charcoal.withValues(alpha: 0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: AppTheme.primaryRed,
                  width: 1.2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: Colors.redAccent.withValues(alpha: 0.3),
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.02),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
