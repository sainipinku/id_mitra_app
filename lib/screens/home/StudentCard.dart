import 'package:flutter/material.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
class StudentCard extends StatelessWidget {
  const StudentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [

          /// PROFILE IMAGE
          /// PROFILE IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(6), // optional rounded corners
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

                Row(
                  children:  [
                    Text(
                      "Sumit Sharma",
                      style:
                      MyStyles.boldText(size: 16, color: AppTheme.black_Color),
                    ),
                    SizedBox(width: 5),
                    Text(
                      "• 8th-B",
                      style: MyStyles.boldText(size: 16, color: AppTheme.btnColor),
                    ),
                  ],
                ),

                const SizedBox(height: 3),

                 Text(
                  "Father name : Shubham Sharma",
                  style: MyStyles.regularText(size: 12, color: AppTheme.graySubTitleColor),
                ),

                const SizedBox(height: 3),

                 Text(
                  "Missing details: Roll no., Father Name",
                  style: MyStyles.regularText(size: 12, color: AppTheme.redBtnBgColor),
                )
              ],
            ),
          ),

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
    );
  }
}