import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:idmitra/Widgets/shimmer_loader.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/Widgets/snack_bar_widget.dart';
import 'package:idmitra/api_mamanger/secure_storage.dart';
import 'package:idmitra/bottom_diloag/logout.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/config/sharedpref.dart';
import 'package:idmitra/providers/home/home_cubit.dart';
import 'package:idmitra/providers/login_auth/login_cubit.dart';
import 'package:idmitra/screens/WebViewPage/WebViewPage.dart';
import 'package:idmitra/screens/auth/login.dart';
import 'package:idmitra/screens/admin/admin_edit_profile/admin_edit_profile.dart';
import 'package:idmitra/utils/navigation_utils.dart';

class AdminProfileSetting extends StatefulWidget {
  const AdminProfileSetting({super.key});

  @override
  State<AdminProfileSetting> createState() => _AdminProfileSettingState();
}

class _AdminProfileSettingState extends State<AdminProfileSetting> {
  late LoginCubit loginCubit;
  final formkey = GlobalKey<FormState>();

  void initCubit() {
    loginCubit = context.read<LoginCubit>();
  }

  @override
  void initState() {
    initCubit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Profile Setting',
        backgroundColor: Colors.white,
      ),
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginLoading) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (_ctx) {
                return Dialog(
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppTheme.progressLowColor,
                        ),
                        SizedBox(height: 10.h),
                        const Text('Loading...'),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is LogoutSuccess) {
            SharedPref.removeAll();
            UserSecureStorage.deleteAll();
            navigateWithTransition(
              context: context,
              page: const LoginScreen(),
            );
          } else if (state is LoginResendSuccess) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              snackBar('Otp sent successfully', Icons.done, Colors.green),
            );
          } else if (state is LoginFailed) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              snackBar('Failed to send an OTP.', Icons.warning, Colors.red),
            );
          } else if (state is LoginOnHold) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              snackBar(
                'Your account on holding contact with owner!!',
                Icons.warning,
                Colors.red,
              ),
            );
          } else if (state is LoginTimeout) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              snackBar('Time out exception', Icons.warning, Colors.red),
            );
          } else if (state is LoginInternetError) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              snackBar(
                  'Internet connection failed.', Icons.wifi, Colors.red),
            );
          }
        },
        child: Column(
          children: [
            _profileHeader(),
            const Divider(height: 1),
            Expanded(child: _menuSection(context)),
          ],
        ),
      ),
    );
  }

  Widget _profileHeader() {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.loading) {
          return const ProfileHeaderShimmer();
        } else if (state.dashboard != null) {
          final data = state.user!.user;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    data!.profilePhotoUrl ?? '',
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  data.name ?? '',
                  style: MyStyles.boldText(
                      size: 16, color: AppTheme.black_Color),
                ),
                const SizedBox(height: 4),
                Text(
                  data.email ?? '',
                  style: MyStyles.regularText(
                      size: 14, color: AppTheme.graySubTitleColor),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        } else {
          return const Center(child: Text("Something went wrong"));
        }
      },
    );
  }

  Widget _menuSection(BuildContext context) {
    return ListView(
      children: [
        _menuItem("Edit Profile", Icons.person_outline, () async {
          final result = await navigateWithTransition(
            context: context,
            page: const AdminEditProfilePage(),
          );
          // If profile was updated, refresh home data
          if (result == true && mounted) {
            context.read<HomeCubit>().loadHomeData();
          }
        }),
        _divider(),
        _menuItem("Privacy & Policy", Icons.privacy_tip, () {
          navigateWithTransition(
            context: context,
            page: WebViewPage(
              url: 'https://idmitra.com/privacy-policy',
              title: 'Privacy & Policy',
            ),
          );
        }),
        _divider(),
        _menuItem("Terms & Conditions", Icons.description, () {
          navigateWithTransition(
            context: context,
            page: WebViewPage(
              url: 'https://idmitra.com/term-and-condition',
              title: 'Terms & Conditions',
            ),
          );
        }),
        _divider(),
        _menuItem(
          "Logout",
          Icons.logout,
          () {
            LogoutBottomDilog(
              buildContext: context,
              button: () {
                loginCubit.constLogoutFun();
              },
              title: 'Logout ?',
              desc: 'Are You Sure You Want to Logout',
            );
          },
          isLogout: true,
        ),
      ],
    );
  }

  Widget _menuItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.black),
      title: Text(
        title,
        style: TextStyle(color: isLogout ? Colors.red : Colors.black),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _divider() => const Divider(height: 1);
}
