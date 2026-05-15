import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {

  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {

    final path = join(
      await getDatabasesPath(),
      'students.db',
    );

    return await openDatabase(
      path,
      version: 1,

      onCreate: (db, version) async {

        /// STUDENTS TABLE
        await db.execute('''
        CREATE TABLE students (

          id INTEGER PRIMARY KEY,
          uuid TEXT,
          school_id INTEGER,
          name TEXT,
          email TEXT,
          phone TEXT,
          gender TEXT,

          school_class_id INTEGER,
          school_class_section_id INTEGER,

          father_name TEXT,
          father_phone TEXT,

          mother_name TEXT,
          mother_phone TEXT,

          profile_photo_url TEXT,

          address TEXT,
          status INTEGER,

          missing_fields TEXT,
          session_json TEXT,
          class_json TEXT,
          section_json TEXT,
          house_json TEXT,

          raw_data TEXT
        )
        ''');

        /// IMAGE TABLE
        await db.execute('''
        CREATE TABLE student_images (

          id INTEGER PRIMARY KEY AUTOINCREMENT,

          student_id INTEGER,

          image_url TEXT,

          local_image_path TEXT,

          created_at TEXT

        )
        ''');

        /// INDEXES
        await db.execute('''
        CREATE INDEX idx_class_section
        ON students(
          school_class_id,
          school_class_section_id
        )
        ''');

        await db.execute('''
        CREATE INDEX idx_name
        ON students(name)
        ''');

      },
    );
  }
}