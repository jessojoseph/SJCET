import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/glass_card.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../blocs/auth_bloc.dart';
import '../../utils/responsive.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _answerController = TextEditingController();
  final _newPasswordController = TextEditingController();

  UserModel? _foundUser;
  int _step = 1; // 1: Email, 2: Question/Answer, 3: New Password

  void _findUser() {
    if (_emailController.text.isEmpty) return;
    context.read<AuthBloc>().add(FindUserEvent(_emailController.text.trim()));
  }

  void _verifyAnswer() {
    if (_answerController.text.trim().toLowerCase() ==
        _foundUser!.securityAnswer) {
      setState(() => _step = 3);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incorrect answer. Please try again.")),
      );
    }
  }

  void _resetPassword() {
    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 6 characters."),
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      ResetPasswordEvent(_foundUser!.email, _newPasswordController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is UserFound) {
            setState(() {
              _foundUser = state.user;
              _step = 2;
            });
          } else if (state is PasswordResetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Password reset successful! Please login."),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is AuthFailed) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Stack(
            children: [
              // Background Gradient
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

              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: context.hp(2)),
                      IconButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: context.hp(4)),
                      Text(
                        "Account\nRecovery",
                        style: GoogleFonts.outfit(
                          fontSize: context.sp(42),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _step == 1
                            ? "Enter your email to locate your account"
                            : _step == 2
                            ? "Verify your identity"
                            : "Create a new security key",
                        style: GoogleFonts.outfit(
                          color: Colors.white54,
                          fontSize: context.sp(16),
                        ),
                      ),
                      SizedBox(height: context.hp(5)),

                      if (_step == 1) _buildEmailStep(isLoading),
                      if (_step == 2) _buildVerifyStep(isLoading),
                      if (_step == 3) _buildResetStep(isLoading),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmailStep(bool isLoading) {
    return Column(
      children: [
        _buildRecoverField(
          controller: _emailController,
          label: "CAMPUS EMAIL",
          hint: "example@sjcet.ac.in",
          icon: Icons.alternate_email_rounded,
          enabled: !isLoading,
        ),
        SizedBox(height: context.hp(5)),
        _buildActionButton("LOCATE ACCOUNT", _findUser, isLoading),
      ],
    );
  }

  Widget _buildVerifyStep(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SECURITY QUESTION",
          style: GoogleFonts.outfit(
            color: AppTheme.goldAccent,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _foundUser!.securityQuestion,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: context.sp(18),
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 30),
        _buildRecoverField(
          controller: _answerController,
          label: "YOUR ANSWER",
          hint: "Enter matching answer",
          icon: Icons.security_outlined,
          enabled: !isLoading,
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => setState(() => _step = 1),
          child: Text(
            "Change Email?",
            style: GoogleFonts.outfit(
              color: AppTheme.goldAccent.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ),
        SizedBox(height: context.hp(5)),
        _buildActionButton("VERIFY IDENTITY", _verifyAnswer, isLoading),
      ],
    );
  }

  Widget _buildResetStep(bool isLoading) {
    return Column(
      children: [
        _buildRecoverField(
          controller: _newPasswordController,
          label: "NEW SECURITY KEY",
          hint: "Min 6 characters",
          icon: Icons.key_outlined,
          isPassword: true,
          enabled: !isLoading,
        ),
        SizedBox(height: context.hp(5)),
        _buildActionButton("RESET PASSWORD", _resetPassword, isLoading),
      ],
    );
  }

  Widget _buildRecoverField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        GlassCard(
          borderRadius: 18,
          blur: 20,
          opacity: 0.05,
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            enabled: enabled,
            style: GoogleFonts.outfit(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppTheme.goldAccent, size: 20),
              hintText: hint,
              hintStyle: GoogleFonts.outfit(
                color: Colors.white12,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.02),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, VoidCallback onTap, bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [AppTheme.accentIndigo, Color(0xFF3F3D89)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentIndigo.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
        ),
      ),
    );
  }
}
