import 'dart:convert';
import 'package:idmitra/db_helper.dart';
import 'package:idmitra/models/students/StudentsListModel.dart';
import 'package:sqflite/sqflite.dart';

class StudentLocalDS {

  /// 🔥 INSERT SINGLE
  Future<void> insertStudent(StudentDetailsData e) async {
    final db = await DBHelper.db;

    await db.insert(
      'students',
      {
        "id": e.id,
        "uuid": e.uuid ?? "",
        "school_id": e.schoolId,

        "name": e.name ?? "",
        "email": e.email?.toString(),
        "phone": e.phone?.toString(),
        "gender": e.gender?.toString(),

        "school_class_id": e.schoolClassId,
        "school_class_section_id": e.schoolClassSectionId,

        "father_name": e.fatherName ?? "",
        "father_phone": e.fatherPhone,
        "mother_name": e.motherName,
        "mother_phone": e.motherPhone,

        "profile_photo_url": e.profilePhotoUrl,
        "address": e.address,
        "status": e.status ?? 0,

        /// JSON fields
        "missing_fields": jsonEncode(e.missingFields ?? []),
        "session_json": jsonEncode(e.session?.toJson() ?? {}),
        "class_json": jsonEncode(e.datumClass?.toJson() ?? {}),
        "section_json": jsonEncode(e.section?.toJson() ?? {}),
        "house_json": jsonEncode(e.house ?? {}),

        /// full backup
        "raw_data": jsonEncode(e.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 🚀 INSERT BATCH (FAST)
  Future<void> insertStudents(List<StudentDetailsData> list) async {
    final db = await DBHelper.db;
    final batch = db.batch();

    for (var e in list) {
      batch.insert(
        'students',
        {
          "id": e.id,
          "name": e.name,
          "father_name": e.fatherName ?? "",
          "school_class_id": e.schoolClassId,
          "school_class_section_id": e.schoolClassSectionId,


          /// full backup
          "raw_data": jsonEncode(e.toJson()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// 🔍 FETCH WITH FILTER + PAGINATION
  Future<List<StudentDetailsData>> getStudents({
    String search = "",
    String gender = "",
    String classId = "",
    List<int> sectionIds = const [],
    bool isPagination = false,
  }) async {
    final db = await DBHelper.db;
    String where = "1=1";
    List<dynamic> args = [];

    if (search.isNotEmpty) {
      where += " AND name LIKE ?";
      args.add("%$search%");
    }

    if (gender.isNotEmpty) {
      where += " AND gender = ?";
      args.add(gender);
    }

    if (classId.isNotEmpty) {
      where += " AND class_id = ?";
      args.add(classId);
    }

    final data = await db.query(
      "students",
      where: where,
      whereArgs: args,
      /// 🔥 IMPORTANT: alphabetical order
      orderBy: "name COLLATE NOCASE ASC",
      // ❌ NO LIMIT
      // ❌ NO OFFSET
    );

    return data.map((e) => StudentDetailsData.fromJson(e)).toList();
  }

  /// 🔢 COUNT
  Future<int> getCount({
    String search = "",
    String gender = "",
    String classId = "",
    List<int> sectionIds = const [],
  }) async {
    final db = await DBHelper.db;

    String where = "1=1";
    List<dynamic> args = [];

    if (search.isNotEmpty) {
      where += " AND name LIKE ?";
      args.add('%$search%');
    }

    if (gender.isNotEmpty) {
      where += " AND gender = ?";
      args.add(gender);
    }

    if (classId.isNotEmpty) {
      where += " AND school_class_id = ?";
      args.add(int.parse(classId));
    }

    if (sectionIds.isNotEmpty) {
      where +=
      " AND school_class_section_id IN (${sectionIds.map((e) => '?').join(',')})";
      args.addAll(sectionIds);
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM students WHERE $where',
      args,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// ❌ CLEAR TABLE
  Future<void> clearStudents() async {
    final db = await DBHelper.db;
    await db.delete('students');
  }
}