import 'package:flutter/material.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/models/students/StudentsListModel.dart';

class StudentProfilePage extends StatelessWidget {
  final StudentDetailsData student;
  const StudentProfilePage({super.key, required this.student});

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
            _headerCard(),
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
          ],
        ),
      ),
    );
  }

  Widget _headerCard() {
    final isActive = (student.status ?? 0) == 1;
    final hasPhoto = student.profilePhotoUrl?.isNotEmpty ?? false;

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
            top: 0,
            left: 0,
            right: 0,
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
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
                              ? NetworkImage(student.profilePhotoUrl!)
                              : null,
                          child: !hasPhoto
                              ? Icon(
                                  Icons.person_rounded,
                                  size: 36,
                                  color: AppTheme.graySubTitleColor,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 13,
                          height: 13,
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
                  Text(
                    student.name ?? '-',
                    style: MyStyles.boldText(
                      size: 16,
                      color: AppTheme.black_Color,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _classSection(),
                    style: MyStyles.mediumText(
                      size: 12,
                      color: AppTheme.btnColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // chips row
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
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

  Widget _chip({
    required String label,
    required Color bgColor,
    required Color textColor,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label, style: MyStyles.mediumText(size: 11, color: textColor)),
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // section header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.btnColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
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
                Text(
                  title,
                  style: MyStyles.boldText(
                    size: 13,
                    color: AppTheme.black_Color,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.LineColor),
          Padding(padding: const EdgeInsets.all(12), child: _buildGrid(rows)),
        ],
      ),
    );
  }

  Widget _buildGrid(List<_InfoRow> rows) {
    final widgets = <Widget>[];
    for (int i = 0; i < rows.length; i += 2) {
      final left = rows[i];
      final right = i + 1 < rows.length ? rows[i + 1] : null;
      widgets.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _cell(left.label, left.value)),
            if (right != null) ...[
              const SizedBox(width: 10),
              Expanded(child: _cell(right.label, right.value)),
            ] else
              const Expanded(child: SizedBox()),
          ],
        ),
      );
      if (i + 2 < rows.length)
        widgets.add(Divider(height: 16, color: AppTheme.LineColor));
    }
    return Column(children: widgets);
  }

  Widget _cell(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: MyStyles.regularText(
          size: 10,
          color: AppTheme.graySubTitleColor,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        value.isEmpty ? '-' : value,
        style: MyStyles.mediumText(size: 12, color: AppTheme.black_Color),
      ),
    ],
  );

  List<_InfoRow> _personalRows() => [
    _InfoRow('Student Name', student.name ?? ''),
    _InfoRow('Login ID', student.loginId ?? ''),
    _InfoRow('Email', student.email?.toString() ?? ''),
    _InfoRow('Phone', student.phone?.toString() ?? ''),
    _InfoRow('WhatsApp', student.whatsappPhone?.toString() ?? ''),
    _InfoRow('Gender', _capitalize(student.gender?.toString() ?? '')),
    _InfoRow('Date of Birth', student.dob ?? ''),
    _InfoRow('Blood Group', student.bloodGroup?.toString() ?? ''),
    _InfoRow('Aadhar No', student.aadharNo?.toString() ?? ''),
    _InfoRow('UID No', student.uidNo?.toString() ?? ''),
    _InfoRow('NIC ID', student.studentNicId?.toString() ?? ''),
    _InfoRow('Caste', student.caste?.toString() ?? ''),
    _InfoRow('Religion', student.religion?.toString() ?? ''),
    _InfoRow('RTE Student', student.isRteStudent?.toString() ?? ''),
  ].where((r) => r.value.isNotEmpty).toList();

  List<_InfoRow> _academicRows() => [
    _InfoRow('Class', student.datumClass?.nameWithprefix ?? ''),
    _InfoRow('Section', student.section?.name ?? ''),
    _InfoRow('Roll No', student.rollNo?.toString() ?? ''),
    _InfoRow('Reg No', student.regNo?.toString() ?? ''),
    _InfoRow('Admission No', student.admissionNo?.toString() ?? ''),
    _InfoRow('SR No', student.srNo ?? ''),
    _InfoRow('RFID No', student.rfidNo?.toString() ?? ''),
    _InfoRow(
      'Transport',
      _capitalize(
        (student.transportMode?.toString() ?? '').replaceAll('_', ' '),
      ),
    ),
  ].where((r) => r.value.isNotEmpty).toList();

  List<_InfoRow> _parentRows() => [
    _InfoRow('Father Name', student.fatherName ?? ''),
    _InfoRow('Father Phone', student.fatherPhone ?? ''),
    _InfoRow('Father WhatsApp', student.fatherWphone?.toString() ?? ''),
    _InfoRow('Father Email', student.fatherEmail?.toString() ?? ''),
    _InfoRow('Mother Name', student.motherName ?? ''),
    _InfoRow('Mother Phone', student.motherPhone?.toString() ?? ''),
    _InfoRow('Mother WhatsApp', student.motherWphone?.toString() ?? ''),
    _InfoRow('Mother Email', student.motherEmail?.toString() ?? ''),
  ].where((r) => r.value.isNotEmpty).toList();

  List<_InfoRow> _addressRows() => [
    _InfoRow('Address', student.address ?? ''),
    _InfoRow('Pincode', student.pincode?.toString() ?? ''),
  ].where((r) => r.value.isNotEmpty).toList();

  String _classSection() {
    final cls = student.datumClass?.nameWithprefix ?? '';
    final sec = student.section?.name ?? '';
    if (cls.isEmpty && sec.isEmpty) return '-';
    if (sec.isEmpty) return cls;
    return '$cls - $sec';
  }

  String _sessionName() {
    final raw = student.session?.name?.toString() ?? '';
    return raw.replaceAll('SessionName.THE_', '').replaceAll('_', '-');
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
}
