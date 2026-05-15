import 'package:flutter/material.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';

class EmployeeMarkAttendance extends StatefulWidget {
  const EmployeeMarkAttendance({super.key});

  @override
  State<EmployeeMarkAttendance> createState() => _EmployeeMarkAttendanceState();
}

class _EmployeeMarkAttendanceState extends State<EmployeeMarkAttendance> {
  late DateTime _currentMonth;
  late int _selectedDate;
  late ScrollController _dateScrollCtrl;

  String _selectedClass = 'Class 12-A';

  static const _monthNames = [
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

  static const _dayNames = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  final List<Map<String, dynamic>> _students = [
    {
      'name': 'Sumit Sharma',
      'rollNo': '12th-A',
      'id': 'Roll No: 01',
      'present': true,
    },
    {
      'name': 'Sumit Sharma',
      'rollNo': '12th-A',
      'id': 'Roll No: 02',
      'present': false,
    },
    {
      'name': 'Sumit Sharma',
      'rollNo': '12th-A',
      'id': 'Roll No: 03',
      'present': true,
    },
    {
      'name': 'Sumit Sharma',
      'rollNo': '12th-A',
      'id': 'Roll No: 04',
      'present': false,
    },
    {
      'name': 'Sumit Sharma',
      'rollNo': '12th-A',
      'id': 'Roll No: 05',
      'present': true,
    },
  ];

  int get _presentCount => _students.where((s) => s['present'] == true).length;
  int get _absentCount => _students.where((s) => s['present'] == false).length;
  int get _totalCount => _students.length;

  int get _daysInMonth =>
      DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _currentMonth.year == now.year && _currentMonth.month == now.month;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _selectedDate = now.day;
    _dateScrollCtrl = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final offset = (_selectedDate - 1) * 58.0;
      if (_dateScrollCtrl.hasClients) {
        _dateScrollCtrl.jumpTo(
          offset.clamp(0, _dateScrollCtrl.position.maxScrollExtent),
        );
      }
    });
  }

  @override
  void dispose() {
    _dateScrollCtrl.dispose();
    super.dispose();
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);

      final now = DateTime.now();
      if (_currentMonth.year == now.year && _currentMonth.month == now.month) {
        _selectedDate = now.day;
      } else {
        _selectedDate = 1;
      }
    });
    _scrollToSelected();
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      final now = DateTime.now();
      if (_currentMonth.year == now.year && _currentMonth.month == now.month) {
        _selectedDate = now.day;
      } else {
        _selectedDate = 1;
      }
    });
    _scrollToSelected();
  }

  void _scrollToSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_dateScrollCtrl.hasClients) {
        final offset = (_selectedDate - 1) * 58.0;
        _dateScrollCtrl.animateTo(
          offset.clamp(0, _dateScrollCtrl.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.appBackgroundColor,
      appBar: const CommonAppBar(title: 'Mark attendance'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _monthSelector(),
                  const SizedBox(height: 16),
                  _dateSelector(),
                  const SizedBox(height: 20),
                  _classDropdown(),
                  const SizedBox(height: 20),
                  _classHeader(),
                  const SizedBox(height: 12),
                  ..._students.asMap().entries.map((e) => _studentCard(e.key)),
                ],
              ),
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  Widget _monthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 22),
            onPressed: _prevMonth,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Text(
            _monthNames[_currentMonth.month - 1],
            style: MyStyles.boldText(size: 16, color: AppTheme.black_Color),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 22),
            onPressed: _nextMonth,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _dateSelector() {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        controller: _dateScrollCtrl,
        scrollDirection: Axis.horizontal,
        itemCount: _daysInMonth,
        itemBuilder: (context, index) {
          final day = index + 1;
          final isSelected = day == _selectedDate;

          final weekday = DateTime(
            _currentMonth.year,
            _currentMonth.month,
            day,
          ).weekday;
          final dayLabel = _dayNames[weekday % 7];

          return GestureDetector(
            onTap: () => setState(() {
              _selectedDate = day;
            }),
            child: Container(
              width: 50,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.btnColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayLabel,
                    style: MyStyles.regularText(
                      size: 12,
                      color: isSelected
                          ? Colors.white
                          : AppTheme.graySubTitleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$day',
                    style: MyStyles.boldText(
                      size: 16,
                      color: isSelected ? Colors.white : AppTheme.black_Color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _classDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Class',
          style: MyStyles.boldText(size: 14, color: AppTheme.black_Color),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.backBtnBgColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedClass,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              style: MyStyles.regularText(
                size: 14,
                color: AppTheme.black_Color,
              ),
              items: [
                'Class 12-A',
                'Class 12-B',
                'Class 11-A',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedClass = v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _classHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedClass,
              style: MyStyles.boldText(size: 18, color: AppTheme.black_Color),
            ),
            Text(
              'Mathematics • Period 2',
              style: MyStyles.regularText(
                size: 13,
                color: AppTheme.graySubTitleColor,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => setState(() {
            for (var s in _students) {
              s['present'] = true;
            }
          }),
          child: Text(
            'Mark all Present',
            style: MyStyles.mediumText(size: 13, color: AppTheme.btnColor),
          ),
        ),
      ],
    );
  }

  Widget _studentCard(int index) {
    final student = _students[index];
    final isPresent = student['present'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 50,
              width: 50,
              color: Colors.grey.shade200,
              child: const Icon(Icons.person, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        student['name'],
                        style: MyStyles.boldText(
                          size: 14,
                          color: AppTheme.black_Color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '• ${student['rollNo']}',
                      style: MyStyles.boldText(
                        size: 14,
                        color: AppTheme.btnColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  student['id'],
                  style: MyStyles.regularText(
                    size: 12,
                    color: AppTheme.graySubTitleColor,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _toggleBtn(
                label: 'P',
                isActive: isPresent,
                activeColor: Colors.green,
                onTap: () => setState(() => _students[index]['present'] = true),
              ),
              const SizedBox(width: 8),
              _toggleBtn(
                label: 'A',
                isActive: !isPresent,
                activeColor: Colors.red,
                onTap: () =>
                    setState(() => _students[index]['present'] = false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn({
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: isActive ? activeColor : activeColor.withOpacity(0.08),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? activeColor : activeColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: MyStyles.boldText(
              size: 15,
              color: isActive ? Colors.white : activeColor.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Marked : $_presentCount/$_totalCount',
                style: MyStyles.boldText(size: 14, color: AppTheme.black_Color),
              ),
              Text(
                'Absents : $_absentCount',
                style: MyStyles.boldText(size: 14, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.btnColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Submit Attendance',
                style: MyStyles.boldText(size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
