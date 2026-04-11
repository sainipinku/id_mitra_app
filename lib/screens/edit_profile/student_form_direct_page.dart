import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/models/schools/SchoolListModel.dart';
import 'package:idmitra/providers/student_form/student_form_cubit.dart';
import 'package:idmitra/screens/edit_profile/student_form.dart';

/// Used when super_admin logs in directly
class StudentFormDirectPage extends StatelessWidget {
  final String schoolName;
  final String schoolId;

  const StudentFormDirectPage({
    super.key,
    required this.schoolName,
    required this.schoolId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StudentFormCubit()
        ..loadFromSchoolId(
          schoolId: schoolId,
          schoolName: schoolName,
        ),
      child: StudentForm(
        schoolDetailsModel: SchoolDetailsModel(
          name: schoolName,
          id: int.tryParse(schoolId),
        ),
      ),
    );
  }
}
