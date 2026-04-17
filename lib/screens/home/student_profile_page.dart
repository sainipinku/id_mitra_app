import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/models/students/StudentsListModel.dart';
import 'package:idmitra/providers/add_student/add_student_cubit.dart';
import 'package:idmitra/providers/student_form/student_form_cubit.dart';
import 'package:idmitra/providers/student_form/student_form_data_cubit.dart';
import 'package:idmitra/screens/add_student/add_student_form.dart';
import 'package:idmitra/utils/common_widgets/app_button.dart';

class StudentProfilePage extends StatefulWidget {
  final StudentDetailsData student;
  final String schoolId;
  const StudentProfilePage({
    super.key,
    required this.student,
    required this.schoolId,
  });

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  late StudentDetailsData _student;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
  }

  String get schoolId => widget.schoolId;

  void _openEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => StudentFormCubit()
                ..loadFromSchoolId(schoolId: schoolId, schoolName: ''),
            ),
            BlocProvider(
              create: (_) => StudentFormDataCubit()..load(schoolId),
            ),
            BlocProvider(create: (_) => AddStudentCubit()),
          ],
          child: AddStudentFormPage(
            schoolId: schoolId,
            editStudent: _student,
          ),
        ),
      ),
    ).then((updatedStudent) {
      if (updatedStudent is StudentDetailsData && mounted) {
        setState(() => _student = updatedStudent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.appBackgroundColor,
      appBar: CommonAppBar(
        title: 'Student Profile',
        backgroundColor: Colors.white,
        showText: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
        child: Column(
          children: [
            _headerCard(context),
            const SizedBox(height: 10),
           // _markStudentCard(),
            const SizedBox(height: 10),
            _sectionCard(
              icon: Icons.person_outline_rounded,
              title: 'Personal Information',
              rows: _personalRows(),
            ),
            _sectionCard(
              icon: Icons.school_outlined,
              title: 'Academic Information',
              rows: _academicRows(),
            ),
            _sectionCard(
              icon: Icons.family_restroom_outlined,
              title: 'Parent Information',
              rows: _parentRows(),
            ),
            _sectionCard(
              icon: Icons.location_on_outlined,
              title: 'Address',
              rows: _addressRows(),
            ),
            _markStudentCard(context),
          ],
        ),
      ),
    );
  }

  Widget _headerCard(BuildContext context) {
    final isActive = (_student.status ?? 0) == 1;
    final hasPhoto = _student.profilePhotoUrl?.isNotEmpty ?? false;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.btnColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.btnColor.withOpacity(0.15),
                    AppTheme.mainColor.withOpacity(0.08),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
          ),
          Positioned(
            top: 8, right: 10,
            child: GestureDetector(
              onTap: () => _openEdit(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.btnColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.edit, size: 16, color: AppTheme.btnColor),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.btnColor.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: AppTheme.appBackgroundColor,
                          backgroundImage: hasPhoto
                              ? NetworkImage(_student.profilePhotoUrl!)
                              : null,
                          child: !hasPhoto
                              ? Icon(Icons.person_rounded,
                                  size: 36, color: AppTheme.graySubTitleColor)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 2, right: 2,
                        child: Container(
                          width: 13, height: 13,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? AppTheme.mainColor
                                : AppTheme.backBtnBgColor,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_student.name ?? '-',
                      style: MyStyles.boldText(size: 16, color: AppTheme.black_Color)),
                  const SizedBox(height: 3),
                  Text(_classSection(),
                      style: MyStyles.mediumText(size: 12, color: AppTheme.btnColor)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6, runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: [
                      _chip(
                        label: isActive ? 'Active' : 'Inactive',
                        bgColor: isActive
                            ? AppTheme.mainColor.withOpacity(0.1)
                            : AppTheme.redBtnBgColor.withOpacity(0.1),
                        textColor: isActive
                            ? AppTheme.mainColor
                            : AppTheme.redBtnBgColor,
                      ),
                      if (_sessionName().isNotEmpty)
                        _chip(
                          label: _sessionName(),
                          bgColor: AppTheme.btnColor.withOpacity(0.1),
                          textColor: AppTheme.btnColor,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _markStudentCard(context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppTheme.btnColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(Icons.flag_outlined, size: 14, color: AppTheme.btnColor),
              ),
              const SizedBox(width: 8),
              Text('Mark Student',
                  style: MyStyles.boldText(size: 13, color: AppTheme.black_Color)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  title: 'TC',
                  height: 44,
                  color: AppTheme.redBtnBgColor,
                  onTap: () => _showComingSoon(context, 'TC'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  title: 'Not in my class',
                  height: 44,
                  color: AppTheme.graySubTitleColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create: (_) => StudentFormCubit()
                                ..loadFromSchoolId(schoolId: schoolId, schoolName: ''),
                            ),
                            BlocProvider(
                              create: (_) => StudentFormDataCubit()..load(schoolId),
                            ),
                            BlocProvider(create: (_) => AddStudentCubit()),
                          ],
                          child: AddStudentFormPage(
                            schoolId: schoolId,
                            editStudent: _student,
                            initialTab: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.btnColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.rocket_launch_outlined, size: 36, color: AppTheme.btnColor),
              ),
              const SizedBox(height: 16),
              Text('Coming Soon',
                  style: MyStyles.boldText(size: 18, color: AppTheme.black_Color)),
              const SizedBox(height: 8),
              Text(
                '"$feature" feature is coming soon.\nStay tuned for updates!',
                textAlign: TextAlign.center,
                style: MyStyles.regularText(size: 13, color: AppTheme.graySubTitleColor),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  title: 'OK',
                  height: 44,
                  color: AppTheme.btnColor,
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip({
    required String label,
    required Color bgColor,
    required Color textColor,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: MyStyles.mediumText(size: 11, color: textColor)),
      );

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required List<_InfoRow> rows,
  }) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.btnColor.withOpacity(0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppTheme.btnColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(icon, size: 14, color: AppTheme.btnColor),
                ),
                const SizedBox(width: 8),
                Text(title,
                    style: MyStyles.boldText(
                        size: 13, color: AppTheme.black_Color)),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.LineColor),
          Padding(
              padding: const EdgeInsets.all(12), child: _buildGrid(rows)),
        ],
      ),
    );
  }

  Widget _buildGrid(List<_InfoRow> rows) {
    final widgets = <Widget>[];
    for (int i = 0; i < rows.length; i += 2) {
      final left = rows[i];
      final right = i + 1 < rows.length ? rows[i + 1] : null;
      widgets.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _cell(left.label, left.value)),
          if (right != null) ...[
            const SizedBox(width: 10),
            Expanded(child: _cell(right.label, right.value)),
          ] else
            const Expanded(child: SizedBox()),
        ],
      ));
      if (i + 2 < rows.length)
        widgets.add(Divider(height: 16, color: AppTheme.LineColor));
    }
    return Column(children: widgets);
  }

  Widget _cell(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: MyStyles.regularText(
                  size: 10, color: AppTheme.graySubTitleColor)),
          const SizedBox(height: 3),
          Text(value.isEmpty ? '-' : value,
              style: MyStyles.mediumText(size: 12, color: AppTheme.black_Color)),
        ],
      );

  List<_InfoRow> _personalRows() => [
        _InfoRow('Student Name', _student.name ?? ''),
        _InfoRow('Login ID', _student.loginId ?? ''),
        _InfoRow('Email', _student.email?.toString() ?? ''),
        _InfoRow('Phone', _student.phone?.toString() ?? ''),
        _InfoRow('WhatsApp', _student.whatsappPhone?.toString() ?? ''),
        _InfoRow('Gender', _cap(_student.gender?.toString() ?? '')),
        _InfoRow('Date of Birth', _student.dob ?? ''),
        _InfoRow('Blood Group', _student.bloodGroup?.toString() ?? ''),
        _InfoRow('Aadhar No', _student.aadharNo?.toString() ?? ''),
        _InfoRow('UID No', _student.uidNo?.toString() ?? ''),
        _InfoRow('NIC ID', _student.studentNicId?.toString() ?? ''),
        _InfoRow('Caste', _student.caste?.toString() ?? ''),
        _InfoRow('Religion', _student.religion?.toString() ?? ''),
        _InfoRow('RTE Student', _student.isRteStudent?.toString() ?? ''),
      ].where((r) => r.value.isNotEmpty).toList();

  List<_InfoRow> _academicRows() => [
        _InfoRow('Class', _student.datumClass?.nameWithprefix ?? ''),
        _InfoRow('Section', _student.section?.name ?? ''),
        _InfoRow('Roll No', _student.rollNo?.toString() ?? ''),
        _InfoRow('Reg No', _student.regNo?.toString() ?? ''),
        _InfoRow('Admission No', _student.admissionNo?.toString() ?? ''),
        _InfoRow('SR No', _student.srNo ?? ''),
        _InfoRow('RFID No', _student.rfidNo?.toString() ?? ''),
        _InfoRow('Transport',
            _cap((_student.transportMode?.toString() ?? '').replaceAll('_', ' '))),
      ].where((r) => r.value.isNotEmpty).toList();

  List<_InfoRow> _parentRows() => [
        _InfoRow('Father Name', _student.fatherName ?? ''),
        _InfoRow('Father Phone', _student.fatherPhone ?? ''),
        _InfoRow('Father WhatsApp', _student.fatherWphone?.toString() ?? ''),
        _InfoRow('Father Email', _student.fatherEmail?.toString() ?? ''),
        _InfoRow('Mother Name', _student.motherName ?? ''),
        _InfoRow('Mother Phone', _student.motherPhone?.toString() ?? ''),
        _InfoRow('Mother WhatsApp', _student.motherWphone?.toString() ?? ''),
        _InfoRow('Mother Email', _student.motherEmail?.toString() ?? ''),
      ].where((r) => r.value.isNotEmpty).toList();

  List<_InfoRow> _addressRows() => [
        _InfoRow('Address', _student.address ?? ''),
        _InfoRow('Pincode', _student.pincode?.toString() ?? ''),
      ].where((r) => r.value.isNotEmpty).toList();

  String _classSection() {
    final cls = _student.datumClass?.nameWithprefix ?? '';
    final sec = _student.section?.name ?? '';
    if (cls.isEmpty && sec.isEmpty) return '-';
    if (sec.isEmpty) return cls;
    return '$cls - $sec';
  }

  String _sessionName() {
    final raw = _student.session?.name?.toString() ?? '';
    return raw.replaceAll('SessionName.THE_', '').replaceAll('_', '-');
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
}
