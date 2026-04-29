import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/Widgets/svg_file.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/models/schools/SchoolListModel.dart';
import 'package:idmitra/models/students/StudentsListModel.dart';
import 'package:idmitra/providers/add_student/add_student_cubit.dart';
import 'package:idmitra/providers/orders/orders_cubit.dart';
import 'package:idmitra/providers/student_form/student_form_cubit.dart';
import 'package:idmitra/providers/student_form/student_form_data_cubit.dart';
import 'package:idmitra/providers/students/students_cubit.dart';
import 'package:idmitra/providers/students/students_state.dart';
import 'package:idmitra/screens/add_student/add_student_form.dart';
import 'package:idmitra/Widgets/shimmer_loader.dart';
import 'package:idmitra/screens/home/FilterBottomSheet.dart';
import 'package:idmitra/screens/home/StudentCard.dart';
import 'package:idmitra/screens/home/StudentIdCardWidget.dart';

class StudentListingPage extends StatefulWidget {
  final String schoolId;
  final SchoolDetailsModel? schoolDetailsModel;

  const StudentListingPage({
    super.key,
    required this.schoolId,
    this.schoolDetailsModel,
  });

  @override
  State<StudentListingPage> createState() => _StudentListingPageState();
}

class _StudentListingPageState extends State<StudentListingPage> {
  TextEditingController searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  bool _isGridView = false;

  void _navigateToAddStudent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => StudentFormCubit()
                ..loadFromSchoolId(
                    schoolId: widget.schoolId, schoolName: ''),
            ),
            BlocProvider(
              create: (_) => StudentFormDataCubit()..load(widget.schoolId),
            ),
            BlocProvider(create: (_) => AddStudentCubit()),
          ],
          child: AddStudentFormPage(schoolId: widget.schoolId),
        ),
      ),
    ).then((result) {
      if (result != null && result is StudentDetailsData) {
        context.read<StudentsCubit>().prependStudent(result);
      } else {
        context.read<StudentsCubit>().fetchStudents(
          search: searchController.text.trim(),
          schoolId: widget.schoolId,
          gender: '',
          classId: '',
        );
      }
    });
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
          gender: '',
          classId: '',
        );
      }
    });
  }

  Future<void> refreshData() async {
    context.read<StudentsCubit>().fetchStudents(
      search: '',
      schoolId: widget.schoolId,
      gender: '',
      classId: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Student Listings'),
      floatingActionButton: _isGridView
          ? null
          : FloatingActionButton(
        backgroundColor: AppTheme.btnColor,
        tooltip: 'Add Student',
        onPressed: () => _navigateToAddStudent(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// SEARCH + FILTER + TOGGLE
              Row(
                children: [
                  Expanded(child: _searchBar()),
                  const SizedBox(width: 8),

                  /// Filter button
                  GestureDetector(
                    onTap: () async {
                      final result =
                      await showModalBottomSheet<Map<String, dynamic>>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: AppTheme.whiteColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(25),
                          ),
                        ),
                        builder: (_) {
                          return BlocProvider(
                            create: (_) => OrdersCubit()
                              ..fetchSchoolClasses(widget.schoolId),
                            child: FilterBottomSheet(
                              schoolId: widget.schoolId,
                            ),
                          );
                        },
                      );

                      if (result != null) {
                        final String? classId = result['class'];
                        final String? gender =
                        result['gender']?.toString().toLowerCase();
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(
                          const Duration(milliseconds: 500),
                              () {
                            context.read<StudentsCubit>().fetchStudents(
                              search: '',
                              schoolId: widget.schoolId,
                              classId: classId ?? '',
                              gender: gender ?? '',
                            );
                          },
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: svgIcon(
                        icon: 'assets/icons/filtter.svg',
                        clr: AppTheme.black_Color,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _isGridView = !_isGridView),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _isGridView ? AppTheme.btnColor : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isGridView
                            ? Icons.view_list_rounded
                            : Icons.badge_outlined,
                        size: 20,
                        color:
                        _isGridView ? Colors.white : AppTheme.black_Color,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Expanded(
                child: BlocBuilder<StudentsCubit, StudentsState>(
                  builder: (context, state) {
                    if (state.loading) {
                      return const ShimmerList(expanded: false);
                    }

                    if (state.studentsList.isEmpty) {
                      return Center(
                        child: Image.asset(
                          "assets/images/no_data.png",
                          height: 200,
                        ),
                      );
                    }

                    final itemCount =
                        state.studentsList.length + (state.hasMore ? 1 : 0);


                    if (_isGridView) {
                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: _scrollController,
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          if (index < state.studentsList.length) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Center(
                                child: SizedBox(
                                  width: 300,
                                  child: StudentIdCardWidget(
                                    student: state.studentsList[index],
                                    schoolId: widget.schoolId,
                                    schoolDetailsModel:
                                    widget.schoolDetailsModel,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child:
                            Center(child: CircularProgressIndicator()),
                          );
                        },
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        if (index < state.studentsList.length) {
                          return StudentCard(
                            studentData: state.studentsList[index],
                            schoolId: widget.schoolId,
                          );
                        }
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
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
        filled: true,
        fillColor: AppTheme.whiteColor,
        contentPadding: const EdgeInsets.all(12),
        hintText: 'Search by name...',
        prefixIcon: const Icon(Icons.search),
        enabledBorder: appBorder(AppTheme.backBtnBgColor, 15),
        focusedBorder: appBorder(AppTheme.backBtnBgColor, 15),
        errorBorder: appBorder(AppTheme.errorMessageBackgroundColor, 15),
        focusedErrorBorder:
        appBorder(AppTheme.errorMessageBackgroundColor, 15),
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