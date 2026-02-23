import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class ViewNoteScreen extends StatelessWidget {
  final NoteModel note;

  const ViewNoteScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(note.createdAt) ?? DateTime.now();
    final formattedDate = DateFormat('MMMM dd, yyyy - hh:mm a').format(date);

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: Stack(
        children: [
          // Background Gradient matching other screens
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
          // Decorative background icon
          Positioned(
            top: -40,
            right: -40,
            child: Opacity(
              opacity: 0.05,
              child: const Icon(
                Icons.menu_book,
                size: 200,
                color: AppTheme.primaryRed,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.charcoal.withValues(
                            alpha: 0.05,
                          ),
                          padding: const EdgeInsets.all(12),
                        ),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppTheme.charcoal,
                          size: 18,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          "Note Details",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.charcoal,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance for centering
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tags Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryRed.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryRed.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    size: 14,
                                    color: AppTheme.charcoal,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    note.semester.toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.charcoal,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryRed.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryRed.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.school_outlined,
                                    size: 14,
                                    color: AppTheme.primaryRed,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    note.subject.toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.primaryRed,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          note.title,
                          style: GoogleFonts.outfit(
                            color: AppTheme.charcoal,
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Date
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: AppTheme.charcoal.withValues(alpha: 0.4),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formattedDate,
                              style: GoogleFonts.outfit(
                                color: AppTheme.charcoal.withValues(alpha: 0.5),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Main Content
                        GlassCard(
                          borderRadius: 24,
                          blur: 15,
                          opacity: 0.03,
                          color: AppTheme.charcoal,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              note.description,
                              style: GoogleFonts.outfit(
                                color: AppTheme.charcoal.withValues(
                                  alpha: 0.85,
                                ),
                                fontSize: 17,
                                height: 1.8,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
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
}
