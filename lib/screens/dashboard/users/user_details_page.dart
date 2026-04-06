import 'package:flutter/material.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/models/schools/SchoolListModel.dart';
import 'package:idmitra/screens/home/student_list.dart';
import 'package:idmitra/utils/navigation_utils.dart';

import '../../edit_profile/image_setting.dart';

class UserDetailsPage extends StatefulWidget {
  SchoolDetailsModel? schoolDetailsModel;
  UserDetailsPage({super.key,this.schoolDetailsModel});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  List<String> tabs = ["Overview", "Documents", "Admin", "Activity"];
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'School Details',
        backgroundColor: Colors.transparent,
        showText: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings,color: Colors.black,),

            // ✅ FIX: show dropdown below icon
            offset: const Offset(0, 45),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 8,

            onSelected: (value) {
              if (value == 'image_settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ImageSettingsScreen(),
                  ),
                );
              } else if (value == 'profile_settings') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile Settings Clicked')),
                );
              }
            },

            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'image_settings',
                child: Row(
                  children: [
                    Icon(Icons.image),
                    SizedBox(width: 10),
                    Text('Image Settings'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'profile_settings',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 10),
                    Text('Profile Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
                        child: Image.network(
                    widget.schoolDetailsModel?.logoUrl ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image, size: 40);
                    },
                  )

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
                          widget.schoolDetailsModel?.name ?? '',
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
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  /// LEFT INFO
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.location_on,
                                            size: 14, color: AppTheme.whiteColor),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            widget.schoolDetailsModel?.address ?? '',maxLines: 2,
                                            style: MyStyles.regularText(
                                                size: 12, color: AppTheme.whiteColor),
                                          ),
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
                              Row(
                                children: [
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
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.network(
                          widget.schoolDetailsModel?.logoUrl ?? '',
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image, size: 40);
                          },
                        ),
                      ),
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
                statCard(title: "STUDENTS", value: "1,250",callBtn: (){
                  navigateWithTransition(
                    context: context,
                    page: StudentListingPage(schoolId: widget.schoolDetailsModel?.id.toString() ?? '',),
                  );
                }),
                statCard(title: "STAFF", value: "85",callBtn: (){}),
                statCard(title: "TOTAL ORDERS", value: "11,00",callBtn: (){}),
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
                    widget.schoolDetailsModel?.name ?? '',
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
                    widget.schoolDetailsModel!.admin!.name ?? '',
                    "ID Proof",
                    "SH-99283-DX",
                  ),
                  divider(),

                  infoRow(
                    "Email Address",
                    widget.schoolDetailsModel!.admin!.email ?? '',
                    "Contact number",
                    widget.schoolDetailsModel!.admin!.phone ?? '',
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
  Widget statCard({required String title, required String value,required VoidCallback callBtn}) {
    return Expanded(
      child: GestureDetector(
        onTap: (){
          callBtn();
        },
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
