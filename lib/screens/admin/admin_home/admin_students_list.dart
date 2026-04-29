import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/Widgets/shimmer_loader.dart';
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
import 'package:idmitra/screens/admin/admin_add_student_form/admin_add_student_form.dart';
import 'package:idmitra/screens/home/FilterBottomSheet.dart';
import 'package:idmitra/screens/home/StudentCard.dart';
import 'package:idmitra/screens/home/StudentIdCardWidget.dart';

class AdminStudentsScreen extends StatefulWidget {
  final String? schoolId;
  final bool showAppBar;
  final SchoolDetailsModel? schoolDetailsModel;
  const AdminStudentsScreen({super.key, this.schoolId, this.showAppBar = false, this.schoolDetailsModel});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  String _schoolId = '';
  bool _schoolLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.schoolId != null && widget.schoolId!.isNotEmpty) {
      _schoolId = widget.schoolId!;
      _schoolLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<StudentsCubit>().fetchStudents(search: '', schoolId: _schoolId);
        }
      });
    }

  }

  @override
  void didUpdateWidget(covariant AdminStudentsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newId = widget.schoolId ?? '';
    if (newId.isNotEmpty && newId != _schoolId) {
      setState(() {
        _schoolId = newId;
        _schoolLoaded = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<StudentsCubit>().fetchStudents(search: '', schoolId: _schoolId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_schoolLoaded || _schoolId.isEmpty) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              shimmerBox(height: 48, radius: 12),
              const SizedBox(height: 15),
              const StudentListShimmer(),
            ],
          ),
        ),
      );
    }
    return _StudentListBody(schoolId: _schoolId, showAppBar: widget.showAppBar, schoolDetailsModel: widget.schoolDetailsModel);
  }
}

class _StudentListBody extends StatefulWidget {
  final String schoolId;
  final bool showAppBar;
  final SchoolDetailsModel? schoolDetailsModel;
  const _StudentListBody({required this.schoolId, this.showAppBar = false, this.schoolDetailsModel});

  @override
  State<_StudentListBody> createState() => _StudentListBodyState();
}

class _StudentListBodyState extends State<_StudentListBody> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels == _scrollCtrl.position.maxScrollExtent) {
        context.read<StudentsCubit>().fetchStudents(
          isLoadMore: true,
          search: _searchCtrl.text.trim(),
          schoolId: widget.schoolId,
          gender: '',
          classId: '',
        );
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _navigateToAddStudent() {
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
          child: AdminAddStudentFormPage(schoolId: widget.schoolId),
        ),
      ),
    ).then((result) {
      if (result != null && result is StudentDetailsData) {
        context.read<StudentsCubit>().prependStudent(result);
      } else {
        context.read<StudentsCubit>().fetchStudents(
          search: _searchCtrl.text.trim(),
          schoolId: widget.schoolId,
          gender: '',
          classId: '',
        );
      }
    });
  }

  Future<void> _refresh() async {
    context.read<StudentsCubit>().fetchStudents(
      search: _searchCtrl.text.trim(),
      schoolId: widget.schoolId,
      gender: '',
      classId: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? CommonAppBar(title: "Student Listing")
          : null,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.btnColor,
        tooltip: 'Add Student',
        onPressed: _navigateToAddStudent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _searchBar()),
                  const SizedBox(width: 10),
                  // Filter button
                  GestureDetector(
                    onTap: () async {
                      final result = await showModalBottomSheet<Map<String, dynamic>>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: AppTheme.whiteColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                        ),
                        builder: (_) => BlocProvider(
                          create: (_) => OrdersCubit()..fetchSchoolClasses(widget.schoolId),
                          child: FilterBottomSheet(schoolId: widget.schoolId),
                        ),
                      );
                      if (result != null) {
                        _debounce?.cancel();
                        _debounce = Timer(const Duration(milliseconds: 300), () {
                          context.read<StudentsCubit>().fetchStudents(
                            search: '',
                            schoolId: widget.schoolId,
                            classId: result['class'] ?? '',
                            gender: result['gender']?.toString().toLowerCase() ?? '',
                          );
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: svgIcon(icon: 'assets/icons/filtter.svg', clr: AppTheme.black_Color),
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
      controller: _searchCtrl,
      style: MyStyles.regularText(size: 14, color: AppTheme.black_Color),
      onChanged: (value) {
        _debounce?.cancel();
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
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.backBtnBgColor),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.backBtnBgColor),
          borderRadius: BorderRadius.circular(15),
        ),
        hintStyle: MyStyles.regularText(size: 14, color: AppTheme.graySubTitleColor),
      ),
    );
  }
}
