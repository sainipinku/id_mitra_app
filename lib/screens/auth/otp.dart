import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/Widgets/snack_bar_widget.dart';
import 'package:idmitra/config/prefConstatnt.dart';
import 'package:idmitra/providers/login_auth/login_cubit.dart';
import 'package:idmitra/screens/dashboard/dashboard.dart';
import 'package:idmitra/utils/common_widgets/app_button.dart';
import 'package:idmitra/utils/navigation_utils.dart';

import 'package:page_transition/page_transition.dart';
import 'package:pinput/pinput.dart';

import '../../components/app_theme.dart';
import '../../components/my_font_weight.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  const OtpVerificationScreen({super.key,required this.phone});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  SmsRetriever? smsRetriever;
  late final TextEditingController pinController;
  late final FocusNode focusNode;
  late final GlobalKey<FormState> formKey;
  Timer? _timer;
  bool resend = false;
  String? comingSms = 'Unknown';
  var appSignatureID;

  final formkey = GlobalKey<FormState>();
  late BuildContext buildContext;

  formatedTime({required int timeInSecond}) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  }

  void startTimer() {
    setState(() {
      resend = false;
    });
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (Preferences.timer == 0) {
        setState(() {
          //_pinPutController.text='';
          resend = true;
          timer.cancel();
        });
      } else {
        setState(() {
          Preferences.timer--;
        });
      }
    });
  }
  late LoginCubit loginCubit;

  initCubit(){
    loginCubit = context.read<LoginCubit>();
  }

  @override
  void initState() {
    // TODO: implement initState
    initCubit();
    Preferences.timer = 120;   // RESET TIMER ON PAGE OPEN
    startTimer();
    formKey = GlobalKey<FormState>();
    pinController = TextEditingController();
    focusNode = FocusNode();

    /// In case you need an SMS autofill feature
    /*smsRetriever = SmsRetrieverImpl(
     // SmartAuth(),
    );*/
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer!.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var focusedBorderColor = AppTheme.graySubTitleColor.withAlpha(50);
    var fillColor = AppTheme.fillColor.withAlpha(50);
    var borderColor = AppTheme.black_Color;

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: MyStyles.regularText(size: 14, color: AppTheme.black_Color),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor),
      ),
    );
    return Scaffold(
      appBar: CommonAppBar(showText: false,title: '',backgroundColor: Colors.transparent,),
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
                          SizedBox(
                            height: 10.h,
                          ),
                          const Text('Loading...')
                        ],
                      ),
                    ),
                  );
                });
          } else if (state is LoginSuccess) {
            navigateAndRemoveUntil(
              context: context,
              page: Dashboard(),
              transition: PageTransitionType.rightToLeft,
            );
          }
          else if (state is LoginResendSuccess) {
            Navigator.of(context).pop();
            final _snackBar =
            snackBar('Otp sent successfully', Icons.done, Colors.green);

            ScaffoldMessenger.of(context).showSnackBar(_snackBar);
          } else if (state is LoginFailed) {
            Navigator.of(context).pop();
            final _snackBar =
            snackBar('Failed to send an OTP.', Icons.warning, Colors.red);

            ScaffoldMessenger.of(context).showSnackBar(_snackBar);
          } else if (state is LoginOnHold) {
            Navigator.of(context).pop();
            final _snackBar = snackBar(
                'Your account on holding contact with owner!!',
                Icons.warning,
                Colors.red);

            ScaffoldMessenger.of(context).showSnackBar(_snackBar);
          } else if (state is LoginTimeout) {
            Navigator.of(context).pop();
            final _snackBar =
            snackBar('Time out exception', Icons.warning, Colors.red);

            ScaffoldMessenger.of(context).showSnackBar(_snackBar);
          } else if (state is LoginInternetError) {
            Navigator.of(context).pop();
            final _snackBar =
            snackBar('Internet connection failed.', Icons.wifi, Colors.red);

            ScaffoldMessenger.of(context).showSnackBar(_snackBar);
          }
        },
        child: SafeArea(
          child: Form(
            key: formkey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [

                    const SizedBox(height: 20),

                    /// ICON WITH CIRCLES
                    /// Illustration
                    Image.asset(
                      'assets/images/otp_top_img.png', // <-- add your image
                      height: 220,
                    ),

                    const SizedBox(height: 30),

                    /// TITLE
                    Text(
                      "OTP Verification",
                      style: MyStyles.boldText(size: 26, color: AppTheme.black_Color ),
                    ),

                    const SizedBox(height: 10),

                    /// DESCRIPTION
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        "Enter the 6-digit code sent to +91 ${widget.phone}",
                        textAlign: TextAlign.center,
                        style: MyStyles.regularText(size: 14, color: AppTheme.garyColor),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// OTP BOXES
                    Container(
                      color: Colors.transparent,
                      child: Center(
                        child: Pinput(
                          length: 6,
                          // You can pass your own SmsRetriever implementation based on any package
                          // in this example we are using the SmartAuth
                          smsRetriever: smsRetriever,
                          controller: pinController,
                          focusNode: focusNode,
                          defaultPinTheme: defaultPinTheme,
                          separatorBuilder: (index) => const SizedBox(width: 5),
                          hapticFeedbackType: HapticFeedbackType.lightImpact,
                          onCompleted: (pin) {
                            debugPrint('onCompleted: $pin');
                          },
                          onChanged: (value) {
                            debugPrint('onChanged: $value');
                          },
                          cursor: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 9),
                                width: 12,
                                height: 1,
                                color: focusedBorderColor,
                              ),
                            ],
                          ),
                          focusedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: focusedBorderColor),
                            ),
                          ),
                          submittedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              color: fillColor,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: focusedBorderColor),
                            ),
                          ),
                          errorPinTheme: defaultPinTheme.copyBorderWith(
                            border: Border.all(color: Colors.redAccent),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// VERIFY BUTTON
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      child: AppButton(
                        title: "Verify Now",
                        isLoading: false,
                        color: AppTheme.btnColor,
                        onTap: () {

                          Map<String, String> map = {
                            "whatsapp_phone": widget.phone,
                            "otp": pinController.text.trim(),
                            "user_type": '',
                          };
                          print('send data ======>$map');
                          if (formkey.currentState!.validate()) {
                            loginCubit.constVerifyOtp(map);
                          }

                        },
                      ),

                    ),

                    const SizedBox(height: 15),

                    /// RESEND TEXT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the Code? ",
                          style: MyStyles.regularText(size: 14, color: AppTheme.garyColor),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            "Resend Code",
                            style: MyStyles.boldText(size: 14, color: AppTheme.graySubTitleColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

