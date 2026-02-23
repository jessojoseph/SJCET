import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/note_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'campus_notes.db');
    return await openDatabase(
      path,
      version: 5,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT,
            role TEXT,
            securityQuestion TEXT,
            securityAnswer TEXT,
            studyTime INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            title TEXT,
            description TEXT,
            subject TEXT,
            semester TEXT,
            created_at TEXT,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE semesters(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            name TEXT,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE subjects(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            semester_name TEXT,
            name TEXT,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE users ADD COLUMN studyTime INTEGER DEFAULT 0',
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE notes ADD COLUMN semester TEXT DEFAULT "General"',
          );
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE semesters(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER,
              name TEXT,
              FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
            )
          ''');
        }
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE subjects(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER,
              semester_name TEXT,
              name TEXT,
              FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
            )
          ''');
        }
      },
    );
  }

  // NOTE CRUD OPERATIONS

  Future<int> addNote(NoteModel note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<NoteModel>> getNotes(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => NoteModel.fromMap(maps[i]));
  }

  Future<int> updateNote(NoteModel note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // SEMESTER OPERATIONS

  Future<int> addSemester(int userId, String name) async {
    final db = await database;
    return await db.insert('semesters', {'user_id': userId, 'name': name});
  }

  Future<List<String>> getSemesters(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'semesters',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => maps[i]['name'] as String);
  }

  Future<int> deleteSemester(int userId, String name) async {
    final db = await database;
    return await db.delete(
      'semesters',
      where: 'user_id = ? AND name = ?',
      whereArgs: [userId, name],
    );
  }

  // SUBJECT OPERATIONS

  Future<int> addSubject(int userId, String semesterName, String name) async {
    final db = await database;
    return await db.insert('subjects', {
      'user_id': userId,
      'semester_name': semesterName,
      'name': name,
    });
  }

  Future<List<String>> getSubjects(int userId, String semesterName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subjects',
      where: 'user_id = ? AND semester_name = ?',
      whereArgs: [userId, semesterName],
    );
    return List.generate(maps.length, (i) => maps[i]['name'] as String);
  }

  Future<List<String>> getAllSubjects(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subjects',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => maps[i]['name'] as String);
  }

  Future<int> deleteSubject(
    int userId,
    String semesterName,
    String name,
  ) async {
    final db = await database;
    return await db.delete(
      'subjects',
      where: 'user_id = ? AND semester_name = ? AND name = ?',
      whereArgs: [userId, semesterName, name],
    );
  }

  // Get User by Email (for password reset)
  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  // Get User by ID (for persistent session)
  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  // Update Password
  Future<int> updatePassword(String email, String newPassword) async {
    final db = await database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // Register User
  Future<int> registerUser(UserModel user) async {
    final db = await database;
    try {
      return await db.insert('users', user.toMap());
    } catch (e) {
      return -1; // Email already exists or other error
    }
  }

  // Login User
  Future<UserModel?> loginUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  // Update Study Time
  Future<int> updateStudyTime(int userId, int additionalSeconds) async {
    final db = await database;
    // Get current study time first
    final user = await getUserById(userId);
    if (user != null) {
      final newStudyTime = user.studyTime + additionalSeconds;
      return await db.update(
        'users',
        {'studyTime': newStudyTime},
        where: 'id = ?',
        whereArgs: [userId],
      );
    }
    return 0;
  }
}
