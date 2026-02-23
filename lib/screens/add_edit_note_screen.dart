import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note_model.dart';
import '../blocs/notes_bloc.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../utils/responsive.dart';

class AddEditNoteScreen extends StatefulWidget {
  final NoteModel? note;
  final int userId;

  const AddEditNoteScreen({super.key, this.note, required this.userId});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _subjectController;
  late TextEditingController _descriptionController;
  late TextEditingController _semesterController;
  final _formKey = GlobalKey<FormState>();
  bool _isAddingCustomSemester = false;
  bool _isAddingCustomSubject = false;
  List<String> _existingSemesters = ['General'];
  List<String> _existingSubjects = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _subjectController = TextEditingController(
      text: widget.note?.subject ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.note?.description ?? '',
    );
    _semesterController = TextEditingController(
      text: widget.note?.semester ?? 'General',
    );

    // Load unique semesters from Bloc
    final notesState = context.read<NotesBloc>().state;
    if (notesState is NotesLoaded) {
      final fromTable = notesState.semesters;
      final fromNotes = notesState.notes
          .map((n) => n.semester)
          .where((s) => s != 'General')
          .toSet()
          .toList();

      final combined = <String>{...fromTable, ...fromNotes}.toList()..sort();
      _existingSemesters.addAll(combined);
    }

