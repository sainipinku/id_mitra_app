import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/Widgets/svg_file.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/providers/school/school_cubit.dart';
import 'package:idmitra/providers/school/school_state.dart';
import 'package:idmitra/screens/add_student/add_student.dart';
import 'package:idmitra/screens/admin/admin_dashboard.dart';
import 'package:idmitra/screens/dashboard/users/users_details_widgets.dart';
import 'package:idmitra/screens/home/FilterBottomSheet.dart';
import 'package:idmitra/screens/home/StudentCard.dart';
import 'package:idmitra/utils/MyStyles.dart';

import '../../admin/admin_home.dart';


class Schools extends StatefulWidget {
  const Schools({super.key});

  @override
  State<Schools> createState() => _SchoolsState();
}

class _SchoolsState extends State<Schools> {
  TextEditingController searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  final List<String> filters = [
    "All",
    "Partner",
    "Schools",
    "Colleges",
    "Corparte",
  ];
  Timer? _debounce;
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
  void initState() {
    super.initState();

    context.read<SchoolCubit>().fetchStudents(search: '');

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {

        context.read<SchoolCubit>().fetchStudents(isLoadMore: true,search: '');
      }
    });
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
            BlocBuilder<SchoolCubit, SchoolState>(
          builder: (context, state) {
            if (state.loading) {
              return Center(child: CircularProgressIndicator());
            }

            return Expanded(
              child: state.students.isEmpty
                  ? Center(
                child: Image.asset(
                  "assets/images/no_data.png",
                  height: 200,
                ),
              )
                  : ListView.builder(
                controller: _scrollController,
                itemCount: state.students.length +
                    (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < state.students.length) {
                    final item = state.students[index];
                    return UsersDetailsWidgets(
                      schoolDetailsModel: item,
                    );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ),
            );
          },
        ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  child: Text("Check"),
                    onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminDashboard()));
                    }
                ),
              ],
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
      onChanged: (value) {
        if (_debounce?.isActive ?? false) _debounce!.cancel();

        _debounce = Timer(const Duration(milliseconds: 500), () {
          context.read<SchoolCubit>().fetchStudents(
            search: value.trim(),
          );
        });
      },
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