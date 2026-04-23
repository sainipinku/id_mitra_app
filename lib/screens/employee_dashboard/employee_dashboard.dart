import 'package:flutter/material.dart';
import 'package:idmitra/Widgets/svg_file.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/screens/employee_dashboard/employee_home.dart';
import 'package:idmitra/screens/employee_dashboard/employee_report_screen/employee_report_screen.dart';
import 'package:idmitra/screens/employee_dashboard/employee_student_list/employee_student_list.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  int _selectedIndex = 0;

  static const _userName = 'Maharana Pratap Sr. Se..';
  static const _userRole = 'Id Mitra Employee';
  static const _notifCount = '1';

  final List<Widget> _pages = const [
    EmployeeHome(),
    EmployeeReportScreen(),
    EmployeeStudentsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.appBackgroundColor,
      appBar: _buildAppBar(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.person, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userName,
                    style: MyStyles.boldText(size: 16, color: AppTheme.black_Color),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _userRole,
                    style: MyStyles.regularText(size: 13, color: AppTheme.graySubTitleColor),
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.btn10perOpacityColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: svgIcon(
                      icon: 'assets/icons/home/notification.svg',
                      clr: AppTheme.btnColor,
                    ),
                  ),
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _notifCount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 0,
              currentIndex: _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i),
              selectedItemColor: AppTheme.btnColor,
              unselectedItemColor: AppTheme.black_Color,
              showUnselectedLabels: true,
              items: [
                BottomNavigationBarItem(
                  icon: svgIcon(
                    icon: 'assets/icons/home/home.svg',
                    clr: _selectedIndex == 0 ? AppTheme.btnColor : AppTheme.black_Color,
                  ),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: svgIcon(
                    icon: 'assets/icons/home/report.svg',
                    clr: _selectedIndex == 1 ? AppTheme.btnColor : AppTheme.black_Color,
                  ),
                  label: 'Reports',
                ),
                BottomNavigationBarItem(
                  icon: svgIcon(
                    icon: 'assets/icons/home/add_user.svg',
                    clr: _selectedIndex == 2 ? AppTheme.btnColor : AppTheme.black_Color,
                  ),
                  label: 'Students',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
