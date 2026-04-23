import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/Widgets/shimmer_loader.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/models/staff/StaffDetailModel.dart';
import 'package:idmitra/models/staff/StaffListModel.dart';
import 'package:idmitra/providers/staff_detail/staff_detail_cubit.dart';
import 'package:idmitra/screens/staff/add_staff_form.dart';

class StaffProfilePage extends StatelessWidget {
  final StaffListModel staff;
  final String schoolId;

  const StaffProfilePage({
    super.key,
    required this.staff,
    required this.schoolId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StaffDetailCubit()..load(schoolId, staff.uuid),
      child: _StaffProfileBody(staff: staff, schoolId: schoolId),
    );
  }
}

class _StaffProfileBody extends StatefulWidget {
  final StaffListModel staff;
  final String schoolId;
  const _StaffProfileBody({required this.staff, required this.schoolId});

  @override
  State<_StaffProfileBody> createState() => _StaffProfileBodyState();
}

class _StaffProfileBodyState extends State<_StaffProfileBody> {
  StaffDetailModel? _updatedStaff;

  void _openEdit(BuildContext context, StaffDetailModel staff) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddStaffFormPage(
          editStudent: staff,
          schoolId: widget.schoolId,
        ),
      ),
    ).then((result) {
      if (!mounted) return;
      if (result is StaffDetailModel) {
        context.read<StaffDetailCubit>().emitUpdated(result);
      } else if (result == true) {
        context.read<StaffDetailCubit>().load(widget.schoolId, widget.staff.uuid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.appBackgroundColor,
      appBar: CommonAppBar(
        title: 'Staff Profile',
        backgroundColor: Colors.white,
        showText: true,
      ),
      body: BlocBuilder<StaffDetailCubit, StaffDetailState>(
        builder: (context, state) {
          if (state.loading) {
            return const ShimmerDetail(sectionRowCounts: [4, 4, 3]);
          }
          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                  const SizedBox(height: 12),
                  Text(state.error!,
                      style: MyStyles.regularText(size: 13, color: Colors.red),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.read<StaffDetailCubit>().load(
                          widget.schoolId, widget.staff.uuid),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final s = state.staff;
          if (s == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
            child: Column(
              children: [
                _headerCard(context, s),
                const SizedBox(height: 10),
                _sectionCard(
                  icon: Icons.person_outline_rounded,
                  title: 'Staff Details',
                  rows: _staffRows(s),
                ),
                _sectionCard(
                  icon: Icons.work_outline_rounded,
                  title: 'Employment Details',
                  rows: _employmentRows(s),
                ),
                _sectionCard(
                  icon: Icons.family_restroom_outlined,
                  title: 'Personal Details',
                  rows: _personalRows(s),
                ),
                _sectionCard(
                  icon: Icons.location_on_outlined,
                  title: 'Address',
                  rows: _addressRows(s),
                ),
                if (s.emergencyContacts.isNotEmpty) _emergencyContactsCard(s),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _headerCard(BuildContext context, StaffDetailModel staff) {
    final isActive = staff.status == 1;
    final hasPhoto = staff.profilePhotoUrl.isNotEmpty;
    final initials = staff.name.trim().isNotEmpty
        ? staff.name
              .trim()
              .split(' ')
              .map((w) => w[0])
              .take(2)
              .join()
              .toUpperCase()
        : '?';

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
          // Top gradient band
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
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
          ),
          // Edit button
          Positioned(
            top: 8,
            right: 10,
            child: GestureDetector(
              onTap: () => _openEdit(context, staff),
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
                children: [
                  // Avatar
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
                              ? NetworkImage(staff.profilePhotoUrl)
                              : null,
                          child: !hasPhoto
                              ? Text(
                                  initials,
                                  style: MyStyles.boldText(
                                    size: 20,
                                    color: AppTheme.btnColor,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      // Status dot
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? Colors.green : Colors.red,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    staff.name,
                    style: MyStyles.boldText(
                      size: 16,
                      color: AppTheme.black_Color,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (staff.designation.isNotEmpty)
                    Text(
                      staff.designation,
                      style: MyStyles.mediumText(
                        size: 12,
                        color: AppTheme.btnColor,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: [
                      _chip(
                        label: isActive ? 'Active' : 'Inactive',
                        bgColor: isActive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        textColor: isActive ? Colors.green : Colors.red,
                      ),
                      if (staff.roleName.isNotEmpty)
                        _chip(
                          label: staff.roleName,
                          bgColor: AppTheme.btnColor.withOpacity(0.1),
                          textColor: AppTheme.btnColor,
                        ),
                      if (staff.department.isNotEmpty)
                        _chip(
                          label: staff.department,
                          bgColor: AppTheme.mainColor.withOpacity(0.1),
                          textColor: AppTheme.mainColor,
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

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required List<_Row> rows,
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

  Widget _buildGrid(List<_Row> rows) {
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

  Widget _emergencyContactsCard(StaffDetailModel staff) {
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
                  child: Icon(
                    Icons.emergency_outlined,
                    size: 14,
                    color: AppTheme.btnColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Emergency Contacts',
                  style: MyStyles.boldText(
                    size: 13,
                    color: AppTheme.black_Color,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.LineColor),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: staff.emergencyContacts.asMap().entries.map<Widget>((
                entry,
              ) {
                final i = entry.key;
                final c = entry.value;
                return Column(
                  children: [
                    if (i > 0) Divider(height: 16, color: AppTheme.LineColor),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _cell('Name', c.name)),
                        const SizedBox(width: 10),
                        Expanded(child: _cell('Relation', c.relation)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _cell('Phone', c.phone)),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<_Row> _staffRows(StaffDetailModel staff) => [
    _Row('Name', staff.name),
    _Row('Email', staff.email),
    _Row('Phone', staff.phone),
    _Row('WhatsApp', staff.whatsappPhone ?? ''),
    _Row('Login ID', staff.loginId ?? ''),
  ].where((r) => r.value.isNotEmpty).toList();

  List<_Row> _employmentRows(StaffDetailModel staff) => [
    _Row('Designation', staff.designation),
    _Row('Department', staff.department),
    _Row('Role', staff.roleName),
    _Row('Employee ID', staff.employeeId ?? ''),
    _Row('National Code', staff.nationalCode ?? ''),
    _Row('Date of Joining', staff.dateOfJoining ?? ''),
  ].where((r) => r.value.isNotEmpty).toList();

  List<_Row> _personalRows(StaffDetailModel staff) => [
    _Row('Father Name', staff.fatherName ?? ''),
    _Row('Mother Name', staff.motherName ?? ''),
    _Row('Husband Name', staff.husbandName ?? ''),
    _Row('Date of Birth', staff.dob ?? ''),
    _Row('Gender', _cap(staff.gender ?? '')),
    _Row('Blood Group', staff.bloodGroup ?? ''),
  ].where((r) => r.value.isNotEmpty).toList();

  List<_Row> _addressRows(StaffDetailModel staff) => [
    _Row('Address', staff.address ?? ''),
    _Row('Pincode', staff.pincode ?? ''),
  ].where((r) => r.value.isNotEmpty).toList();

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

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}

class _Row {
  final String label;
  final String value;
  const _Row(this.label, this.value);
}