    _loadSubjects();
  }

  void _loadSubjects() {
    final semester = _semesterController.text;
    if (semester != "General") {
      context.read<NotesBloc>().add(LoadSubjectsEvent(widget.userId, semester));
    }

    final notesState = context.read<NotesBloc>().state;
    if (notesState is NotesLoaded) {
      // Find subjects for this semester from notes
      final subjectsFromNotes = notesState.notes
          .where((n) => n.semester == semester)
          .map((n) => n.subject)
          .toSet()
          .toList();

      final subjectsFromTable = notesState.subjects;

      setState(() {
        _existingSubjects = {
          ...subjectsFromNotes,
          ...subjectsFromTable,
        }.toList()..sort();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      final note = NoteModel(
        id: widget.note?.id,
        userId: widget.userId,
        title: _titleController.text.trim(),
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        semester: _semesterController.text.trim().isEmpty
            ? 'General'
            : _semesterController.text.trim(),
        createdAt: widget.note?.createdAt ?? DateTime.now().toIso8601String(),
      );

      if (widget.note == null) {
        context.read<NotesBloc>().add(AddNoteEvent(note));
      } else {
        context.read<NotesBloc>().add(UpdateNoteEvent(note));
      }
      Navigator.pop(context);
    }
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
            top: context.hp(10),
            right: -context.wp(10),
            child: Opacity(
              opacity: 0.05,
              child: Icon(
                Icons.edit_note,
                size: context.wp(80),
                color: Colors.white,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(context.wp(6)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.note == null ? "NEW NOTE" : "EDIT NOTE",
                        style: GoogleFonts.outfit(
                          color: AppTheme.goldAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: context.sp(16),
                        ),
                      ),
                      const SizedBox(width: 48), // Spacer for balance
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _buildInputLabel("LECTURE TITLE"),
                          _buildGlassInput(
                            controller: _titleController,
                            hint: "Enter physics lecture topic...",
                            icon: Icons.title,
                            validator: (v) =>
                                v!.isEmpty ? "Title is required" : null,
                          ),
                          const SizedBox(height: 25),
                          _buildSemesterSelector(),
                          const SizedBox(height: 25),
                          _buildSubjectSelector(),
                          const SizedBox(height: 25),
                          _buildInputLabel("NOTE CONTENT"),
                          _buildGlassInput(
                            controller: _descriptionController,
                            hint: "Start writing your notes here...",
                            icon: Icons.description_outlined,
                            maxLines: context.hp(1) > 7 ? 12 : 8,
                            validator: (v) =>
                                v!.isEmpty ? "Content is required" : null,
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
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: GestureDetector(
          onTap: _saveNote,
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
              child: Text(
                "SAVE NOTE",
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
      ),
    );
  }

  Widget _buildSubjectSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel("SELECT OR ADD SUBJECT"),
        BlocBuilder<NotesBloc, NotesState>(
          builder: (context, state) {
            List<String> combinedSubjects = [];
            if (state is NotesLoaded) {
              final subjectsFromTable = state.subjects;
              final subjectsFromNotes = state.notes
                  .where((n) => n.semester == _semesterController.text)
                  .map((n) => n.subject)
                  .toSet()
                  .toList();
              combinedSubjects = <String>{
                ...subjectsFromNotes,
                ...subjectsFromTable,
              }.toList()..sort();
            }

            return GlassCard(
              borderRadius: 20,
              blur: 15,
              opacity: 0.05,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: DropdownButtonFormField<String>(
                  value: _isAddingCustomSubject
                      ? null
                      : (combinedSubjects.contains(_subjectController.text)
                            ? _subjectController.text
                            : null),
                  dropdownColor: const Color(0xFF1A1A1A),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white24,
                  ),
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.book_outlined,
                      color: AppTheme.goldAccent,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 20),
                  ),
                  hint: Text(
                    "Select Subject",
                    style: GoogleFonts.outfit(color: Colors.white24),
                  ),
                  items: [
                    ...combinedSubjects.map((String sub) {
                      return DropdownMenuItem(value: sub, child: Text(sub));
                    }),
                    const DropdownMenuItem(
                      value: "ADD_NEW",
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 18,
                            color: AppTheme.goldAccent,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Add New Subject...",
                            style: TextStyle(color: AppTheme.goldAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      if (newValue == "ADD_NEW") {
                        _isAddingCustomSubject = true;
                        _subjectController.clear();
                      } else {
                        _isAddingCustomSubject = false;
                        _subjectController.text = newValue!;
                      }
                    });
                  },
                ),
              ),
            );
          },
        ),
        if (_isAddingCustomSubject) ...[
          const SizedBox(height: 15),
          _buildInputLabel("NEW SUBJECT NAME"),
          _buildGlassInput(
            controller: _subjectController,
            hint: "Type subject name (e.g. Engineering Math)",
            icon: Icons.edit_note_rounded,
            validator: (v) => v!.isEmpty ? "Please enter a subject name" : null,
          ),
        ],
      ],
    );
  }

  Widget _buildSemesterSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel("SELECT OR ADD SEMESTER"),
        GlassCard(
          borderRadius: 20,
          blur: 15,
          opacity: 0.05,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: DropdownButtonFormField<String>(
              value: _isAddingCustomSemester
                  ? null
                  : (_existingSemesters.contains(_semesterController.text)
                        ? _semesterController.text
                        : null),
              dropdownColor: const Color(0xFF1A1A1A),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white24,
              ),
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.list_alt_rounded,
                  color: AppTheme.goldAccent,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 20),
              ),
              hint: Text(
                "Select Semester",
                style: GoogleFonts.outfit(color: Colors.white24),
              ),
              items: [
                ..._existingSemesters.map((String sem) {
                  return DropdownMenuItem(value: sem, child: Text(sem));
                }),
                const DropdownMenuItem(
                  value: "ADD_NEW",
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 18,
                        color: AppTheme.goldAccent,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Add New Semester...",
                        style: TextStyle(color: AppTheme.goldAccent),
                      ),
                    ],
                  ),
                ),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  if (newValue == "ADD_NEW") {
                    _isAddingCustomSemester = true;
                    _semesterController.clear();
                  } else {
                    _isAddingCustomSemester = false;
                    _semesterController.text = newValue!;
                    _loadSubjects();
                    // Clear selected subject if it's from a dropdown (to avoid semester mismatch)
                    // but keep it if the user is manually typing a custom subject.
                    if (!_isAddingCustomSubject) {
                      _subjectController.clear();
                    }
                  }
                });
              },
            ),
          ),
        ),
        if (_isAddingCustomSemester) ...[
          const SizedBox(height: 15),
          _buildInputLabel("NEW SEMESTER NAME"),
          _buildGlassInput(
            controller: _semesterController,
            hint: "Type semester name (e.g. Semester 9)",
            icon: Icons.edit_calendar_outlined,
            validator: (v) => v!.isEmpty ? "Please enter a name" : null,
          ),
        ],
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: Colors.white38,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return GlassCard(
      borderRadius: 20,
      blur: 15,
      opacity: 0.05,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: Colors.white12),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: Icon(
              icon,
              color: AppTheme.goldAccent.withValues(alpha: 0.5),
              size: 20,
            ),
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.02),
          contentPadding: const EdgeInsets.all(20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppTheme.goldAccent, width: 1),
          ),
        ),
      ),
    );
  }
}
