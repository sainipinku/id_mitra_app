import 'package:flutter/material.dart';
import 'package:idmitra/Widgets/svg_file.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/screens/dashboard/users/users_details_widgets.dart';
import 'package:idmitra/screens/home/FilterBottomSheet.dart';
import 'package:idmitra/screens/home/StudentCard.dart';
import 'package:idmitra/utils/MyStyles.dart';


class Schools extends StatefulWidget {
  const Schools({super.key});

  @override
  State<Schools> createState() => _SchoolsState();
}

class _SchoolsState extends State<Schools> {
  TextEditingController searchController = TextEditingController();
  final List<String> filters = [
    "All",
    "Partner",
    "Schools",
    "Colleges",
    "Corparte",
  ];

  int selectedIndex = 0;
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

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// SEARCH BAR
            _searchBar(),

            const SizedBox(height: 15),
            fillterList(),
            const SizedBox(height: 15),
            /// STUDENT LIST
            Expanded(
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) {
                  return const UsersDetailsWidgets();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget fillterList(){
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.btnColor
                    : AppTheme.appBackgroundColor,
                border: Border.all(color: isSelected
                    ? AppTheme.btnColor
                    : AppTheme.graySubTitleColor),
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.center,
              child: Text(
                filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _searchBar() {
    return TextField(
      controller: searchController,
      style: MyStyles.regularTxt(AppTheme.black_Color,14),
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

        hintStyle: MyStyles.regularTxt(AppTheme.black_Color,14),
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