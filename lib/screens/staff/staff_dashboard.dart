import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/Widgets/svg_file.dart';
import 'package:idmitra/api_mamanger/secure_storage.dart';
import 'package:idmitra/bottom_diloag/logout.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/config/sharedpref.dart';
import 'package:idmitra/providers/login_auth/login_cubit.dart';
import 'package:idmitra/screens/auth/login.dart';
import 'package:idmitra/utils/MyStyles.dart';
import 'package:idmitra/utils/navigation_utils.dart';

import 'staff_home.dart';
import 'staff_setting.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = [
    const StaffHome(),
    BlocProvider(create: (_) => LoginCubit(), child: const StaffSetting()),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            SharedPref.removeAll();
            UserSecureStorage.deleteAll();
            navigateWithTransition(context: context, page: const LoginScreen());
          }
        },
        child: Scaffold(
          appBar: _appBar(context),
          body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    currentIndex: _selectedIndex,
                    onTap: _onItemTapped,
                    selectedItemColor: AppTheme.btnColor,
                    unselectedItemColor: AppTheme.black_Color,
                    showUnselectedLabels: true,
                    items: [
                      BottomNavigationBarItem(
                        icon: svgIcon(icon: 'assets/icons/home/home.svg', clr: _selectedIndex == 0 ? AppTheme.btnColor : AppTheme.black_Color),
                        label: "Dashboard",
                      ),
                      BottomNavigationBarItem(
                        icon: svgIcon(icon: 'assets/icons/home/user-profile.svg', clr: _selectedIndex == 1 ? AppTheme.btnColor : AppTheme.black_Color),
                        label: "Setting",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFE0E0E0),
              child: Icon(Icons.person, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Staff", style: MyStyles.boldTxt(AppTheme.black_Color, 20)),
                  Text("ID Mitra Staff", style: MyStyles.regularTxt(AppTheme.graySubTitleColor, 14)),
                ],
              ),
            ),
            Stack(
              children: [
                IconButton(
                  icon: Container(
                    height: 44, width: 44,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.btn10perOpacityColor),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: svgIcon(icon: 'assets/icons/home/notification.svg', clr: AppTheme.btnColor),
                    ),
                  ),
                  onPressed: () {},
                ),
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Text("1", style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
              ],
            ),
            // Logout button
            IconButton(
              icon: Container(
                height: 44, width: 44,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red.withOpacity(0.1)),
                child: const Icon(Icons.logout, color: Colors.red, size: 20),
              ),
              onPressed: () {
                LogoutBottomDilog(
                  buildContext: context,
                  title: 'Logout',
                  desc: 'Are you sure you want to logout?',
                  button: () => context.read<LoginCubit>().constLogoutFun(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
