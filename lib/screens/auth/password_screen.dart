import 'package:flutter/material.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/components/text_filed.dart';
import 'package:idmitra/screens/auth/ConfirmPasswordTextField.dart';
import 'package:idmitra/screens/auth/PasswordTextField.dart';
import 'package:idmitra/utils/common_widgets/app_button.dart';



class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final formkey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final pinController = TextEditingController();
  final confirmPinController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                        "Set Your Security",
                        style: MyStyles.boldText(
                          size: 26,
                          color: AppTheme.black_Color,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Create a secure password and PIN to protect your account.",
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
                              "Create Password",
                              style: MyStyles.boldText(
                                size: 14,
                                color: AppTheme.black_Color,
                              ),
                            ),


                            PasswordTextField(controller: passwordController),
                            Text(
                              "Confirm Password",
                              style: MyStyles.boldText(
                                size: 14,
                                color: AppTheme.black_Color,
                              ),
                            ),

                            ConfirmPasswordTextField(
                              controller: confirmPasswordController,
                              passwordController: passwordController,
                            ),
                            Text(
                              "Create PIN",
                              style: MyStyles.boldText(
                                size: 14,
                                color: AppTheme.black_Color,
                              ),
                            ),


                            phoneNumberTextField(controller: pinController,hintName: "Enter 4-digit PIN",isRequired: false,digitNo: 4),
                            Text(
                              "Confirm Pin Number",
                              style: MyStyles.boldText(
                                size: 14,
                                color: AppTheme.black_Color,
                              ),
                            ),

                            phoneNumberTextField(
                              controller: confirmPinController,hintName: "Enter 4-digit PIN",isRequired: false,digitNo: 4
                            ),
                            const SizedBox(height: 20),

                            AppButton(
                              title: "Save",
                              isLoading: false,
                              color: AppTheme.btnColor,
                              onTap: () {
                                if (formkey.currentState!.validate()) {

                                }
                              },
                            ),
                          ].map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: e,
                          ))
                              .toList(),
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
    );
  }
}
