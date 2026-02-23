import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/note_model.dart';
import '../services/database_service.dart';

// Events
abstract class NotesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNotesEvent extends NotesEvent {
  final int userId;
  LoadNotesEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddNoteEvent extends NotesEvent {
  final NoteModel note;
  AddNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

class UpdateNoteEvent extends NotesEvent {
  final NoteModel note;
  UpdateNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

class DeleteNoteEvent extends NotesEvent {
  final int noteId;
  final int userId;
  DeleteNoteEvent(this.noteId, this.userId);

  @override
  List<Object?> get props => [noteId, userId];
}

class AddSemesterEvent extends NotesEvent {
  final int userId;
  final String name;
  AddSemesterEvent(this.userId, this.name);

  @override
  List<Object?> get props => [userId, name];
}

class LoadSemestersEvent extends NotesEvent {
  final int userId;
  LoadSemestersEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddSubjectEvent extends NotesEvent {
  final int userId;
  final String semesterName;
  final String name;
  AddSubjectEvent(this.userId, this.semesterName, this.name);

  @override
  List<Object?> get props => [userId, semesterName, name];
}

class LoadSubjectsEvent extends NotesEvent {
  final int userId;
  final String semesterName;
  LoadSubjectsEvent(this.userId, this.semesterName);

  @override
  List<Object?> get props => [userId, semesterName];
}

// States
abstract class NotesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<NoteModel> notes;
  final List<String> semesters;
  final List<String> subjects;
  NotesLoaded(
    this.notes, {
    this.semesters = const [],
    this.subjects = const [],
  });

  @override
  List<Object?> get props => [notes, semesters, subjects];
}

class NotesOperationSuccess extends NotesState {
  final String message;
  NotesOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class NotesError extends NotesState {
  final String message;
  NotesError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final DatabaseService _databaseService = DatabaseService();

  NotesBloc() : super(NotesInitial()) {
    on<LoadNotesEvent>(_onLoadNotes);
    on<AddNoteEvent>(_onAddNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<AddSemesterEvent>(_onAddSemester);
    on<LoadSemestersEvent>(_onLoadSemesters);
    on<AddSubjectEvent>(_onAddSubject);
    on<LoadSubjectsEvent>(_onLoadSubjects);
  }

  Future<void> _onLoadNotes(
    LoadNotesEvent event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading());
    try {
      final notes = await _databaseService.getNotes(event.userId);
      final semesters = await _databaseService.getSemesters(event.userId);
      emit(NotesLoaded(notes, semesters: semesters));
    } catch (e) {
      log('Error loading notes: $e');
      emit(NotesError('Failed to load notes.'));
    }
  }

  Future<void> _onLoadSubjects(
    LoadSubjectsEvent event,
    Emitter<NotesState> emit,
  ) async {
    try {
      final subjects = await _databaseService.getSubjects(
        event.userId,
        event.semesterName,
      );
      if (state is NotesLoaded) {
        emit(
          NotesLoaded(
            (state as NotesLoaded).notes,
            semesters: (state as NotesLoaded).semesters,
            subjects: subjects,
          ),
        );
      }
    } catch (e) {
      log('Error loading subjects: $e');
    }
  }

  Future<void> _onAddSubject(
    AddSubjectEvent event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _databaseService.addSubject(
        event.userId,
        event.semesterName,
        event.name,
      );
      final subjects = await _databaseService.getSubjects(
        event.userId,
        event.semesterName,
      );
      if (state is NotesLoaded) {
        emit(
          NotesLoaded(
            (state as NotesLoaded).notes,
            semesters: (state as NotesLoaded).semesters,
            subjects: subjects,
          ),
        );
      }
    } catch (e) {
      log('Error adding subject: $e');
    }
  }

  Future<void> _onLoadSemesters(
    LoadSemestersEvent event,
    Emitter<NotesState> emit,
  ) async {
    try {
      final sems = await _databaseService.getSemesters(event.userId);
      if (state is NotesLoaded) {
        emit(NotesLoaded((state as NotesLoaded).notes, semesters: sems));
      }
    } catch (e) {
      log('Error loading semesters: $e');
    }
  }

  Future<void> _onAddSemester(
    AddSemesterEvent event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _databaseService.addSemester(event.userId, event.name);
      final sems = await _databaseService.getSemesters(event.userId);
      if (state is NotesLoaded) {
        emit(NotesLoaded((state as NotesLoaded).notes, semesters: sems));
      } else {
        add(LoadNotesEvent(event.userId));
      }
    } catch (e) {
      log('Error adding semester: $e');
    }
  }

  Future<void> _onAddNote(AddNoteEvent event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    try {
      final result = await _databaseService.addNote(event.note);
      if (result != -1) {
        final notes = await _databaseService.getNotes(event.note.userId);
        final semesters = await _databaseService.getSemesters(
          event.note.userId,
        );
        emit(NotesOperationSuccess('Note added successfully!'));
        emit(NotesLoaded(notes, semesters: semesters));
      } else {
        emit(NotesError('Failed to add note.'));
      }
    } catch (e) {
      log('Error adding note: $e');
      emit(NotesError('An error occurred while adding note.'));
    }
  }

  Future<void> _onUpdateNote(
    UpdateNoteEvent event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading());
    try {
      await _databaseService.updateNote(event.note);
      final notes = await _databaseService.getNotes(event.note.userId);
      final semesters = await _databaseService.getSemesters(event.note.userId);
      emit(NotesOperationSuccess('Note updated successfully!'));
      emit(NotesLoaded(notes, semesters: semesters));
    } catch (e) {
      log('Error updating note: $e');
      emit(NotesError('Failed to update note.'));
    }
  }

  Future<void> _onDeleteNote(
    DeleteNoteEvent event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoading());
    try {
      await _databaseService.deleteNote(event.noteId);
      final notes = await _databaseService.getNotes(event.userId);
      final semesters = await _databaseService.getSemesters(event.userId);
      emit(NotesOperationSuccess('Note deleted!'));
      emit(NotesLoaded(notes, semesters: semesters));
    } catch (e) {
      log('Error deleting note: $e');
      emit(NotesError('Failed to delete note.'));
    }
  }
}
