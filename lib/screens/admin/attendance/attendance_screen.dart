import 'package:flutter/material.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/Widgets/shimmer_loader.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/utils/MyStyles.dart';

class _ClassItem {
  final String id;
  final String name;
  const _ClassItem(this.id, this.name);
}

class _StudentAttendance {
  final String name;
  final String rollNo;
  final String avatarInitial;
  final String status;
  const _StudentAttendance({
    required this.name,
    required this.rollNo,
    required this.avatarInitial,
    required this.status,
  });
}

const _classes = [
  _ClassItem('1', 'Class 1 - A'),
  _ClassItem('2', 'Class 1 - B'),
  _ClassItem('3', 'Class 2 - A'),
  _ClassItem('4', 'Class 3 - A'),
  _ClassItem('5', 'Class 4 - B'),
];

const _demoStudents = [
  _StudentAttendance(
    name: 'Aarav Sharma',
    rollNo: '01',
    avatarInitial: 'A',
    status: 'present',
  ),
  _StudentAttendance(
    name: 'Priya Verma',
    rollNo: '02',
    avatarInitial: 'P',
    status: 'absent',
  ),
  _StudentAttendance(
    name: 'Rohan Gupta',
    rollNo: '03',
    avatarInitial: 'R',
    status: 'late',
  ),
  _StudentAttendance(
    name: 'Sneha Patel',
    rollNo: '04',
    avatarInitial: 'S',
    status: 'leave',
  ),
  _StudentAttendance(
    name: 'Karan Mehta',
    rollNo: '05',
    avatarInitial: 'K',
    status: 'present',
  ),
  _StudentAttendance(
    name: 'Divya Singh',
    rollNo: '06',
    avatarInitial: 'D',
    status: 'present',
  ),
  _StudentAttendance(
    name: 'Amit Joshi',
    rollNo: '07',
    avatarInitial: 'A',
    status: 'absent',
  ),
  _StudentAttendance(
    name: 'Neha Yadav',
    rollNo: '08',
    avatarInitial: 'N',
    status: 'present',
  ),
  _StudentAttendance(
    name: 'Vikas Tiwari',
    rollNo: '09',
    avatarInitial: 'V',
    status: 'late',
  ),
  _StudentAttendance(
    name: 'Pooja Mishra',
    rollNo: '10',
    avatarInitial: 'P',
    status: 'present',
  ),
];

Color _statusColor(String status) {
  switch (status) {
    case 'present':
      return Colors.green;
    case 'absent':
      return Colors.red;
    case 'late':
      return Colors.orange;
    case 'leave':
      return Colors.blue;
    default:
      return Colors.grey;
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'present':
      return 'Present';
    case 'absent':
      return 'Absent';
    case 'late':
      return 'Late';
    case 'leave':
      return 'Leave';
    default:
      return status;
  }
}

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const _weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

