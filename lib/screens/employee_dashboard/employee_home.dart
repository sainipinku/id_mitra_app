import 'package:flutter/material.dart';
import 'package:idmitra/Widgets/shimmer_loader.dart';
import 'package:idmitra/Widgets/svg_file.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/screens/employee_dashboard/employee_mark_attendance/employee_mark_attendance.dart';
import 'package:idmitra/utils/navigation_utils.dart';

class EmployeeHome extends StatefulWidget {
  const EmployeeHome({super.key});

  @override
  State<EmployeeHome> createState() => _EmployeeHomeState();
}

class _EmployeeHomeState extends State<EmployeeHome> {
  final TextEditingController _searchCtrl = TextEditingController();

  static const _myStudents = '124';
  static const _issued = '89';
  static const _pending = '16';

  static const _recentRequests = [
    {
      'name': 'Sumit Sharma',
      'father': 'Shubham Sharma',
      'classSection': 'Class: 8  Section: B',
      'status': 'IN PROGRESS',
      'photo': null,
    },
    {
      'name': 'Sumit Sharma',
      'father': 'Shubham Sharma',
      'classSection': 'Class: 8  Section: B',
      'status': 'IN PROGRESS',
      'photo': null,
    },
    {
      'name': 'Sumit Sharma',
      'father': 'Shubham Sharma',
      'classSection': 'Class: 9  Section: B',
      'status': 'IN PROGRESS',
      'photo': null,
    },
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topStatsRow(),
          const SizedBox(height: 20),
          _sectionHeader('Student Directory', onViewAll: () {}),
          const SizedBox(height: 10),
          _searchBar(),
          const SizedBox(height: 14),
          _attendanceButtons(),
          const SizedBox(height: 20),
          _sectionHeader('Recent Requests', onViewAll: () {}),
          const SizedBox(height: 10),
          ..._recentRequests.map(_requestCard),
        ],
      ),
    );
  }

  Widget _topStatsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/frame1.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.people,
                        size: 60,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'My Students',
                  style: MyStyles.regularText(
                    size: 13,
                    color: AppTheme.graySubTitleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _myStudents,
                  style: MyStyles.boldText(
                    size: 28,
                    color: AppTheme.black_Color,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            children: [
              _miniStatCard(
                label: 'Issued',
                value: _issued,
                icon: Icons.credit_card_outlined,
                iconColor: AppTheme.btnColor,
              ),
              const SizedBox(height: 12),
              _miniStatCard(
                label: 'Pending',
                value: _pending,
                icon: Icons.hourglass_empty_outlined,
                iconColor: AppTheme.btnColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: MyStyles.regularText(
                  size: 13,
                  color: AppTheme.graySubTitleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: MyStyles.boldText(
                  size: 24,
                  color: AppTheme.black_Color,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.btn10perOpacityColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, {required VoidCallback onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: MyStyles.boldText(size: 16, color: AppTheme.black_Color),
        ),
        GestureDetector(
          onTap: onViewAll,
          child: Text(
            'View All >',
            style: MyStyles.regularText(size: 13, color: AppTheme.btnColor),
          ),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return TextField(
      controller: _searchCtrl,
      style: MyStyles.regularText(size: 14, color: AppTheme.black_Color),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        hintText: 'Search Student name and students ID...',
        prefixIcon: const Icon(Icons.search, size: 20),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.btnColor),
          borderRadius: BorderRadius.circular(12),
        ),
        hintStyle: MyStyles.regularText(
          size: 13,
          color: AppTheme.graySubTitleColor,
        ),
      ),
    );
  }

  Widget _attendanceButtons() {
    return Row(
      children: [
        Expanded(
          child: _attendanceBtn(
            label: 'Mark attendance',
            icon: Icons.calendar_today_outlined,
            color: AppTheme.mainColor,
            onTap: () => navigateWithTransition(
              context: context,
              page: const EmployeeMarkAttendance(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // View Attendance — coming soon
        // Expanded(
        //   child: _attendanceBtn(
        //     label: 'View attendance',
        //     icon: Icons.calendar_month_outlined,
        //     color: AppTheme.btnColor,
        //     onTap: () {},
        //   ),
        // ),
        Expanded(
          child: _attendanceBtn(
            label: 'Add Student',
            icon: Icons.person_add_alt_1_outlined,
            color: AppTheme.btnColor,
            onTap: () {
            },
          ),
        ),
      ],
    );
  }

  Widget _attendanceBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color,
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: MyStyles.mediumText(
                  size: 13,
                  color: AppTheme.black_Color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _requestCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 52,
              width: 52,
              color: Colors.grey.shade200,
              child: const Icon(Icons.person, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: MyStyles.boldText(
                    size: 14,
                    color: AppTheme.black_Color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Father name: ${item['father']}',
                  style: MyStyles.regularText(
                    size: 12,
                    color: AppTheme.graySubTitleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['classSection'],
                  style: MyStyles.regularText(
                    size: 12,
                    color: AppTheme.graySubTitleColor,
                  ),
                ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.orangeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item['status'],
              style: MyStyles.boldText(
                size: 10,
                color: AppTheme.orangeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
