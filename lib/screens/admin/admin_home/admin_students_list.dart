import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:idmitra/api_mamanger/api_manager.dart';
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/Widgets/shimmer_loader.dart';
import 'package:idmitra/Widgets/svg_file.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/components/text_filed.dart';
import 'package:idmitra/models/correction/CorrectionListModel.dart';
import 'package:idmitra/models/orders/OrderModel.dart';
import 'package:idmitra/models/schools/SchoolListModel.dart';
import 'package:idmitra/models/students/StudentsListModel.dart';
import 'package:idmitra/providers/add_student/add_student_cubit.dart';
import 'package:idmitra/providers/correction/correction_cubit.dart';
import 'package:idmitra/providers/correction/correction_state.dart';
import 'package:idmitra/providers/orders/orders_cubit.dart';
import 'package:idmitra/providers/orders/orders_state.dart';
import 'package:idmitra/providers/student_form/student_form_cubit.dart';
import 'package:idmitra/providers/student_form/student_form_data_cubit.dart';
import 'package:idmitra/providers/students/students_cubit.dart';
import 'package:idmitra/providers/students/students_state.dart';
import 'package:idmitra/screens/admin/admin_add_student_form/admin_add_student_form.dart';
import 'package:idmitra/screens/admin/admin_order/admin_order_detail_page.dart';
import 'package:idmitra/screens/home/FilterBottomSheet.dart';
import 'package:idmitra/screens/home/StudentCard.dart';
import 'package:idmitra/screens/home/StudentIdCardWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminStudentsScreen extends StatefulWidget {
  final String? schoolId;
  final bool showAppBar;
  final SchoolDetailsModel? schoolDetailsModel;

  const AdminStudentsScreen({
    super.key,
    this.schoolId,
    this.showAppBar = false,
    this.schoolDetailsModel,
  });

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen>
    with SingleTickerProviderStateMixin {
  String _schoolId = '';
  bool _schoolLoaded = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.schoolId != null && widget.schoolId!.isNotEmpty) {
      _schoolId = widget.schoolId!;
      _schoolLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<StudentsCubit>().fetchStudents(
            search: '',
            schoolId: _schoolId,
          );
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
          context.read<StudentsCubit>().fetchStudents(
            search: '',
            schoolId: _schoolId,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(color: AppTheme.titleHintColor),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              centerTitle: true,
              title: Text(
                'Student Listings',
                style: MyStyles.boldText(size: 20, color: Colors.black),
              ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: AppTheme.btnColor,
                unselectedLabelColor: AppTheme.graySubTitleColor,
                indicatorColor: AppTheme.btnColor,
                indicatorWeight: 2.5,
                labelStyle: MyStyles.mediumText(size: 13, color: Colors.white),
                unselectedLabelStyle: MyStyles.regularText(
                  size: 13,
                  color: Colors.white,
                ),
                tabs: const [
                  Tab(text: 'Students List'),
                  Tab(text: 'Correction List'),
                  Tab(text: 'Orders List'),
                ],
              ),
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(kTextTabBarHeight),
              child: Material(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.btnColor,
                  unselectedLabelColor: AppTheme.graySubTitleColor,
                  indicatorColor: AppTheme.btnColor,
                  indicatorWeight: 2.5,
                  labelStyle: MyStyles.mediumText(
                    size: 13,
                    color: Colors.white,
                  ),
                  unselectedLabelStyle: MyStyles.regularText(
                    size: 13,
                    color: Colors.white,
                  ),
                  tabs: const [
                    Tab(text: 'Students List'),
                    Tab(text: 'Correction List'),
                    Tab(text: 'Orders'),
                  ],
                ),
              ),
            ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AdminStudentsTab(
            schoolId: _schoolId,
            schoolDetailsModel: widget.schoolDetailsModel,
          ),
          BlocProvider(
            create: (_) =>
                CorrectionCubit()..fetchCorrectionStudents(schoolId: _schoolId),
            child: _AdminCorrectionTab(schoolId: _schoolId),
          ),
          BlocProvider(
            create: (_) => OrdersCubit()
              ..fetchOrders(schoolId: _schoolId, isSchool: true)
              ..fetchSchoolClasses(_schoolId),
            child: _AdminOrdersTab(schoolId: _schoolId, isSchool: true),
          ),
        ],
      ),
    );
  }
}

class _AdminStudentsTab extends StatefulWidget {
  final String schoolId;
  final SchoolDetailsModel? schoolDetailsModel;
  const _AdminStudentsTab({required this.schoolId, this.schoolDetailsModel});

  @override
  State<_AdminStudentsTab> createState() => _AdminStudentsTabState();
}

