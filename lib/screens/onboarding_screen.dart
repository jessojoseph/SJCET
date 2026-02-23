import 'package:campus_notes/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_card.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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

          // 2. Academic Atmospheric Elements
          Positioned(
            bottom: -context.hp(10),
            right: -context.wp(20),
            child: Opacity(
              opacity: 0.1,
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

          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [_buildPage1(), _buildPage2(), _buildPage3()],
          ),

          // Bottom Controls
          Positioned(
            bottom: context.hp(5),
            left: 30,
            right: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Page Indicator
                Row(
                  children: List.generate(3, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      width: _currentPage == index ? 32 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: _currentPage == index
                            ? AppTheme.primaryRed
                            : AppTheme.primaryRed.withValues(alpha: 0.2),
                      ),
                    );
                  }),
                ),

                // Navigation Button
                GestureDetector(
                  onTap: () {
                    if (_currentPage < 2) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      // Final Step Navigation to Register
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.primaryRed, AppTheme.secondaryRed],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRed.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage1() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: context.hp(8)),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth * 0.45;
                final cardHeight = constraints.maxHeight * 0.4;
                return Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      child: _buildCharacterCard(
                        title: "Student",
                        image: "assets/images/student.png",
                        width: cardWidth,
                        height: cardHeight,
                      ),
                    ),
                    Positioned(
                      top: constraints.maxHeight * 0.1,
                      right: 0,
                      child: _buildCharacterCard(
                        title: "Freelancer",
                        image: "assets/images/worker.png",
                        width: cardWidth,
                        height: cardHeight,
                      ),
                    ),
                    Positioned(
                      bottom: constraints.maxHeight * 0.1,
                      left: 0,
                      child: _buildCharacterCard(
                        title: "Teacher",
                        image: "assets/images/freelancer.png",
                        width: cardWidth,
                        height: cardHeight,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: _buildCharacterCard(
                        title: "Other",
                        image: "assets/images/other.png",
                        width: cardWidth,
                        height: cardHeight,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: context.isSmallScreen ? 20 : 40),
          Text(
            "Choose Your\nSmart Role",
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: context.sp(36),
            ),
          ),
          SizedBox(height: context.isSmallScreen ? 10 : 20),
          Text(
            "Choose your style so AI smartly personalizes notes to match your workflow.",
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: context.sp(16),
            ),
          ),
          SizedBox(height: context.hp(15)),
        ],
      ),
    );
  }

  Widget _buildCharacterCard({
    required String title,
    required String image,
    required double width,
    required double height,
  }) {
    return GlassCard(
      borderRadius: 24,
      blur: 20,
      opacity: 0.1,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.8,
            colors: [Colors.white.withOpacity(0.05), Colors.transparent],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: AppTheme.charcoal.withValues(alpha: 0.8),
                        fontSize: width > 120 ? 14 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage2() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: context.hp(8)),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 0.8,
                child: GlassCard(
                  borderRadius: 40,
                  blur: 25,
                  opacity: 0.1,
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Travel Journal",
                              style: GoogleFonts.outfit(
                                color: AppTheme.charcoal,
                                fontSize: context.sp(22),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.more_horiz,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ],
                        ),
                        SizedBox(height: context.isSmallScreen ? 10 : 20),
                        Expanded(
                          child: Icon(
                            Icons.public,
                            size: context.wp(40),
                            color: AppTheme.charcoal.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: context.isSmallScreen ? 20 : 40),
          RichText(
            text: TextSpan(
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: context.sp(36),
              ),
              children: [
                const TextSpan(text: "Unlock "),
                TextSpan(
                  text: "Your\nUnique Way To\nUse Orbyte",
                  style: TextStyle(
                    color: AppTheme.charcoal.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.hp(15)),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: context.hp(8)),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    ...List.generate(3, (index) {
                      return Positioned(
                        top: constraints.maxHeight * 0.2 + (index * 40),
                        right: constraints.maxWidth * 0.1 + (index * 25),
                        child: Transform.rotate(
                          angle: (index - 1) * 0.12,
                          child: GlassCard(
                            borderRadius: 35,
                            opacity: 0.18 - (index * 0.05),
                            blur: 15,
                            child: SizedBox(
                              width: constraints.maxWidth * 0.5,
                              height: constraints.maxHeight * 0.6,
                            ),
                          ),
                        ),
                      );
                    }),
                    Positioned(
                      top: constraints.maxHeight * 0.3,
                      child: GlassCard(
                        borderRadius: 40,
                        blur: 20,
                        opacity: 0.15,
                        child: Container(
                          width: constraints.maxWidth * 0.55,
                          height: constraints.maxHeight * 0.65,
                          padding: const EdgeInsets.all(25),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: Colors.amber.withOpacity(0.8),
                                size: constraints.maxWidth * 0.25,
                              ),
                              SizedBox(height: context.isSmallScreen ? 15 : 30),
                              Text(
                                "Smart AI",
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: context.sp(20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: context.isSmallScreen ? 20 : 40),
          Text(
            "AI note Helps\nYou Build Smart\nNotes Fast",
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: context.sp(36),
            ),
          ),
          SizedBox(height: context.isSmallScreen ? 10 : 20),
          Text(
            "We prepared this example so AI can guide your note-taking effectively.",
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: context.sp(16),
            ),
          ),
          SizedBox(height: context.hp(15)),
        ],
      ),
    );
  }
}
