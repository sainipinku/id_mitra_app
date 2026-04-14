import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/Widgets/svg_file.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/models/students/StudentsListModel.dart';
import 'package:idmitra/providers/add_student/add_student_cubit.dart';
import 'package:idmitra/providers/student_form/student_form_cubit.dart';
import 'package:idmitra/providers/student_form/student_form_data_cubit.dart';
import 'package:idmitra/providers/students/students_cubit.dart';
import 'package:idmitra/providers/students/students_state.dart';
import 'package:idmitra/screens/add_student/add_student_form.dart';
import 'package:idmitra/screens/home/FilterBottomSheet.dart';
import 'package:idmitra/screens/home/StudentCard.dart';

class StudentListingPage extends StatefulWidget {
  String schoolId;
  StudentListingPage({super.key, required this.schoolId});

  @override
  State<StudentListingPage> createState() => _StudentListingPageState();
}

class _StudentListingPageState extends State<StudentListingPage> {
  TextEditingController searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  int selectedIndex = 0;

  void _navigateToAddStudent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => StudentFormCubit()
                ..loadFromSchoolId(schoolId: widget.schoolId, schoolName: ''),
            ),
            BlocProvider(
              create: (_) => StudentFormDataCubit()..load(widget.schoolId),
            ),
            BlocProvider(create: (_) => AddStudentCubit()),
          ],
          child: AddStudentFormPage(schoolId: widget.schoolId),
        ),
      ),
    ).then((_) {
      context.read<StudentsCubit>().fetchStudents(
        search: searchController.text.trim(),
        schoolId: widget.schoolId,
      );
    });
  }

  void _navigateToEdit(BuildContext context, StudentDetailsData student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => StudentFormCubit()
                ..loadFromSchoolId(schoolId: widget.schoolId, schoolName: ''),
            ),
            BlocProvider(
              create: (_) => StudentFormDataCubit()..load(widget.schoolId),
            ),
            BlocProvider(create: (_) => AddStudentCubit()),
          ],
          child: AddStudentFormPage(
            schoolId: widget.schoolId,
            editStudent: student,
          ),
        ),
      ),
    ).then((_) {
      // Refresh list after edit
      context.read<StudentsCubit>().fetchStudents(
        search: searchController.text.trim(),
        schoolId: widget.schoolId,
      );
    });
  }

  void openFilter(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.whiteColor,
      shape: const RoundedRectangleBorder( // <-- SEE HERE
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (BuildContext context) {
        return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setState){
              setState((){});
              return SingleChildScrollView(
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: FilterBottomSheet(),
                )
                ,
              );
            }
        );
      },

    );

  }

  @override
  void initState() {
    super.initState();

    context.read<StudentsCubit>().fetchStudents(
      search: '',
      schoolId: widget.schoolId,
    );

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        context.read<StudentsCubit>().fetchStudents(
          isLoadMore: true,
          search: '',
          schoolId: widget.schoolId,
        );
      }
    });
  }
  Future<void> refreshData() async {
  //  await Future.delayed(const Duration(seconds: 2));
    context.read<StudentsCubit>().fetchStudents(
      search: '',
      schoolId: widget.schoolId,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Student Listings',
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.btnColor,
        tooltip: 'Add Student',
        onPressed: () => _navigateToAddStudent(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh:  refreshData,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// SCHOOL DROPDOWN + FILTER
              Row(
                children: [

                  Expanded(
                    child: _searchBar(),
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

              /// STUDENT LIST
              BlocBuilder<StudentsCubit, StudentsState>(
                builder: (context, state) {
                  if (state.loading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return Expanded(
                    child: state.studentsList.isEmpty
                        ? Center(
                            child: Image.asset(
                              "assets/images/no_data.png",
                              height: 200,
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount:
                                state.studentsList.length +
                                (state.hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < state.studentsList.length) {
                                final item = state.studentsList[index];
                                return StudentCard(
                                  studentData: item,
                                  onEdit: () => _navigateToEdit(context, item),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return TextField(
      controller: searchController,
      style: MyStyles.regularText(size: 14, color: AppTheme.black_Color),
      onChanged: (value) {
        if (_debounce?.isActive ?? false) _debounce!.cancel();

        _debounce = Timer(const Duration(milliseconds: 500), () {
          context.read<StudentsCubit>().fetchStudents(
            search: value.trim(),
            schoolId: widget.schoolId,
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
