import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/screens/add_school/add_newschool.dart';
import 'package:idmitra/utils/common_widgets/app_button.dart';
import 'package:idmitra/utils/navigation_utils.dart';

class SelectRolePage extends StatefulWidget {
  const SelectRolePage({super.key});

  @override
  State<SelectRolePage> createState() => _SelectRolePageState();
}

class _SelectRolePageState extends State<SelectRolePage> {

  int selectedIndex = 0;

  List roles = [
    {
      "title": "School",
      "desc": "Add schools, manage onboarding, and track referrals.",
      "icon": Icons.school
    },
    {
      "title": "Collage",
      "desc": "Manage administrators and staff roles efficiently",
      "icon": Icons.school
    },
    {
      "title": "Corporate",
      "desc": "Organize and manage all school employees in one place",
      "icon": Icons.corporate_fare
    },
    {
      "title": "Chanel Partner",
      "desc": "Organize and manage all school employees in one place",
      "icon": Icons.wifi_channel
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CommonAppBar(title: '',backgroundColor: Colors.transparent,),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              /// Logo
              Column(
                children: const [
                  Text(
                    "IDMITRA",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Image.asset(height: 90,width: 90,
                "assets/icons/home/app_logo.png",

              ),
              const SizedBox(height: 15),

              /// Title
              const Text(
                "Select User Role",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Choose how you want to continue with ID Mitra.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey
                ),
              ),

              const SizedBox(height: 25),

              /// Role Cards
              Expanded(
                child: ListView.builder(
                  itemCount: roles.length,
                  itemBuilder: (context, index) {

                    bool isSelected = selectedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          boxShadow: [
                            if(isSelected)
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.15),
                                blurRadius: 10,
                                spreadRadius: 1,
                              )
                          ],
                        ),
                        child: Row(
                          children: [

                            /// Icon
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                roles[index]["icon"],
                                color: Colors.blue,
                              ),
                            ),

                            const SizedBox(width: 15),

                            /// Text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    roles[index]["title"],
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    roles[index]["desc"],
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// Radio Icon
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// Continue Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: AppButton(
                  title: "Continue",
                  isLoading: false,
                  color: AppTheme.btnColor,
                  onTap: () {
                    navigateWithTransition(
                      context: context,
                      page: AddNewSchoolPage(),
                    );

                  },
                ),

              ),


            ],
          ),
        ),
      ),
    );
  }
}