import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:idmitra/Widgets/snack_bar_widget.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/components/text_filed.dart';
import 'package:idmitra/providers/login_auth/login_cubit.dart';
import 'package:idmitra/screens/auth/PasswordTextField.dart';
import 'package:idmitra/screens/auth/forget_password_login.dart';
import 'package:idmitra/screens/auth/otp.dart';
import 'package:idmitra/utils/common_widgets/app_button.dart';
import 'package:idmitra/utils/navigation_utils.dart';

import 'package:page_transition/page_transition.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginCubit loginCubit;
  final formkey = GlobalKey<FormState>();
  late BuildContext buildContext;
  initCubit() {
    loginCubit = context.read<LoginCubit>();
  }
  @override
  void initState() {
    // TODO: implement initState
    initCubit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController phoneController = TextEditingController();
    return Scaffold(
      appBar: AppBar(backgroundColor: AppTheme.appBackgroundColor),
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
          } else if (state is LoginSuccess) {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: OtpVerificationScreen(
                  phone: phoneController.text.trim(),
                  alreadyUser: state.loginModel.user?.lastChangeAt == null ? true : false,
                  loginWithType: state.loginWithType,
                  forgetPassword: false,
                ),
                ctx: context,
              ),
            );
          } else if (state is LoginNoFound) {
            Navigator.of(context).pop();
            final _snackBar = snackBar(
              state.message,
              Icons.done,
              Colors.green,
            );

            ScaffoldMessenger.of(context).showSnackBar(_snackBar);
          }
          else if (state is LoginResendSuccess) {
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
              state.message ?? 'Your account on holding contact with owner!!',
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
        child: SafeArea(
          child: Column(
            children: [
              /// 🔹 Scrollable Content
              Expanded(
                child: Form(
                  key: formkey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        Image.asset('assets/images/login_top_img.png'),

                        const SizedBox(height: 30),

                        Text(
                          "Hello, Welcome",
                          style: MyStyles.boldText(
                            size: 16,
                            color: AppTheme.black_Color,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Login to manage your school identity system.",
                          textAlign: TextAlign.center,
                          style: MyStyles.regularText(
                            size: 14,
                            color: AppTheme.garyColor,
                          ),
                        ),

                        const SizedBox(height: 30),

                        /// Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Mobile/Email",
                                style: MyStyles.boldText(
                                  size: 14,
                                  color: AppTheme.black_Color,
                                ),
                              ),
                              const SizedBox(height: 8),

                              nameTextField(controller: phoneController),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(onPressed: (){
                                    navigateWithTransition(
                                      context: context,
                                      page: const ForgetPasswordLoginScreen(),
                                    );
                                  },child: Text( "Forget Password",style: MyStyles.boldText(size: 14, color: AppTheme.redBtnBgColor ),)
                                   ,

                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              AppButton(
                                title: "Submit" ,
                                isLoading: false,
                                color: AppTheme.btnColor,
                                onTap: () {
                                  String input = phoneController.text.trim();
                                  Map<String, String> map = {};
                                 // Regex for phone (only digits, length 10–15)
                                  final phoneRegex = RegExp(r'^[0-9]{10,15}$');

                                  // Regex for email
                                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                  if (phoneRegex.hasMatch(input)) {
                                     map = {
                                      "whatsapp_phone": phoneController.text.trim(),
                                    };

                                     if (formkey.currentState!.validate()) {
                                       loginCubit.constSendOtp(map,'phone');
                                     }
                                    // Send OTP using phone
                                    print("Send OTP to phone: $input");

                                    // Example:
                                    // api.sendOtp(phone: input);

                                  } else if (emailRegex.hasMatch(input)) {
                                    map = {
                                      "email": phoneController.text.trim(),
                                    };

                                    if (formkey.currentState!.validate()) {
                                      loginCubit.constSendOtp(map,'email');
                                    }
                                    // Send OTP using email
                                    print("Send OTP to email: $input");

                                    // Example:
                                    // api.sendOtp(email: input);

                                  } else {
                                    final _snackBar = snackBar(
                                      "Enter valid phone number or email",
                                      Icons.warning,
                                      Colors.red,
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(_snackBar);
                                    // Invalid input
                                    print("Enter valid phone number or email");
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// 🔹 FIXED BOTTOM TEXT ✅
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Text(
                  "By logging in, you agree to our\nTerms of Service and Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: MyStyles.regularText(
                    size: 12,
                    color: AppTheme.garyColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Social Button Widget
  Widget _socialButton({required IconData icon, required Color color}) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.grey.shade200,
      child: Icon(icon, color: color, size: 28),
    );
  }
}
