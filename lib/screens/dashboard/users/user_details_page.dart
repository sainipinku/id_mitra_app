import 'package:flutter/material.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  List<String> tabs = ["Overview", "Documents", "Admin", "Activity"];
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'School Details', backgroundColor: Colors.transparent,showText: true,),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            /// 🔹 TOP CARD (IMAGE + LOGO)
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [

                /// 🔹 CARD CONTAINER (with radius)
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [

                      /// IMAGE
                      Positioned.fill(
                        child: Image.asset(
                          "assets/images/school.png",
                          fit: BoxFit.cover,
                        ),
                      ),

                      /// DARK OVERLAY
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ),

                      /// CENTER TITLE
                      Center(
                        child: Text(
                          "Sunrise Public School",
                          textAlign: TextAlign.center,
                          style: MyStyles.boldText(
                            size: 20,
                            color: AppTheme.whiteColor,
                          ),
                        ),
                      ),

                      /// BOTTOM INFO BAR
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.white20perOpacityColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              /// LEFT INFO
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        size: 14, color: AppTheme.whiteColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Kota, Rajasthan",
                                      style: MyStyles.regularText(
                                          size: 12, color: AppTheme.whiteColor),
                                    ),

                                    const SizedBox(width: 8),

                                    Icon(Icons.calendar_month_outlined,
                                        size: 14, color: AppTheme.whiteColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      "12 Feb 2026",
                                      style: MyStyles.regularText(
                                          size: 12, color: AppTheme.whiteColor),
                                    ),
                                  ],
                                ),
                              ),

                              /// STATUS
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.greenColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "ACTIVE",
                                  style: MyStyles.boldText(
                                      size: 10, color: AppTheme.whiteColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// 🔹 TOP LOGO (PERFECT CENTER)
                Positioned(
                  top: -40,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset("assets/images/app_logo.png"),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            /// 🔹 STATS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                statCard("STUDENTS", "1,250"),
                statCard("STAFF", "85"),
                statCard("TOTAL ORDERS", "11,00"),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔹 TABS
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: List.generate(tabs.length, (index) {
                  final isSelected = selectedIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: tabItem(tabs[index], isSelected),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),
            if(selectedIndex == 0)
            /// 🔹 GENERAL INFO CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    "General Information",
                    style: MyStyles.boldText(size: 20, color: AppTheme.black_Color),
                  ),
                  const SizedBox(height: 12),

                  infoRow(
                    "School Name",
                    "Sunrise Public School",
                    "School ID",
                    "SH-99283-DX",
                  ),
                  divider(),

                  infoRow(
                    "Email Address",
                    "Xaviar@school.edu",
                    "Contact number",
                    "+91 9876543210",
                  ),
                  divider(),

                  infoRow(
                    "Category",
                    "Private Sec. School",
                    "Established",
                    "1995 (29 Years)",
                  ),
                  divider(),

                  const Text(
                    "Address",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "109/43, Gaya Building, Yusuf Meharali Road, Mandvi",
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            if(selectedIndex == 2)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Admin Information",
                    style: MyStyles.boldText(size: 20, color: AppTheme.black_Color),
                  ),
                  const SizedBox(height: 12),

                  infoRow(
                    "Admin Name",
                    "Sunrise Public School",
                    "ID Proof",
                    "SH-99283-DX",
                  ),
                  divider(),

                  infoRow(
                    "Email Address",
                    "Xaviar@school.edu",
                    "Contact number",
                    "+91 9876543210",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 STAT CARD
  Widget statCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.whiteColor,
          border: Border.all(color: AppTheme.backBtnBgColor),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: MyStyles.regularText(size: 14, color: AppTheme.black_Color),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: MyStyles.boldText(size: 20, color: AppTheme.btnColor),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 TAB ITEM
  Widget tabItem(String title, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.btnColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 🔹 INFO ROW
  Widget infoRow(String title1, String value1, String title2, String value2) {
    return Row(
      children: [
        Expanded(child: infoColumn(title1, value1)),
        Expanded(child: infoColumn(title2, value2)),
      ],
    );
  }

  Widget infoColumn(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: MyStyles.regularText(size: 14, color: AppTheme.graySubTitleColor)),
          const SizedBox(height: 2),
          Text(value, style: MyStyles.regularText(size: 14, color: AppTheme.black_Color)),
        ],
      ),
    );
  }

  Widget divider() {
    return const Divider(height: 20);
  }
}
