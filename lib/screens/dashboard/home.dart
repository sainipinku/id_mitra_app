import 'package:flutter/material.dart';
import 'package:idmitra/Widgets/svg_file.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/screens/SelectRolePage/SelectRolePage.dart';
import 'package:idmitra/screens/dashboard/StatCard.dart';
import 'package:idmitra/screens/home/student_list.dart';
import 'package:idmitra/utils/MyStyles.dart';
import 'package:idmitra/utils/navigation_utils.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          /// STATS GRID
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: const [

              StatCard(
                title: "Total Users",
                value: "124",
                icon: Icons.person,
                color: Colors.blue,
              ),

              StatCard(
                title: "Active Users",
                value: "98",
                icon: Icons.person_outline,
                color: Colors.green,
              ),

              StatCard(
                title: "Total Students",
                value: "500",
                icon: Icons.school,
                color: Colors.orange,
              ),

              StatCard(
                title: "Total Employee",
                value: "58",
                icon: Icons.group,
                color: Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// QUICK ACTIONS CARD
          Container(
            padding: const EdgeInsets.all(16),
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

                const Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                /// ADD NEW USER BUTTON
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff1FA2FF), Color(0xff12D8FA)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: GestureDetector(
                    onTap: (){
                      navigateWithTransition(
                        context: context,
                        page: SelectRolePage(),
                      );
                    },
                    child: Row(
                      children: [

                        Container(
                          height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: AppTheme.btn10perOpacityColor
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: svgIcon(icon: 'assets/icons/home/add_user.svg', clr: AppTheme.whiteColor,),
                            )),

                        const SizedBox(width: 12),

                         Expanded(
                          child: Text(
                            "Add New Users",
                            style: MyStyles.semiBoldTxt(AppTheme.whiteColor, 14),
                          ),
                        ),

                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

}