class _AdminStudentsTabState extends State<_AdminStudentsTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final ScrollController _gridScrollCtrl = ScrollController();
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
    _gridScrollCtrl.dispose();
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
    ).then((_) {
      context.read<StudentsCubit>().fetchStudents(
        search: _searchCtrl.text.trim(),
        schoolId: widget.schoolId,
        gender: '',
        classId: '',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _isGridView
          ? null
          : FloatingActionButton(
              backgroundColor: AppTheme.btnColor,
              tooltip: 'Add Student',
              onPressed: _navigateToAddStudent,
              child: const Icon(Icons.add, color: Colors.white),
            ),
      body: RefreshIndicator(
        onRefresh: () async => context.read<StudentsCubit>().fetchStudents(
          search: _searchCtrl.text.trim(),
          schoolId: widget.schoolId,
          gender: '',
          classId: '',
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _searchBar()),
                  const SizedBox(width: 10),
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
                            builder: (_) => BlocProvider(
                              create: (_) =>
                                  OrdersCubit()
                                    ..fetchSchoolClasses(widget.schoolId),
                              child: FilterBottomSheet(
                                schoolId: widget.schoolId,
                              ),
                            ),
                          );
                      if (result != null) {
                        _debounce?.cancel();
                        _debounce = Timer(
                          const Duration(milliseconds: 300),
                          () {
                            context.read<StudentsCubit>().applyFilters(
                              schoolId: widget.schoolId,
                              classId: result["class"] ?? "",
                              sectionIds: List<int>.from(
                                result["section"] ?? [],
                              ),
                              gender: result["gender"] ?? "",
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
                //  const SizedBox(width: 8),
                  // GestureDetector(
                  //   onTap: () => setState(() => _isGridView = !_isGridView),
                  //   child: Container(
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 12,
                  //       vertical: 10,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: _isGridView ? AppTheme.btnColor : Colors.white,
                  //       borderRadius: BorderRadius.circular(12),
                  //       border: Border.all(
                  //         color: _isGridView
                  //             ? AppTheme.btnColor
                  //             : Colors.grey.shade300,
                  //         width: 1,
                  //       ),
                  //       boxShadow: _isGridView
                  //           ? [
                  //               BoxShadow(
                  //                 color: AppTheme.btnColor.withOpacity(0.3),
                  //                 blurRadius: 8,
                  //                 offset: const Offset(0, 3),
                  //               ),
                  //             ]
                  //           : [],
                  //     ),
                  //     child: Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         Icon(
                  //           _isGridView
                  //               ? Icons.view_list_rounded
                  //               : Icons.badge_outlined,
                  //           size: 18,
                  //           color: _isGridView
                  //               ? Colors.white
                  //               : AppTheme.black_Color,
                  //         ),
                  //         const SizedBox(width: 6),
                  //         Text(
                  //           _isGridView ? 'List' : 'ID Card',
                  //           style: MyStyles.mediumText(
                  //             size: 12,
                  //             color: _isGridView
                  //                 ? Colors.white
                  //                 : AppTheme.black_Color,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 15),
              Expanded(
                child: BlocBuilder<StudentsCubit, StudentsState>(
                  builder: (context, state) {
                    if (state.loading)
                      return const ShimmerList(expanded: false);
                    if (state.studentsList.isEmpty) {
                      return Center(
                        child: Image.asset(
                          'assets/images/no_data.png',
                          height: 200,
                        ),
                      );
                    }
                    final itemCount =
                        state.studentsList.length + (state.hasMore ? 1 : 0);
                    if (_isGridView) {
                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: _gridScrollCtrl,
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          if (index < state.studentsList.length) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Center(
                                child: SizedBox(
                                  width: 300,
                                  child: Hero(
                                    tag:
                                        'student_card_${state.studentsList[index].uuid}',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: StudentIdCardWidget(
                                        student: state.studentsList[index],
                                        schoolId: widget.schoolId,
                                        schoolDetailsModel:
                                            widget.schoolDetailsModel,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                      );
                    }
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollCtrl,
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        if (index < state.studentsList.length) {
                          final student = state.studentsList[index];
                          return StudentCard(
                            key: ValueKey(student.uuid),
                            studentData: student,
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

  Widget _searchBar() => TextField(
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
      hintStyle: MyStyles.regularText(
        size: 14,
        color: AppTheme.graySubTitleColor,
      ),
    ),
  );
}

class _AdminCorrectionTab extends StatefulWidget {
  final String schoolId;
  final VoidCallback? onOrderSent;
  const _AdminCorrectionTab({required this.schoolId, this.onOrderSent});

  @override
  State<_AdminCorrectionTab> createState() => _AdminCorrectionTabState();
}

class _AdminCorrectionTabState extends State<_AdminCorrectionTab> {
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        context.read<CorrectionCubit>().fetchCorrectionStudents(
          schoolId: widget.schoolId,
          isLoadMore: true,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _isGridView
          ? null
          : FloatingActionButton(
              backgroundColor: AppTheme.btnColor,
              tooltip: 'Download',
              onPressed: () => _showDownloadDialog(context),
              child: const Icon(Icons.download_rounded, color: Colors.white),
            ),
      body: BlocListener<CorrectionCubit, CorrectionState>(
      listenWhen: (p, c) =>
          p.downloadUrl != c.downloadUrl ||
          p.downloadError != c.downloadError ||
          p.sendOrderSuccess != c.sendOrderSuccess ||
          p.sendOrderError != c.sendOrderError,
      listener: (context, state) async {
        if (state.sendOrderSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Order sent successfully!'),
              backgroundColor: AppTheme.btnColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(12),
            ),
          );
        }
        if (state.sendOrderError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.sendOrderError!),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(12),
            ),
          );
        }
        if (!state.downloadLoading &&
            state.downloadUrl != null &&
            state.downloadUrl!.isNotEmpty) {
          final uri = Uri.tryParse(state.downloadUrl!);
          if (uri != null) {
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (_) {}
          }
        }
        if (!state.downloadLoading && state.downloadError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.downloadError!),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(12),
            ),
          );
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _searchBar()),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _isGridView = !_isGridView),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isGridView ? AppTheme.btnColor : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isGridView ? AppTheme.btnColor : Colors.grey.shade300,
                      ),
                      boxShadow: _isGridView
                          ? [BoxShadow(color: AppTheme.btnColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isGridView ? Icons.view_list_rounded : Icons.badge_outlined,
                          size: 18,
                          color: _isGridView ? Colors.white : AppTheme.black_Color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isGridView ? 'List' : 'ID Card',
                          style: MyStyles.mediumText(
                            size: 12,
                            color: _isGridView ? Colors.white : AppTheme.black_Color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                          builder: (_) => BlocProvider(
                            create: (_) =>
                                OrdersCubit()
                                  ..fetchSchoolClasses(widget.schoolId),
                            child: FilterBottomSheet(schoolId: widget.schoolId),
                          ),
                        );
                    if (result != null) {
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 300), () {
                        context.read<CorrectionCubit>().fetchCorrectionStudents(
                          schoolId: widget.schoolId,
                          classFilter: result['class'] ?? '',
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
                    child: svgIcon(
                      icon: 'assets/icons/filtter.svg',
                      clr: AppTheme.black_Color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<CorrectionCubit, CorrectionState>(
              builder: (context, state) {
                if (state.studentsLoading && state.students.isEmpty) {
                  return const ShimmerList(expanded: false);
                }
                if (state.studentsError != null && state.students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.studentsError!,
                          style: MyStyles.regularText(
                            size: 14,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context
                              .read<CorrectionCubit>()
                              .fetchCorrectionStudents(
                                schoolId: widget.schoolId,
                              ),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.btnColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (state.students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/no_data.png', height: 160),
                        const SizedBox(height: 12),
                        Text(
                          'No students found',
                          style: MyStyles.mediumText(
                            size: 14,
                            color: AppTheme.graySubTitleColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  color: AppTheme.btnColor,
                  onRefresh: () async => context
                      .read<CorrectionCubit>()
                      .fetchCorrectionStudents(schoolId: widget.schoolId),
                  child: Column(
                    children: [
                      if (!_isGridView && state.selectedStudentIds.isNotEmpty)
                        Container(
                          color: AppTheme.btnColor.withOpacity(0.08),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${state.selectedStudentIds.length} selected',
                                style: MyStyles.mediumText(
                                  size: 13,
                                  color: AppTheme.btnColor,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () => context
                                    .read<CorrectionCubit>()
                                    .selectAllStudents(),
                                child: Text(
                                  'Select All',
                                  style: MyStyles.mediumText(
                                    size: 12,
                                    color: AppTheme.btnColor,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => context
                                    .read<CorrectionCubit>()
                                    .clearStudentSelection(),
                                child: Text(
                                  'Clear',
                                  style: MyStyles.mediumText(
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              state.sendOrderLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.btnColor,
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () {},
                                      // => context
                                      //     .read<CorrectionCubit>()
                                      //     .processOrder(
                                      //       schoolId: widget.schoolId,
                                      //     ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.btnColor,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.send_rounded,
                                              size: 13,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Send Order',
                                              style: MyStyles.mediumText(
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: _isGridView
                            ? ListView.builder(
                                controller: _scrollCtrl,
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                                itemCount: state.students.length + (state.studentsHasMore ? 1 : 0),
                                itemBuilder: (_, i) {
                                  if (i < state.students.length) {
                                    final s = state.students[i].student;
                                    if (s == null) return const SizedBox.shrink();
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 20),
                                      child: Center(
                                        child: SizedBox(
                                          width: 300,
                                          child: StudentIdCardWidget(
                                            student: _correctionToStudentData(s),
                                            schoolId: widget.schoolId,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(child: CircularProgressIndicator(color: AppTheme.btnColor, strokeWidth: 2)),
                                  );
                                },
                              )
                            : ListView.builder(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                          itemCount:
                              state.students.length +
                              (state.studentsHasMore ? 1 : 0),
                          itemBuilder: (_, i) {
                            if (i < state.students.length) {
                              final item = state.students[i];
                              final isSelected = state.selectedStudentIds
                                  .contains(item.id);
                              return _CorrectionStudentCard(
                                item: item,
                                isSelected: isSelected,
                                onToggle: () => context
                                    .read<CorrectionCubit>()
                                    .toggleStudentSelection(item.id),
                              );
                            }
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.btnColor,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _showDownloadDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: ctx.read<CorrectionCubit>(),
        child: _DownloadChecklistDialog(schoolId: widget.schoolId),
      ),
    );
  }

  StudentDetailsData _correctionToStudentData(CorrectionStudentData s) {
    return StudentDetailsData(
      id: s.id,
      uuid: s.uuid,
      schoolId: s.schoolId,
      name: s.name,
      photo: s.photo,
      profilePhotoUrl: s.photoUrl,
      fatherName: s.fatherName,
      fatherPhone: s.fatherPhone,
      motherName: s.motherName,
      motherPhone: s.motherPhone,
      address: s.address,
      dob: s.dob,
      regNo: s.regNo,
      rollNo: s.rollNo,
      admissionNo: s.admissionNo,
      schoolClassId: s.schoolClassId,
      schoolClassSectionId: s.schoolClassSectionId,
      datumClass: s.studentClass != null
          ? Class(id: s.studentClass!.id, nameWithprefix: s.studentClass!.nameWithPrefix)
          : null,
      section: s.section != null
          ? Section(id: s.section!.id, name: s.section!.name)
          : null,
    );
  }

  Widget _searchBar() => TextField(
    controller: _searchCtrl,
    style: MyStyles.regularText(size: 14, color: AppTheme.black_Color),
    onChanged: (value) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        context.read<CorrectionCubit>().fetchCorrectionStudents(
          schoolId: widget.schoolId,
          search: value.trim(),
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
      hintStyle: MyStyles.regularText(
        size: 14,
        color: AppTheme.graySubTitleColor,
      ),
    ),
  );
}

class _CorrectionStudentCard extends StatefulWidget {
  final CorrectionStudentItem item;
  final bool isSelected;
  final VoidCallback onToggle;
  const _CorrectionStudentCard({
    required this.item,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  State<_CorrectionStudentCard> createState() => _CorrectionStudentCardState();
}

class _CorrectionStudentCardState extends State<_CorrectionStudentCard> {
  String? _currentPhotoUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final s = widget.item.student;
    _currentPhotoUrl = s?.photoUrl ?? s?.photo ?? '';
  }

  Future<void> _fromCamera() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    if (pickedFile != null) {
      File rotatedImage = await FlutterExifRotation.rotateImage(path: pickedFile.path);
      await _uploadImage(rotatedImage.path);
    }
  }

  Future<void> _fromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: AppTheme.MainColor,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(title: 'Crop Image', aspectRatioLockEnabled: true),
      ],
    );
    if (croppedFile != null) {
      await _uploadImage(croppedFile.path);
    }
  }

  Future<void> _uploadImage(String path) async {
    setState(() => _isUploading = true);
    try {
      File fixedImage = await FlutterExifRotation.rotateImage(path: path);
      final uuid = widget.item.student?.uuid ?? '';
      var response = await ApiManager().multiRequestRoute(
        fixedImage.path,
        Config.baseUrl + Routes.updateStudentProfile(uuid),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _currentPhotoUrl = jsonData['data']['profile_photo_url'];
        });
      }
    } catch (e) {
      debugPrint("Upload error: $e");
    }
    setState(() => _isUploading = false);
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Choose Image", style: MyStyles.boldText(size: 14, color: Colors.black)),
            const SizedBox(height: 15),
            InkWell(
              onTap: () { Navigator.pop(ctx); _fromCamera(); },
              child: Row(children: [
                SvgPicture.asset('assets/icons/camera_single.svg'),
                const SizedBox(width: 10),
                Text("Camera", style: MyStyles.regularText(size: 14, color: Colors.black)),
              ]),
            ),
            Container(margin: const EdgeInsets.symmetric(vertical: 10), height: 1, color: Colors.grey.shade300),
            InkWell(
              onTap: () { Navigator.pop(ctx); _fromGallery(); },
              child: Row(children: [
                SvgPicture.asset('assets/icons/choose_from_gallery.svg'),
                const SizedBox(width: 10),
                Text("Gallery", style: MyStyles.regularText(size: 14, color: Colors.black)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: Colors.black,
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.8,
                    maxScale: 4,
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
                      },
                      errorBuilder: (_, __, ___) => Container(
                        height: 300,
                        width: double.infinity,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.person, size: 80, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showPicker();
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Profile Image"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.item.student;
    final className = s?.studentClass?.nameWithPrefix ?? '';
    final sectionName = s?.section?.name ?? '';
    final fatherPhone = s?.fatherPhone ?? '';
    final photoUrl = _currentPhotoUrl ?? '';

    return GestureDetector(
      onTap: widget.onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? AppTheme.btnColor.withOpacity(0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isSelected ? AppTheme.btnColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: widget.isSelected,
                onChanged: (_) => widget.onToggle(),
                activeColor: AppTheme.btnColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: BorderSide(color: AppTheme.graySubTitleColor),
              ),
            ),
            const SizedBox(width: 10),
            // Photo with tap handler
            GestureDetector(
              onTap: () {
                if (photoUrl.isNotEmpty) {
                  _showImagePreview(photoUrl);
                } else {
                  _showPicker();
                }
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: _isUploading
                        ? const SizedBox(
                            height: 60,
                            width: 60,
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : photoUrl.isNotEmpty
                            ? Image.network(
                                photoUrl,
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _placeholder(),
                              )
                            : _placeholder(),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 22,
                      width: 22,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        photoUrl.isNotEmpty ? Icons.preview : Icons.camera_alt,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          s?.name ?? '',
                          style: MyStyles.boldText(size: 16, color: AppTheme.black_Color),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (className.isNotEmpty) ...[
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '• $className${sectionName.isNotEmpty ? ' ($sectionName)' : ''}',
                            style: MyStyles.boldText(size: 14, color: AppTheme.btnColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  if (fatherPhone.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(fatherPhone, style: MyStyles.regularText(size: 12, color: AppTheme.graySubTitleColor)),
                      ],
                    ),
                  const SizedBox(height: 2),
                  if ((s?.fatherName ?? '').isNotEmpty)
                    Text('F: ${s!.fatherName}', style: MyStyles.regularText(size: 12, color: AppTheme.graySubTitleColor)),
                  if ((s?.motherName ?? '').isNotEmpty)
                    Text('M: ${s!.motherName}', style: MyStyles.regularText(size: 12, color: AppTheme.graySubTitleColor)),
                  if ((s?.address ?? '').isNotEmpty)
                    Text(s!.address!, style: MyStyles.regularText(size: 11, color: AppTheme.graySubTitleColor), overflow: TextOverflow.ellipsis, maxLines: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    height: 60,
    width: 60,
    color: Colors.grey.shade200,
    child: const Icon(Icons.person, color: Colors.grey),
  );
}

class _DownloadChecklistDialog extends StatefulWidget {
  final String schoolId;
  const _DownloadChecklistDialog({required this.schoolId});

  @override
  State<_DownloadChecklistDialog> createState() =>
      _DownloadChecklistDialogState();
}

class _DownloadChecklistDialogState extends State<_DownloadChecklistDialog> {
  Set<String> _selectedColumns = {};
  String _printType = '';

  List<Map<String, String>> _buildPrintTypes(List<CorrectionItem> items) {
    final types = items
        .map((e) => e.listType ?? '')
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();
    return [
      {'value': '', 'label': '-Select Print Type-'},
      ...types.map(
        (t) => {
          'value': t,
          'label': t == 'class_wise'
              ? 'Class Wise'
              : t == 'section_wise'
              ? 'Section Wise'
              : t
                    .replaceAll('_', ' ')
                    .split(' ')
                    .map(
                      (w) => w.isNotEmpty
                          ? '${w[0].toUpperCase()}${w.substring(1)}'
                          : '',
                    )
                    .join(' '),
        },
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    context.read<CorrectionCubit>().fetchDownloadColumns(
      schoolId: widget.schoolId,
    );
  }

  void _toggleColumn(String key) {
    setState(() {
      if (_selectedColumns.contains(key)) {
        _selectedColumns.remove(key);
      } else {
        _selectedColumns.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CorrectionCubit, CorrectionState>(
      listenWhen: (p, c) =>
          p.downloadLoading != c.downloadLoading ||
          p.downloadUrl != c.downloadUrl ||
          p.downloadError != c.downloadError ||
          (p.columnsLoading && !c.columnsLoading),
      listener: (ctx, state) async {
        if (!state.columnsLoading &&
            state.downloadColumns.isNotEmpty &&
            _selectedColumns.isEmpty) {
          setState(() {
            _selectedColumns = state.downloadColumns.map((c) => c.key).toSet();
          });
        }
        if (!state.downloadLoading &&
            state.downloadUrl != null &&
            state.downloadUrl!.isNotEmpty) {
          Navigator.of(context).pop();
          final uri = Uri.tryParse(state.downloadUrl!);
          if (uri != null) {
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (_) {}
          }
        }
        if (!state.downloadLoading && state.downloadError != null) {
          Navigator.of(context).pop();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.downloadError!),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(12),
              ),
            );
          }
        }
      },
      builder: (context, state) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Download Checklist',
                    style: MyStyles.boldText(
                      size: 18,
                      color: AppTheme.black_Color,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Select Data You Want to Display in Correction List',
                style: MyStyles.mediumText(
                  size: 13,
                  color: AppTheme.graySubTitleColor,
                ),
              ),
              const SizedBox(height: 16),
              if (state.columnsLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(
                      color: AppTheme.btnColor,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (state.downloadColumns.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No columns available',
                    style: MyStyles.regularText(
                      size: 13,
                      color: AppTheme.graySubTitleColor,
                    ),
                  ),
                )
              else
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 3.2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 4,
                  children: state.downloadColumns.map((col) {
                    final isSelected = _selectedColumns.contains(col.key);
                    return GestureDetector(
                      onTap: () => _toggleColumn(col.key),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.btnColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.btnColor
                                    : Colors.grey.shade400,
                                width: 1.5,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 13,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              col.label,
                              style: MyStyles.regularText(
                                size: 12,
                                color: AppTheme.black_Color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
              Text(
                'Print List Type *',
                style: MyStyles.mediumText(
                  size: 13,
                  color: AppTheme.black_Color,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _printType,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.graySubTitleColor,
                    ),
                    style: MyStyles.regularText(
                      size: 14,
                      color: AppTheme.black_Color,
                    ),
                    items: _buildPrintTypes(state.items)
                        .map(
                          (t) => DropdownMenuItem<String>(
                            value: t['value']!,
                            child: Text(
                              t['label']!,
                              style: MyStyles.regularText(
                                size: 14,
                                color: AppTheme.black_Color,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _printType = v ?? ''),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: state.downloadLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        'Cancel',
                        style: MyStyles.mediumText(
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: state.downloadLoading
                        ? null
                        : () {
                            if (_printType.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Please select a Print List Type',
                                  ),
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.all(12),
                                ),
                              );
                              return;
                            }
                            if (_selectedColumns.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Please select at least one column',
                                  ),
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.all(12),
                                ),
                              );
                              return;
                            }
                            context
                                .read<CorrectionCubit>()
                                .downloadCorrectionList(
                                  schoolId: widget.schoolId,
                                  columns: _selectedColumns.toList(),
                                  printType: _printType,
                                );
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: state.downloadLoading
                            ? Colors.grey
                            : const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: state.downloadLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Confirm',
                              style: MyStyles.mediumText(
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminOrdersTab extends StatefulWidget {
  final String schoolId;
  final bool isSchool;
  const _AdminOrdersTab({required this.schoolId, this.isSchool = true});

  @override
  State<_AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends State<_AdminOrdersTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _dateFromCtrl = TextEditingController();
  final TextEditingController _dateToCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  Timer? _debounce;

  String _selectedStatus = '';
  String _selectedClass = '';

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        context.read<OrdersCubit>().fetchOrders(
          isLoadMore: true,
          search: _searchCtrl.text.trim(),
          status: _selectedStatus,
          classId: _selectedClass,
          schoolId: widget.schoolId,
          isSchool: widget.isSchool,
          dateFrom: _dateFromCtrl.text,
          dateTo: _dateToCtrl.text,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _dateFromCtrl.dispose();
    _dateToCtrl.dispose();
    _scrollCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _resetAndFetch() {
    context.read<OrdersCubit>().fetchOrders(
      search: _searchCtrl.text.trim(),
      status: _selectedStatus,
      classId: _selectedClass,
      schoolId: widget.schoolId,
      isSchool: widget.isSchool,
      dateFrom: _dateFromCtrl.text,
      dateTo: _dateToCtrl.text,
    );
  }

  bool get _hasActiveFilters =>
      _selectedStatus.isNotEmpty ||
      _selectedClass.isNotEmpty ||
      _dateFromCtrl.text.isNotEmpty ||
      _dateToCtrl.text.isNotEmpty;

  void _clearFilters() {
    setState(() {
      _selectedStatus = '';
      _selectedClass = '';
      _dateFromCtrl.clear();
      _dateToCtrl.clear();
    });
    _resetAndFetch();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: _searchBar(),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            children: [
              const Divider(height: 1, color: AppTheme.LineColor),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _classDropdown()),
                  const SizedBox(width: 8),
                  Expanded(child: _statusDropdown()),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _dateField(_dateFromCtrl, 'From dd-mm-yyyy')),
                  const SizedBox(width: 8),
                  Expanded(child: _dateField(_dateToCtrl, 'To dd-mm-yyyy')),
                ],
              ),
              if (_hasActiveFilters) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _clearFilters,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightRedColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.close,
                            size: 12,
                            color: AppTheme.cancelTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Clear Filters',
                            style: MyStyles.mediumText(
                              size: 11,
                              color: AppTheme.cancelTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<OrdersCubit, OrdersState>(
            builder: (_, state) {
              if (state.loading && state.ordersList.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: OrderListShimmer(),
                );
              }
              if (state.error != null && state.ordersList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.error!,
                        style: MyStyles.regularText(
                          size: 14,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _resetAndFetch,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.btnColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (state.ordersList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/no_data.png', height: 160),
                      const SizedBox(height: 12),
                      Text(
                        'No orders found',
                        style: MyStyles.mediumText(
                          size: 14,
                          color: AppTheme.graySubTitleColor,
                        ),
                      ),
                      if (_hasActiveFilters) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _clearFilters,
                          child: Text(
                            'Clear filters',
                            style: MyStyles.mediumText(
                              size: 13,
                              color: AppTheme.btnColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                color: AppTheme.btnColor,
                onRefresh: () async => _resetAndFetch(),
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  itemCount: state.ordersList.length + (state.hasMore ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i < state.ordersList.length) {
                      return _AdminOrderCard(
                        order: state.ordersList[i],
                        schoolId: widget.schoolId,
                        isSchool: widget.isSchool,
                      );
                    }
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.btnColor,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _searchBar() => TextField(
    controller: _searchCtrl,
    style: MyStyles.regularText(size: 14, color: AppTheme.black_Color),
    onChanged: (_) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), _resetAndFetch);
    },
    decoration: InputDecoration(
      filled: true,
      fillColor: AppTheme.appBackgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintText: 'Search by student name, order ID...',
      prefixIcon: const Icon(
        Icons.search_rounded,
        size: 20,
        color: AppTheme.graySubTitleColor,
      ),
      suffixIcon: _searchCtrl.text.isNotEmpty
          ? GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                setState(() {});
                _resetAndFetch();
              },
              child: const Icon(
                Icons.close,
                size: 16,
                color: AppTheme.graySubTitleColor,
              ),
            )
          : null,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.backBtnBgColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppTheme.btnColor),
        borderRadius: BorderRadius.circular(12),
      ),
      hintStyle: MyStyles.regularText(
        size: 13,
        color: AppTheme.graySubTitleColor,
      ),
    ),
  );

  Widget _classDropdown() => BlocBuilder<OrdersCubit, OrdersState>(
    buildWhen: (p, c) =>
        p.availableClasses != c.availableClasses ||
        p.classesLoading != c.classesLoading,
    builder: (_, state) => _dropdown(
      value: _selectedClass.isEmpty ? '' : _selectedClass,
      hint: 'All Classes',
      loading: state.classesLoading,
      items: [
        const DropdownMenuItem(value: '', child: Text('All Classes')),
        ...state.availableClasses.map(
          (c) => DropdownMenuItem(
            value: c.classId.toString(),
            child: Text(
              c.nameWithprefix ?? c.name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: (v) {
        setState(() => _selectedClass = v ?? '');
        WidgetsBinding.instance.addPostFrameCallback((_) => _resetAndFetch());
      },
    ),
  );

  Widget _statusDropdown() => _dropdown(
    value: _selectedStatus,
    hint: 'All Status',
    items: kOrderFilterStatuses
        .map(
          (s) => DropdownMenuItem<String>(
            value: s.value,
            child: Text(s.label, overflow: TextOverflow.ellipsis),
          ),
        )
        .toList(),
    onChanged: (v) {
      setState(() => _selectedStatus = v ?? '');
      WidgetsBinding.instance.addPostFrameCallback((_) => _resetAndFetch());
    },
  );

  Widget _dropdown({
    required String value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    bool loading = false,
  }) => Container(
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: AppTheme.appBackgroundColor,
      border: Border.all(color: AppTheme.backBtnBgColor.withOpacity(0.5)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        menuMaxHeight: 300,
        icon: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.btnColor,
                ),
              )
            : const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppTheme.graySubTitleColor,
              ),
        style: MyStyles.regularText(size: 13, color: AppTheme.black_Color),
        items: items,
        onChanged: onChanged,
      ),
    ),
  );

  Widget _dateField(TextEditingController ctrl, String hint) {
    return StatefulBuilder(
      builder: (context, setLocal) => AppTextField(
        controller: ctrl,
        hintText: hint,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d.\-/]')),
          LengthLimitingTextInputFormatter(10),
          _DotDateFormatter(),
        ],
        suffixIcon: ctrl.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  ctrl.clear();
                  setLocal(() {});
                  _debounce?.cancel();
                  _debounce = Timer(
                    const Duration(milliseconds: 200),
                    _resetAndFetch,
                  );
                },
                child: const Icon(Icons.close, size: 16),
              )
            : null,
        onChanged: (_) {
          setLocal(() {});
          if (ctrl.text.length == 10 || ctrl.text.isEmpty) {
            _debounce?.cancel();
            _debounce = Timer(
              const Duration(milliseconds: 400),
              _resetAndFetch,
            );
          }
        },
      ),
    );
  }
}

class _AdminOrderCard extends StatefulWidget {
  final OrderModel order;
  final String schoolId;
  final bool isSchool;
  const _AdminOrderCard({
    required this.order,
    this.schoolId = '',
    this.isSchool = true,
  });

  @override
  State<_AdminOrderCard> createState() => _AdminOrderCardState();
}

class _AdminOrderCardState extends State<_AdminOrderCard> {
  late String _currentStatus;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
  }

  Color get _statusColor {
    switch (_currentStatus) {
      case 'completed':
        return const Color(0xFF2DC24E);
      case 'cancelled':
        return AppTheme.cancelTextColor;
      case 'work_in_process':
        return AppTheme.btnColor;
      case 're_order':
        return AppTheme.PendingDotColor;
      default:
        return AppTheme.graySubTitleColor;
    }
  }

  Color get _statusBg {
    switch (_currentStatus) {
      case 'completed':
        return const Color(0xFFE8F9ED);
      case 'cancelled':
        return AppTheme.lightRedColor;
      case 'work_in_process':
        return AppTheme.lightBlueColor;
      case 're_order':
        return AppTheme.PendingLightColor;
      default:
        return AppTheme.appBackgroundColor;
    }
  }

  String get _statusLabel => kOrderStatuses
      .firstWhere(
        (s) => s.value == _currentStatus,
        orElse: () => OrderStatusOption(
          _currentStatus,
          _currentStatus.replaceAll('_', ' '),
        ),
      )
      .label;

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _updating = true);
    final success = await context.read<OrdersCubit>().updateOrderStatus(
      widget.order.uuid,
      newStatus,
    );
    if (!mounted) return;
    setState(() {
      _updating = false;
      if (success) _currentStatus = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Status updated successfully' : 'Failed to update status',
        ),
        backgroundColor: success ? AppTheme.btnColor : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.order.student;
    final school = widget.order.school;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminOrderDetailPage(
            uuid: widget.order.uuid,
            schoolId: widget.schoolId,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child:
                  (student?.profilePhotoUrl != null &&
                      student!.profilePhotoUrl!.isNotEmpty)
                  ? Image.network(
                      student.profilePhotoUrl!,
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          student?.name ?? '-',
                          style: MyStyles.boldText(
                            size: 16,
                            color: AppTheme.black_Color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (student?.className != null) ...[
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '• ${student!.className!}',
                            style: MyStyles.boldText(
                              size: 14,
                              color: AppTheme.btnColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  if (school?.name != null)
                    Text(
                      school!.name,
                      style: MyStyles.regularText(
                        size: 12,
                        color: AppTheme.graySubTitleColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 3),
                  Text(
                    '#${widget.order.id} • ${widget.order.typeLabel}',
                    style: MyStyles.regularText(
                      size: 12,
                      color: AppTheme.graySubTitleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _statusBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: _statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _statusLabel,
                              style: MyStyles.mediumText(
                                size: 11,
                                color: _statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 11,
                        color: AppTheme.graySubTitleColor,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        widget.order.orderedAt,
                        style: MyStyles.regularText(
                          size: 11,
                          color: AppTheme.graySubTitleColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _updating
                ? const Padding(
                    padding: EdgeInsets.all(4),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.btnColor,
                      ),
                    ),
                  )
                : _currentStatus == 'completed'
                ? const SizedBox.shrink()
                : PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    offset: const Offset(0, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                    onSelected: _updateStatus,
                    itemBuilder: (_) => [
                      const PopupMenuItem<String>(
                        value: 'completed',
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: AppTheme.graySubTitleColor,
                            ),
                            SizedBox(width: 10),
                            Text('Mark as Completed'),
                          ],
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    height: 60,
    width: 60,
    color: Colors.grey.shade300,
    child: const Icon(Icons.person, color: Colors.grey),
  );
}

class _DotDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '-').replaceAll('.', '-');
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
