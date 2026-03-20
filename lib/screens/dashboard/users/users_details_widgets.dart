import 'package:flutter/material.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/screens/dashboard/users/user_details_page.dart';
import 'package:idmitra/utils/navigation_utils.dart';

class UsersDetailsWidgets extends StatefulWidget {
  const UsersDetailsWidgets({super.key});

  @override
  State<UsersDetailsWidgets> createState() => _UsersDetailsWidgetsState();
}

class _UsersDetailsWidgetsState extends State<UsersDetailsWidgets> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),

      child: GestureDetector(
        onTap: (){
          navigateWithTransition(
            context: context,
            page: UserDetailsPage(),
          );
        },
        child: Row(
          children: [

            /// PROFILE IMAGE
            /// PROFILE IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(60), // optional rounded corners
              child: Image.network(
                "https://randomuser.me/api/portraits/men/32.jpg",
                height: 60,
                width: 60,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 12),

            /// STUDENT DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Sunrise Public School",
                    style:
                    MyStyles.boldText(size: 16, color: AppTheme.black_Color),
                  ),

                  const SizedBox(height: 3),

                  Row(
                    children: [
                      Icon(Icons.location_on,size: 15,),
                      Text(
                        "Kota, Rajasthan",
                        style: MyStyles.regularText(size: 12, color: AppTheme.graySubTitleColor),
                      ),
                      SizedBox(width: 5,),
                      Icon(Icons.calendar_month_outlined,size: 15,),
                      Text(
                        "12 Feb 2026",
                        style: MyStyles.regularText(size: 12, color: AppTheme.graySubTitleColor),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  /// STATUS BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.activeBtn10perOpacityColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child:  Text(
                      "ACTIVE",
                      style: MyStyles.boldText(size: 10, color: AppTheme.activeBtn),
                    ),
                  )
                ],
              ),
            ),

            /// STATUS BADGE
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.appBackgroundColor,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
              ),
            )
          ],
        ),
      ),
    );
  }
}
