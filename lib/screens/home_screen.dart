import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/note_model.dart';
import '../blocs/notes_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../widgets/glass_card.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

import 'auth/login_screen.dart';
import 'add_edit_note_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedSemester = "All";
  String _selectedSubject = "All";
  Timer? _studyTimer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    context.read<NotesBloc>().add(LoadNotesEvent(widget.user.id!));
    _startStudyTimer();
  }

  void _startStudyTimer() {
    _studyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsElapsed++;
      // Every 30 seconds, sync with database
      if (_secondsElapsed % 30 == 0) {
        context.read<AuthBloc>().add(UpdateStudyTimeEvent(30));
      }
    });
  }

  @override
  void dispose() {
    _studyTimer?.cancel();
    // Sync final seconds before disposing
    if (_secondsElapsed % 30 != 0) {
      context.read<AuthBloc>().add(UpdateStudyTimeEvent(_secondsElapsed % 30));
    }
    _searchController.dispose();
    super.dispose();
  }

  String _formatStudyTime(int totalSeconds) {
    if (totalSeconds < 60) return "${totalSeconds}s";
    if (totalSeconds < 3600) {
      return "${(totalSeconds / 60).toStringAsFixed(1)}m";
    }
    return "${(totalSeconds / 3600).toStringAsFixed(1)}h";
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  void _showAddSemesterDialog() {
    final TextEditingController semController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: GlassCard(
          borderRadius: 24,
          blur: 20,
          opacity: 0.1,
          child: Container(
            width: context.wp(80),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.goldAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_month_outlined,
                    color: AppTheme.goldAccent,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "New Semester",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: context.sp(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    controller: semController,
                    autofocus: true,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: "e.g. Semester 9",
                      hintStyle: GoogleFonts.outfit(color: Colors.white24),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Text(
                              "CANCEL",
                              style: GoogleFonts.outfit(
                                color: Colors.white38,
                                fontWeight: FontWeight.bold,
                                fontSize: context.sp(12),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (semController.text.trim().isNotEmpty) {
                            context.read<NotesBloc>().add(
                              AddSemesterEvent(
                                widget.user.id!,
                                semController.text.trim(),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.goldAccent.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "ADD",
                              style: GoogleFonts.outfit(
                                color: AppTheme.pureBlack,
                                fontWeight: FontWeight.bold,
                                fontSize: context.sp(12),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddSubjectDialog() {
    if (_selectedSemester == "All") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a specific semester first"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final TextEditingController subController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: GlassCard(
          borderRadius: 24,
          blur: 20,
          opacity: 0.1,
          child: Container(
            width: context.wp(80),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.goldAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: AppTheme.goldAccent,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "New Subject",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: context.sp(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "For $_selectedSemester",
                  style: GoogleFonts.outfit(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    controller: subController,
                    autofocus: true,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: "e.g. Thermodynamics",
                      hintStyle: GoogleFonts.outfit(color: Colors.white24),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Text(
                              "CANCEL",
                              style: GoogleFonts.outfit(
                                color: Colors.white38,
                                fontWeight: FontWeight.bold,
                                fontSize: context.sp(12),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (subController.text.trim().isNotEmpty) {
                            context.read<NotesBloc>().add(
                              AddSubjectEvent(
                                widget.user.id!,
                                _selectedSemester,
                                subController.text.trim(),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.goldAccent.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "ADD",
                              style: GoogleFonts.outfit(
                                color: AppTheme.pureBlack,
                                fontWeight: FontWeight.bold,
                                fontSize: context.sp(12),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(NoteModel note) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: GlassCard(
          borderRadius: 24,
          blur: 20,
          opacity: 0.1,
          child: Container(
            width: context.wp(80),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_sweep_rounded,
                    color: Colors.redAccent,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Delete Note?",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: context.sp(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Are you sure you want to remove '${note.title}'?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: context.sp(13),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Text(
                              "CANCEL",
                              style: GoogleFonts.outfit(
                                color: Colors.white38,
                                fontWeight: FontWeight.bold,
                                fontSize: context.sp(12),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          context.read<NotesBloc>().add(
                            DeleteNoteEvent(note.id!, widget.user.id!),
                          );
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "DELETE",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: context.sp(12),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: GlassCard(
          borderRadius: 24,
          blur: 20,
          opacity: 0.1,
          child: Container(
            width: context.wp(80),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.accentIndigo.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppTheme.accentIndigo,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "End Session?",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: context.sp(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Are you sure you want to sign out of your account?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: context.sp(13),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Text(
                              "STAY",
                              style: GoogleFonts.outfit(
                                color: Colors.white38,
                                fontWeight: FontWeight.bold,
                                fontSize: context.sp(12),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          context.read<AuthBloc>().add(LogoutEvent());
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.accentIndigo.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "LOGOUT",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: context.sp(12),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAddEdit({NoteModel? note}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AddEditNoteScreen(note: note, userId: widget.user.id!),
      ),
    );
  }

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

          // Academic Atmospheric Elements
          Positioned(
            top: -context.hp(5),
            right: -context.wp(10),
            child: Opacity(
              opacity: 0.05,
              child: Icon(
                Icons.school,
                size: context.wp(80),
                color: Colors.white,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Greeting Section
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.wp(6),
                    context.hp(2),
                    context.wp(6),
                    context.hp(1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.goldAccent.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: context.wp(6),
                          backgroundColor: AppTheme.accentIndigo.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            widget.user.name.substring(0, 1).toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: AppTheme.goldAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: context.sp(18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: GoogleFonts.outfit(
                                color: Colors.white54,
                                fontSize: context.sp(14),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              widget.user.name,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: context.sp(24),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _showLogoutDialog,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.power_settings_new_rounded,
                          color: Colors.redAccent,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar Section
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.wp(6),
                    vertical: 20,
                  ),
                  child: GlassCard(
                    borderRadius: 18,
                    blur: 15,
                    opacity: 0.05,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) {
                        setState(() {
                          _searchQuery = v.toLowerCase();
                        });
                      },
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: "Search your library...",
                        hintStyle: GoogleFonts.outfit(color: Colors.white24),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Colors.white38,
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.white38,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = "");
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                ),

                // Quick Stats Dashboard
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.wp(6)),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      return BlocBuilder<NotesBloc, NotesState>(
                        builder: (context, notesState) {
                          int totalNotes = 0;
                          if (notesState is NotesLoaded) {
                            totalNotes = notesState.notes.length;
                          }

                          String studyTimeStr = "0s";
                          if (authState is AuthSuccess) {
                            studyTimeStr = _formatStudyTime(
                              authState.user.studyTime + (_secondsElapsed % 31),
                            );
                          }

                          return Row(
                            children: [
                              _buildStatCard(
                                "Total Notes",
                                totalNotes.toString(),
                                Icons.description_rounded,
                                AppTheme.goldAccent,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                "Study Time",
                                studyTimeStr,
                                Icons.timer_rounded,
                                AppTheme.accentIndigo,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 25),

                // Semester Navigation
                _buildSectionHeader(
                  "CAMPUS SEMESTER",
                  onAdd: _showAddSemesterDialog,
                  addButtonLabel: "Add Semester",
                ),
                const SizedBox(height: 12),
                BlocBuilder<NotesBloc, NotesState>(
                  builder: (context, state) {
                    List<String> semesters = ["All"];
                    if (state is NotesLoaded) {
                      final combined = <String>{
                        ...state.semesters,
                        ...state.notes
                            .map((n) => n.semester)
                            .where((s) => s != 'General'),
                      }.toList()..sort();
                      semesters.addAll(<String>["General", ...combined]);
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: context.wp(6)),
                      child: Row(
                        children: semesters.map((sem) {
                          return _buildFilterChip(sem);
                        }).toList(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 25),

                // Subject Navigation
                _buildSectionHeader(
                  "CURRICULUM SUBJECTS",
                  onAdd: _selectedSemester != "All"
                      ? _showAddSubjectDialog
                      : null,
                  addButtonLabel: "Add Subject",
                ),
                const SizedBox(height: 12),
                BlocBuilder<NotesBloc, NotesState>(
                  builder: (context, state) {
                    List<String> subjects = ["All"];
                    if (state is NotesLoaded) {
                      final filteredBySem = state.notes.where(
                        (n) =>
                            _selectedSemester == "All" ||
                            n.semester == _selectedSemester,
                      );

                      final fromNotes = filteredBySem
                          .map((n) => n.subject)
                          .toSet();

                      final fromTable = _selectedSemester == "All"
                          ? <String>[]
                          : state.subjects;

                      final combined = {...fromNotes, ...fromTable}.toList()
                        ..sort();
                      subjects.addAll(combined);
                    }

                    if (!subjects.contains(_selectedSubject)) {
                      _selectedSubject = "All";
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: context.wp(6)),
                      child: Row(
                        children: subjects.map((sub) {
                          return _buildFilterChip(sub, isSubject: true);
                        }).toList(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 35),

                // Section Title + Result Count
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.wp(6)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "RESEARCH NOTES",
                            style: GoogleFonts.outfit(
                              color: AppTheme.goldAccent.withValues(alpha: 0.7),
                              fontSize: context.sp(10),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedSemester == "All"
                                ? "Global Library"
                                : "$_selectedSemester Curricula",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: context.sp(18),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      BlocBuilder<NotesBloc, NotesState>(
                        builder: (context, state) {
                          int count = 0;
                          if (state is NotesLoaded) {
                            count = state.notes.where((n) {
                              final matchesSearch =
                                  n.title.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  n.subject.toLowerCase().contains(
                                    _searchQuery,
                                  );
                              final matchesSemester =
                                  _selectedSemester == "All" ||
                                  n.semester == _selectedSemester;
                              final matchesSubject =
                                  _selectedSubject == "All" ||
                                  n.subject == _selectedSubject;
                              return matchesSearch &&
                                  matchesSemester &&
                                  matchesSubject;
                            }).length;
                          }
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "$count ITEMS",
                              style: GoogleFonts.outfit(
                                color: Colors.white38,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Notes List
                Expanded(
                  child: BlocConsumer<NotesBloc, NotesState>(
                    listener: (context, state) {
                      if (state is NotesOperationSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.indigo,
                          ),
                        );
                      } else if (state is NotesError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is NotesLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.goldAccent,
                          ),
                        );
                      } else if (state is NotesLoaded) {
                        final filteredNotes = state.notes.where((n) {
                          final matchesSearch =
                              n.title.toLowerCase().contains(_searchQuery) ||
                              n.subject.toLowerCase().contains(_searchQuery);
                          final matchesSemester =
                              _selectedSemester == "All" ||
                              n.semester == _selectedSemester;
                          final matchesSubject =
                              _selectedSubject == "All" ||
                              n.subject == _selectedSubject;
                          return matchesSearch &&
                              matchesSemester &&
                              matchesSubject;
                        }).toList();

                        if (filteredNotes.isEmpty) {
                          return _buildEmptyState();
                        }

                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: context.wp(6),
                            vertical: 10,
                          ),
                          itemCount: filteredNotes.length,
                          itemBuilder: (context, index) {
                            return _buildNoteCard(filteredNotes[index]);
                          },
                        );
                      }
                      return const Center(
                        child: Text(
                          "Start adding your campus notes!",
                          style: TextStyle(color: Colors.white38),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEdit(),
        backgroundColor: AppTheme.goldAccent,
        child: const Icon(Icons.add, color: AppTheme.pureBlack),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: context.wp(20),
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 20),
          Text(
            "No notes yet.",
            style: GoogleFonts.outfit(
              color: Colors.white38,
              fontSize: context.sp(18),
            ),
          ),
          Text(
            "Tap + to create your first lecture note.",
            style: GoogleFonts.outfit(
              color: Colors.white24,
              fontSize: context.sp(14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSubject = false}) {
    bool isSelected = isSubject
        ? _selectedSubject == label
        : _selectedSemester == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSubject) {
            _selectedSubject = label;
          } else {
            _selectedSemester = label;
            _selectedSubject = "All"; // Reset subject when semester changes
            if (label != "All") {
              context.read<NotesBloc>().add(
                LoadSubjectsEvent(widget.user.id!, label),
              );
            }
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isSubject ? AppTheme.goldAccent : AppTheme.accentIndigo)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isSubject ? AppTheme.goldAccent : AppTheme.accentIndigo)
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected
                ? (isSubject ? AppTheme.pureBlack : Colors.white)
                : Colors.white38,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    return Expanded(
      child: GlassCard(
        borderRadius: 20,
        blur: 10,
        opacity: 0.05,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accentColor.withValues(alpha: 0.6), size: 20),
              const SizedBox(height: 12),
              Text(
                value,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: context.sp(22),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: context.sp(11),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(NoteModel note) {
    final date = DateTime.parse(note.createdAt);
    final formattedDate = DateFormat('MMM dd, yyyy').format(date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GlassCard(
        borderRadius: 24,
        blur: 20,
        opacity: 0.1,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _navigateToAddEdit(note: note),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.goldAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.goldAccent.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 10,
                            color: Colors.white38,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            note.semester.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: Colors.white38,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.school_outlined,
                            size: 12,
                            color: AppTheme.goldAccent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            note.subject.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: AppTheme.goldAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildCompactActionButtons(note),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  note.title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: context.sp(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  note.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: context.sp(14),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.white24,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: GoogleFonts.outfit(
                            color: Colors.white24,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: AppTheme.goldAccent.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactActionButtons(NoteModel note) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert_rounded,
        color: Colors.white38,
        size: 20,
      ),
      padding: EdgeInsets.zero,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      onSelected: (val) {
        if (val == 'delete') {
          _showDeleteDialog(note);
        } else if (val == 'edit') {
          _navigateToAddEdit(note: note);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, size: 18, color: Colors.white),
              const SizedBox(width: 10),
              Text("Edit Note", style: GoogleFonts.outfit(fontSize: 14)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(
                Icons.delete_outline,
                size: 18,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 10),
              Text(
                "Delete",
                style: GoogleFonts.outfit(
                  color: Colors.redAccent,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    String title, {
    VoidCallback? onAdd,
    String? addButtonLabel,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.wp(6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white38,
              fontSize: context.sp(10),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          if (onAdd != null)
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.goldAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.goldAccent.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      size: 14,
                      color: AppTheme.goldAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      addButtonLabel ?? "ADD",
                      style: GoogleFonts.outfit(
                        color: AppTheme.goldAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