class AttendanceScreen extends StatefulWidget {
  final String schoolId;
  const AttendanceScreen({super.key, required this.schoolId});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDate;
  _ClassItem? _selectedClass;
  String _searchQuery = '';
  String _statusFilter = 'all';
  bool _loading = false;
  List<_StudentAttendance> _students = [];
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onClassSelected(_ClassItem? cls) {
    setState(() {
      _selectedClass = cls;
      _loading = true;
      _students = [];
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _loading = false;
          _students = cls != null ? _demoStudents : [];
        });
      }
    });
  }

  List<_StudentAttendance> get _filtered {
    return _students.where((s) {
      final matchSearch =
          _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchStatus = _statusFilter == 'all' || s.status == _statusFilter;
      return matchSearch && matchStatus;
    }).toList();
  }

  int _count(String status) =>
      _students.where((s) => s.status == status).length;

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: AppTheme.appBackgroundColor,
      appBar: CommonAppBar(
        title: 'Attendance',
        showBackButton: true,
        showDivider: true,
      ),
      body: isWideScreen
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 270,
                  child: _SidePanel(
                    classes: _classes,
                    selectedClass: _selectedClass,
                    focusedMonth: _focusedMonth,
                    selectedDate: _selectedDate,
                    onClassSelected: _onClassSelected,
                    onMonthChanged: (m) => setState(() => _focusedMonth = m),
                    onDateSelected: (d) => setState(() => _selectedDate = d),
                    presentCount: _count('present'),
                    absentCount: _count('absent'),
                    lateCount: _count('late'),
                    leaveCount: _count('leave'),
                    totalCount: _students.length,
                  ),
                ),
                Expanded(
                  child: _MainPanel(
                    selectedClass: _selectedClass,
                    selectedDate: _selectedDate,
                    loading: _loading,
                    students: _filtered,
                    allStudents: _students,
                    searchCtrl: _searchCtrl,
                    searchQuery: _searchQuery,
                    statusFilter: _statusFilter,
                    onSearchChanged: (v) => setState(() => _searchQuery = v),
                    onStatusFilterChanged: (v) =>
                        setState(() => _statusFilter = v),
                  ),
                ),
              ],
            )
          : _MobileLayout(
              classes: _classes,
              selectedClass: _selectedClass,
              onClassSelected: _onClassSelected,
              focusedMonth: _focusedMonth,
              selectedDate: _selectedDate,
              onMonthChanged: (m) => setState(() => _focusedMonth = m),
              onDateSelected: (d) => setState(() => _selectedDate = d),
              presentCount: _count('present'),
              absentCount: _count('absent'),
              lateCount: _count('late'),
              leaveCount: _count('leave'),
              totalCount: _students.length,
              loading: _loading,
              students: _filtered,
              allStudents: _students,
              searchCtrl: _searchCtrl,
              searchQuery: _searchQuery,
              statusFilter: _statusFilter,
              onSearchChanged: (v) => setState(() => _searchQuery = v),
              onStatusFilterChanged: (v) => setState(() => _statusFilter = v),
            ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final List<_ClassItem> classes;
  final _ClassItem? selectedClass;
  final ValueChanged<_ClassItem?> onClassSelected;
  final DateTime focusedMonth;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDateSelected;
  final int presentCount, absentCount, lateCount, leaveCount, totalCount;
  final bool loading;
  final List<_StudentAttendance> students;
  final List<_StudentAttendance> allStudents;
  final TextEditingController searchCtrl;
  final String searchQuery;
  final String statusFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusFilterChanged;

  const _MobileLayout({
    required this.classes,
    required this.selectedClass,
    required this.onClassSelected,
    required this.focusedMonth,
    required this.selectedDate,
    required this.onMonthChanged,
    required this.onDateSelected,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.leaveCount,
    required this.totalCount,
    required this.loading,
    required this.students,
    required this.allStudents,
    required this.searchCtrl,
    required this.searchQuery,
    required this.statusFilter,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: _ClassCard(
              classes: classes,
              selected: selectedClass,
              onChanged: onClassSelected,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: _MainPanel(
              selectedClass: selectedClass,
              selectedDate: selectedDate,
              loading: loading,
              students: students,
              allStudents: allStudents,
              searchCtrl: searchCtrl,
              searchQuery: searchQuery,
              statusFilter: statusFilter,
              onSearchChanged: onSearchChanged,
              onStatusFilterChanged: onStatusFilterChanged,
              wide: false,
            ),
          ),
        ),
      ],
    );
  }
}

class _SidePanel extends StatelessWidget {
  final List<_ClassItem> classes;
  final _ClassItem? selectedClass;
  final DateTime focusedMonth;
  final DateTime? selectedDate;
  final ValueChanged<_ClassItem?> onClassSelected;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDateSelected;
  final int presentCount, absentCount, lateCount, leaveCount, totalCount;

