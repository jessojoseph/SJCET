import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/glass_card.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../blocs/auth_bloc.dart';
import '../../utils/responsive.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String selectedRole;
  const RegisterScreen({super.key, required this.selectedRole});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _answerController = TextEditingController();

  String _selectedQuestion = "What was the name of your first school?";
  final List<String> _securityQuestions = [
    "What was the name of your first school?",
    "What is your mother's maiden name?",
    "What was the name of your first pet?",
    "In what city were you born?",
    "What is your favorite teacher's name?",
  ];

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      final user = UserModel(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: widget.selectedRole,
        securityQuestion: _selectedQuestion,
        securityAnswer: _answerController.text.trim().toLowerCase(),
      );

      context.read<AuthBloc>().add(RegisterUserEvent(user));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration Successful! Please login.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
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
              // 1. Dynamic Background
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

              // 2. Artistic Background Accents
              Positioned(
                top: -context.hp(5),
                right: -context.wp(10),
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(
                    Icons.school,
                    size: context.wp(80),
                    color: AppTheme.goldAccent,
                  ),
                ),
              ),
              Positioned(
                bottom: context.hp(5),
                left: -context.wp(10),
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(
                    Icons.menu_book,
                    size: context.wp(50),
                    color: AppTheme.accentIndigo,
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: context.hp(1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.pop(context),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.05,
                              ),
                              padding: const EdgeInsets.all(12),
                            ),
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          Image.asset(
                            'assets/images/college_logo.png',
                            height: context.isSmallScreen ? 40 : 50,
                            opacity: const AlwaysStoppedAnimation(0.8),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: context.hp(2)),
                              Text(
                                "Create Your\nAcademy ID",
                                style: GoogleFonts.outfit(
                                  fontSize: context.sp(36),
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.1,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.goldAccent.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppTheme.goldAccent.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "Joining as: ${widget.selectedRole}",
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.goldAccent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: context.sp(13),
                                  ),
                                ),
                              ),
                              SizedBox(height: context.hp(3)),

                              _buildPremiumField(
                                controller: _nameController,
                                label: "Student Name",
                                hint: "Enter your full name",
                                icon: Icons.badge_outlined,
                                validator: (v) =>
                                    v!.isEmpty ? "Name is required" : null,
                                enabled: !isLoading,
                              ),
                              const SizedBox(height: 15),
                              _buildPremiumField(
                                controller: _emailController,
                                label: "Campus Email",
                                hint: "example@sjcet.ac.in",
                                icon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) => !v!.contains('@')
                                    ? "Use valid college email"
                                    : null,
                                enabled: !isLoading,
                              ),
                              const SizedBox(height: 15),
                              _buildPremiumField(
                                controller: _passwordController,
                                label: "Security Key",
                                hint: "Create a strong password",
                                icon: Icons.key_outlined,
                                isPassword: true,
                                validator: (v) => v!.length < 6
                                    ? "Min 6 characters needed"
                                    : null,
                                enabled: !isLoading,
                              ),

                              const SizedBox(height: 25),
                              // Security Question Section
                              Text(
                                "RECOVERY QUESTION",
                                style: GoogleFonts.outfit(
                                  color: Colors.white54,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              GlassCard(
                                borderRadius: 18,
                                blur: 15,
                                opacity: 0.05,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedQuestion,
                                      isExpanded: true,
                                      dropdownColor: const Color(0xFF1A1A1A),
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      items: _securityQuestions.map((
                                        String value,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: GoogleFonts.outfit(
                                              fontSize: 13,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: isLoading
                                          ? null
                                          : (newValue) {
                                              setState(() {
                                                _selectedQuestion = newValue!;
                                              });
                                            },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              _buildPremiumField(
                                controller: _answerController,
                                label: "Your Answer",
                                hint: "Needed for password recovery",
                                icon: Icons.security_outlined,
                                validator: (v) =>
                                    v!.isEmpty ? "Answer is required" : null,
                                enabled: !isLoading,
                              ),

                              SizedBox(height: context.hp(4)),

                              // Elevated Action Button
                              GestureDetector(
                                onTap: isLoading ? null : _handleRegister,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFFFFF),
                                        Color(0xFFE2E2E2),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withValues(
                                          alpha: 0.1,
                                        ),
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
                                              strokeWidth: 2,
                                              color: AppTheme.pureBlack,
                                            ),
                                          )
                                        : Text(
                                            "Register",
                                            style: GoogleFonts.outfit(
                                              color: AppTheme.pureBlack,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 25),
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      "By registering, you agree to follow the",
                                      style: GoogleFonts.outfit(
                                        color: Colors.white38,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      "SJCET Campus Conduct Policy",
                                      style: GoogleFonts.outfit(
                                        color: AppTheme.goldAccent.withValues(
                                          alpha: 0.5,
                                        ),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),
                              Center(
                                child: TextButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => Navigator.of(context)
                                            .pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const LoginScreen(),
                                              ),
                                            ),
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: context.sp(15),
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: "Already a member? ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "Sign In",
                                          style: TextStyle(
                                            color: AppTheme.goldAccent,
                                            fontWeight: FontWeight.w700,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPremiumField({
    required TextEditingController controller,
    required String label,
    required String hint,
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
            label.toUpperCase(),
            style: GoogleFonts.outfit(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
        GlassCard(
          borderRadius: 18,
          blur: 15,
          opacity: 0.05,
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            validator: validator,
            enabled: enabled,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.outfit(
                color: Colors.white12,
                fontSize: 13,
              ),
              prefixIcon: Icon(
                icon,
                color: AppTheme.goldAccent.withValues(alpha: 0.7),
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
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: AppTheme.goldAccent.withValues(alpha: 0.3),
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
