import 'package:flutter/material.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/Widgets/svg_file.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/screens/home/FilterBottomSheet.dart';
import 'package:idmitra/screens/home/StudentCard.dart';

class StudentListingPage extends StatefulWidget {
  const StudentListingPage({super.key});

  @override
  State<StudentListingPage> createState() => _StudentListingPageState();
}

class _StudentListingPageState extends State<StudentListingPage> {
  TextEditingController searchController = TextEditingController();

  void openFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const FilterBottomSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Student Listings',backgroundColor: Colors.transparent,),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// SCHOOL DROPDOWN + FILTER
            Row(
              children: [

                Expanded(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppTheme.graySubTitleColor,width: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Xavier school Se. sec.sch..."),
                        Icon(Icons.keyboard_arrow_down)
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                GestureDetector(
                  onTap: (){
                    openFilter(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppTheme.graySubTitleColor,width: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: svgIcon(icon: 'assets/icons/filtter.svg', clr: AppTheme.black_Color,),
                  ),
                )
              ],
            ),

            const SizedBox(height: 15),

            /// SEARCH BAR
            _searchBar(),

            const SizedBox(height: 15),

            /// STUDENT LIST
            Expanded(
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) {
                  return const StudentCard();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      controller: searchController,
      style: MyStyles.regularText(size: 14, color: AppTheme.black_Color),
      onChanged: (value) {},
      decoration: InputDecoration(
        filled: true, // ✅ important
        fillColor: AppTheme.whiteColor, // ✅ background color

        contentPadding: const EdgeInsets.all(12),
        hintText: 'Search by name or company...',
        prefixIcon: const Icon(Icons.search),

        enabledBorder: appBorder(AppTheme.backBtnBgColor, 15),
        focusedBorder: appBorder(AppTheme.backBtnBgColor, 15),
        errorBorder: appBorder(AppTheme.errorMessageBackgroundColor, 15),
        focusedErrorBorder: appBorder(AppTheme.errorMessageBackgroundColor, 15),

        hintStyle: MyStyles.regularText(
          size: 14,
          color: AppTheme.graySubTitleColor,
        ),
      ),
    );
  }

  OutlineInputBorder appBorder(Color color, double radius) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color),
      borderRadius: BorderRadius.circular(radius),
    );
  }
}