  const _SidePanel({
    required this.classes,
    required this.selectedClass,
    required this.focusedMonth,
    required this.selectedDate,
    required this.onClassSelected,
    required this.onMonthChanged,
    required this.onDateSelected,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.leaveCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ClassCard(
            classes: classes,
            selected: selectedClass,
            onChanged: onClassSelected,
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final List<_ClassItem> classes;
  final _ClassItem? selected;
  final ValueChanged<_ClassItem?> onChanged;

  const _ClassCard({
    required this.classes,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.btnColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.class_outlined,
                  size: 16,
                  color: AppTheme.btnColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Select Class',
                style: MyStyles.mediumTxt(AppTheme.black_Color, 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ClassDropdown(
            classes: classes,
            selected: selected,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}



class _MainPanel extends StatelessWidget {
  final _ClassItem? selectedClass;
  final DateTime? selectedDate;
  final bool loading;
  final List<_StudentAttendance> students;
  final List<_StudentAttendance> allStudents;
  final TextEditingController searchCtrl;
  final String searchQuery;
  final String statusFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusFilterChanged;

  final bool wide;

  const _MainPanel({
    required this.selectedClass,
    required this.selectedDate,
    required this.loading,
    required this.students,
    required this.allStudents,
    required this.searchCtrl,
    required this.searchQuery,
    required this.statusFilter,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    this.wide = true,
  });

  String get _dateLabel {
    final now = DateTime.now();
    final d = selectedDate ?? now;
    return '${_weekDays[d.weekday % 7]}, ${_monthNames[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: wide
          ? const EdgeInsets.fromLTRB(6, 12, 12, 12)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedClass?.name ?? 'Select Class',
                        style: MyStyles.boldTxt(AppTheme.black_Color, 18),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.btnColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.btnColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 16,
                            color: AppTheme.btnColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${allStudents.length}',
                            style: MyStyles.mediumTxt(AppTheme.btnColor, 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: AppTheme.graySubTitleColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _dateLabel,
                      style: MyStyles.regularTxt(
                        AppTheme.graySubTitleColor,
                        12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchCtrl,
                    style: MyStyles.regularTxt(AppTheme.black_Color, 13),
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.appBackgroundColor,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      hintText: 'Search by name...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.backBtnBgColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.btnColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintStyle: MyStyles.regularTxt(
                        AppTheme.graySubTitleColor,
                        13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _StatusDropdown(
                  value: statusFilter,
                  onChanged: onStatusFilterChanged,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1),

          if (wide) ...[
            Expanded(
              child: loading
                  ? const ShimmerList(expanded: false)
                  : selectedClass == null
                      ? const _EmptyState(
                          icon: Icons.class_outlined,
                          message: 'Please select a class to view attendance',
                        )
                      : students.isEmpty
                          ? const _EmptyState(
                              icon: Icons.search_off_rounded,
                              message: 'No students found',
                            )
                          : _StudentList(students: students),
            ),
          ] else ...[
            if (loading)
              const ShimmerList(expanded: false)
            else if (selectedClass == null)
              const _EmptyState(
                icon: Icons.class_outlined,
                message: 'Please select a class to view attendance',
              )
            else if (students.isEmpty)
              const _EmptyState(
                icon: Icons.search_off_rounded,
                message: 'No students found',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                itemCount: students.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _StudentTile(student: students[i]),
              ),
          ],

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  'Showing ${students.length} of ${allStudents.length} students',
                  style: MyStyles.regularTxt(AppTheme.graySubTitleColor, 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassDropdown extends StatelessWidget {
  final List<_ClassItem> classes;
  final _ClassItem? selected;
  final ValueChanged<_ClassItem?> onChanged;

  const _ClassDropdown({
    required this.classes,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.appBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.backBtnBgColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_ClassItem>(
          value: selected,
          isExpanded: true,
          hint: Text(
            'Select Class',
            style: MyStyles.regularTxt(AppTheme.graySubTitleColor, 13),
          ),
          style: MyStyles.regularTxt(AppTheme.black_Color, 13),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          items: classes
              .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _StatusDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = ['all', 'present', 'absent', 'late', 'leave'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.appBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.backBtnBgColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          style: MyStyles.regularTxt(AppTheme.black_Color, 13),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          items: options
              .map(
                (o) => DropdownMenuItem(
                  value: o,
                  child: Text(o == 'all' ? 'All Status' : _statusLabel(o)),
                ),
              )
              .toList(),
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ),
    );
  }
}

class _StudentList extends StatelessWidget {
  final List<_StudentAttendance> students;
  const _StudentList({required this.students});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _StudentTile(student: students[i]),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final _StudentAttendance student;
  const _StudentTile({required this.student});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(student.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.appBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.12),
            child: Text(
              student.avatarInitial,
              style: MyStyles.boldTxt(color, 15),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: MyStyles.mediumTxt(AppTheme.black_Color, 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'Roll No: ${student.rollNo}',
                  style: MyStyles.regularTxt(AppTheme.graySubTitleColor, 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              _statusLabel(student.status),
              style: MyStyles.mediumTxt(color, 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            message,
            style: MyStyles.regularTxt(AppTheme.graySubTitleColor, 13),
          ),
        ],
      ),
    );
  }
}
