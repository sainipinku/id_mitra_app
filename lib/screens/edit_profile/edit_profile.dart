import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/Widgets/snack_bar_widget.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/providers/login_auth/login_cubit.dart';


class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Profile Setting',backgroundColor: Colors.white,),
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
            Navigator.of(context).pop();
            final _snackBar = snackBar(
              'Otp sent successfully',
              Icons.done,
              Colors.green,
            );
            ScaffoldMessenger.of(context).showSnackBar(_snackBar);
          } else if (state is LoginResendSuccess) {
            Navigator.of(context).pop();
            final _snackBar = snackBar(
              'Otp sent successfully',
              Icons.done,
              Colors.green,
            );

            ScaffoldMessenger.of(context).showSnackBar(_snackBar);
          } else if (state is LoginFailed) {
            Navigator.of(context).pop();
            final _snackBar = snackBar(
              'Failed to send an OTP.',
              Icons.warning,
              Colors.red,
            );

            ScaffoldMessenger.of(context).showSnackBar(_snackBar);
          } else if (state is LoginOnHold) {
            Navigator.of(context).pop();
            final _snackBar = snackBar(
              'Your account on holding contact with owner!!',
              Icons.warning,
              Colors.red,
            );

            ScaffoldMessenger.of(context).showSnackBar(_snackBar);
          } else if (state is LoginTimeout) {
            Navigator.of(context).pop();
            final _snackBar = snackBar(
              'Time out exception',
              Icons.warning,
              Colors.red,
            );

            ScaffoldMessenger.of(context).showSnackBar(_snackBar);
          } else if (state is LoginInternetError) {
            Navigator.of(context).pop();
            final _snackBar = snackBar(
              'Internet connection failed.',
              Icons.wifi,
              Colors.red,
            );

            ScaffoldMessenger.of(context).showSnackBar(_snackBar);
          }
        },
        child: Column(
          children: [

          ],
        ),
      )
      ,
    );
  }
}
