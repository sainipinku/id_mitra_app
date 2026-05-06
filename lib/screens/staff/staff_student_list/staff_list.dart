import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/Widgets/shimmer_loader.dart';
import 'package:idmitra/api_mamanger/UserLocal.dart';
import 'package:idmitra/api_mamanger/api_manager.dart';
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/api_mamanger/secure_storage.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/components/text_filed.dart';
import 'package:idmitra/models/correction/CorrectionListModel.dart';
import 'package:idmitra/models/orders/OrderModel.dart';
import 'package:idmitra/models/staff/StaffDetailModel.dart';
import 'package:idmitra/models/staff/StaffListModel.dart';
import 'package:idmitra/models/students/StudentsListModel.dart';
import 'package:idmitra/providers/add_student/add_student_cubit.dart';
import 'package:idmitra/providers/correction/correction_cubit.dart';
import 'package:idmitra/providers/correction/correction_state.dart';
import 'package:idmitra/providers/orders/orders_cubit.dart';
import 'package:idmitra/providers/staff_correction/staff_correction_cubit.dart';
import 'package:idmitra/providers/staff_correction/staff_correction_state.dart';
import 'package:idmitra/providers/staff_list/staff_list_cubit.dart';
import 'package:idmitra/providers/student_form/student_form_cubit.dart';
import 'package:idmitra/providers/student_form/student_form_data_cubit.dart';
import 'package:idmitra/screens/orders/order_staff_page.dart';
import 'package:idmitra/screens/staff/staff_add_student_form/staff_add_student_form.dart';
import 'package:idmitra/screens/staff/staff_add_student_form/staff_add_student_form.dart';
import 'package:idmitra/screens/staff/staff_order_page/staff_order_detail_page.dart';
import 'package:idmitra/utils/common_widgets/app_button.dart';
import 'package:idmitra/Widgets/svg_file.dart';
import 'package:idmitra/screens/home/FilterBottomSheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_staff_form.dart';
import 'assign_classes_sheet.dart';
import 'staff_profile_page.dart';

  class StaffListingPage extends StatefulWidget {
  final String schoolId;
  final bool showAppBar;
  final bool isSchool;
  const StaffListingPage({
    super.key,
    required this.schoolId,
    this.showAppBar = true,
    this.isSchool = false,
  });

  @override
  State<StaffListingPage> createState() => _StaffListingPageState();
}

class _StaffListingPageState extends State<StaffListingPage>
    with SingleTickerProviderStateMixin {
  late final StaffListCubit _cubit;
  late final StaffCorrectionCubit _correctionCubit;
  late final TabController _tabController;
  String? _schoolId;

  @override
  void initState() {
    super.initState();
    _cubit = StaffListCubit();
    _correctionCubit = StaffCorrectionCubit();
    _tabController = TabController(length: 3, vsync: this);
    _loadSchoolAndFetch();
  }

  Future<void> _loadSchoolAndFetch() async {
    String id = widget.schoolId;
    if (id.isEmpty) {
      final school = await UserLocal.getSchool();
      id = school['schoolId'] ?? '';
    }
    if (mounted) {
      setState(() => _schoolId = id);
      if (id.isNotEmpty) {
        _cubit.fetchStaff(schoolId: id);
        _correctionCubit.fetchStaffCorrection(schoolId: id);
      }
    }
  }

  @override
  void dispose() {
    _cubit.close();
    _correctionCubit.close();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_schoolId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final tabBar = TabBar(
      controller: _tabController,
      labelColor: AppTheme.btnColor,
      unselectedLabelColor: AppTheme.graySubTitleColor,
      indicatorColor: AppTheme.btnColor,
      indicatorWeight: 2.5,
      labelStyle: MyStyles.mediumText(size: 13,color: Colors.white),
      unselectedLabelStyle: MyStyles.regularText(size: 13,color: Colors.white),
      tabs: const [
        Tab(text: 'Staff List'),
        Tab(text: 'Correction List'),
        Tab(text: 'Staff Orders'),
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _correctionCubit),
      ],
      child: Scaffold(
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
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
                    ),
                  ),
                ),
              ),
              centerTitle: true,
              title: Text('Staff Listings', style: MyStyles.boldText(size: 20, color: Colors.black)),
              bottom: tabBar,
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(kTextTabBarHeight),
              child: Material(color: Colors.white, child: tabBar),
            ),
      body: Column(
        children: [
          _StaffTabCountBanner(tabController: _tabController),
          Expanded(
            child: TabBarView(
        controller: _tabController,
        children: [
          BlocProvider.value(
            value: _cubit,
            child: _StaffListBody(
              schoolId: _schoolId!,
              cubit: _cubit,
              showAppBar: false,
            ),
          ),
          BlocProvider.value(
            value: _correctionCubit,
            child: _StaffCorrectionTab(schoolId: _schoolId!, isSchool: widget.isSchool),
          ),
          // Tab 3: Staff Orders
          _StaffOrdersTab(schoolId: _schoolId!, isSchool: widget.isSchool),
        ],
            ),
          ),
        ],
      ),
    ), // Scaffold
    ); // MultiBlocProvider
  }
}

class _StaffListBody extends StatefulWidget {
  final String schoolId;
  final StaffListCubit cubit;
  final bool showAppBar;
  const _StaffListBody({required this.schoolId, required this.cubit, this.showAppBar = true});

  @override
  State<_StaffListBody> createState() => _StaffListBodyState();
}

class _StaffListBodyState extends State<_StaffListBody> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  Timer? _debounce;

  String get _schoolId => widget.schoolId;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      widget.cubit.fetchStaff(
        schoolId: _schoolId,
        search: _searchCtrl.text.trim(),
        isLoadMore: true,
      );
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    await widget.cubit.fetchStaff(
      schoolId: _schoolId,
      search: _searchCtrl.text.trim(),
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.cubit.fetchStaff(schoolId: _schoolId, search: value.trim());
    });
  }

  void _navigateToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddStaffFormPage(
          editStaff: null,
          schoolId: _schoolId,
        ),
      ),
    );

    if (result == true && mounted) {
      widget.cubit.fetchStaff(
        schoolId: _schoolId,
        search: _searchCtrl.text.trim(),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.appBackgroundColor,
      appBar: widget.showAppBar
          ? CommonAppBar(
              title: 'Staff Listings',
              backgroundColor: Colors.white,
              showText: true,
            )
          : null,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.btnColor,
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: TextField(
                controller: _searchCtrl,
                style: MyStyles.regularText(size: 14, color: AppTheme.black_Color),
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.whiteColor,
                  contentPadding: const EdgeInsets.all(12),
                  hintText: 'Search staff...',
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
              ),
            ),
            Expanded(
              child: BlocBuilder<StaffListCubit, StaffListState>(
                builder: (context, state) {
                  if (state.loading) {
                    return const ShimmerList(expanded: false, itemCount: 6);
                  }

                  if (state.error != null && state.list.isEmpty) {
                    final isPermissionError = state.error!.toLowerCase().contains('permission') ||
                        state.error!.toLowerCase().contains('denied') ||
                        state.error!.toLowerCase().contains('unauthorized') ||
                        state.error!.toLowerCase().contains('forbidden');
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPermissionError ? Icons.lock_outline : Icons.error_outline,
                                    size: 56,
                                    color: isPermissionError ? Colors.orange.shade400 : Colors.red.shade300,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    state.error!,
                                    style: MyStyles.regularText(size: 14, color: AppTheme.black_Color),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (!isPermissionError) ...[
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: _refresh,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  if (state.list.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Image.asset('assets/images/no_data.png', height: 200),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    controller: _scrollCtrl,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: state.list.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i < state.list.length) {
                        return _StaffCard(staff: state.list[i], schoolId: _schoolId, cubit: widget.cubit);
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
        ],
      ),
    );
  }
}

class _StaffCountRow extends StatelessWidget {
  final int total;
  final String label;
  const _StaffCountRow({required this.total, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.btnColor.withOpacity(0.08),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        '$label: $total',
        style: MyStyles.mediumText(size: 13, color: AppTheme.btnColor),
      ),
    );
  }
}

class _StaffCard extends StatefulWidget {
  final StaffListModel staff;
  final String schoolId;
  final StaffListCubit cubit;
  const _StaffCard({required this.staff, required this.schoolId, required this.cubit});

  @override
  State<_StaffCard> createState() => _StaffCardState();
}

class _StaffCardState extends State<_StaffCard> {
  late StaffListModel staff;
  String? _uploadedPhotoUrl;

  @override
  void initState() {
    super.initState();
    staff = widget.staff;
  }

  @override
  void didUpdateWidget(covariant _StaffCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_uploadedPhotoUrl != null) {
      staff = StaffListModel(
        id: widget.staff.id,
        uuid: widget.staff.uuid,
        name: widget.staff.name,
        designation: widget.staff.designation,
        department: widget.staff.department,
        email: widget.staff.email,
        phone: widget.staff.phone,
        whatsappPhone: widget.staff.whatsappPhone,
        address: widget.staff.address,
        profilePhotoUrl: _uploadedPhotoUrl,
        roleName: widget.staff.roleName,
        roleId: widget.staff.roleId,
        status: widget.staff.status,
        assignedClasses: widget.staff.assignedClasses,
        dob: widget.staff.dob,
        fatherName: widget.staff.fatherName,
        motherName: widget.staff.motherName,
        husbandName: widget.staff.husbandName,
        gender: widget.staff.gender,
        bloodGroup: widget.staff.bloodGroup,
        pincode: widget.staff.pincode,
        employeeId: widget.staff.employeeId,
        nationalCode: widget.staff.nationalCode,
        loginId: widget.staff.loginId,
        dateOfJoining: widget.staff.dateOfJoining,
      );
    } else {
      staff = widget.staff;
    }
  }

  File? _photoFile;
  bool _isUploading = false;

  Future<void> _fromCamera() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) await _uploadPhoto(picked.path);
  }

  Future<void> _fromGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _photoFile = File(picked.path);
      await _cropAndUpload();
    }
  }

  Future<void> _cropAndUpload() async {
    if (_photoFile == null) return;
    final cropped = await ImageCropper().cropImage(
      sourcePath: _photoFile!.path,
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
    if (cropped != null) await _uploadPhoto(cropped.path);
  }

  Future<void> _uploadPhoto(String path) async {
    setState(() => _isUploading = true);
    try {
      final token = await UserSecureStorage.fetchToken();
      final url = Config.baseUrl + Routes.uploadStaffPhoto(schoolId, staff.uuid);
      print('uploadStaffPhoto URL: $url');
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.files.add(await http.MultipartFile.fromPath('photo', path));
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      print('uploadStaffPhoto status: ${response.statusCode}');
      print('uploadStaffPhoto body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        String? newUrl = jsonData['data']?['profile_photo_url'] as String?;
        if (newUrl != null) {
          final regex = RegExp(r'https?://');
          final matches = regex.allMatches(newUrl).toList();
          if (matches.length > 1) newUrl = newUrl.substring(matches.last.start);
          newUrl = newUrl
              .replaceAll('http://127.0.0.1:8000', 'https://idmitra.com')
              .replaceAll('http://localhost:8000', 'https://idmitra.com')
              .replaceAll('http://localhost', 'https://idmitra.com');
        }
        if (newUrl != null && mounted) {
          setState(() {
            _uploadedPhotoUrl = newUrl;
            staff = StaffListModel(
              id: staff.id,
              uuid: staff.uuid,
              name: staff.name,
              designation: staff.designation,
              department: staff.department,
              email: staff.email,
              phone: staff.phone,
              whatsappPhone: staff.whatsappPhone,
              address: staff.address,
              profilePhotoUrl: newUrl,
              roleName: staff.roleName,
              roleId: staff.roleId,
              status: staff.status,
              assignedClasses: staff.assignedClasses,
              dob: staff.dob,
              fatherName: staff.fatherName,
              motherName: staff.motherName,
              husbandName: staff.husbandName,
              gender: staff.gender,
              bloodGroup: staff.bloodGroup,
              pincode: staff.pincode,
              employeeId: staff.employeeId,
              nationalCode: staff.nationalCode,
              loginId: staff.loginId,
              dateOfJoining: staff.dateOfJoining,
            );
          });
          cubit.updateStaffPhoto(staff.uuid, newUrl!);
        }
      }
    } catch (e) {
      debugPrint('uploadPhoto error: $e');
    }
    if (mounted) setState(() => _isUploading = false);
  }

  void _showPhotoPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose Image',
                style: MyStyles.boldText(size: 14, color: Colors.black)),
            const SizedBox(height: 15),
            _pickerItem(
              icon: 'assets/icons/camera_single.svg',
              title: 'Camera',
              onTap: () {
                Navigator.pop(sheetCtx);
                Future.delayed(const Duration(milliseconds: 300), _fromCamera);
              },
            ),
            _divider(),
            _pickerItem(
              icon: 'assets/icons/choose_from_gallery.svg',
              title: 'Gallery',
              onTap: () {
                Navigator.pop(sheetCtx);
                Future.delayed(const Duration(milliseconds: 300), _fromGallery);
              },
            ),
          ],
        ),
      ),

    );
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
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
                          return const SizedBox(
                            height: 300,
                            child: Center(child: CircularProgressIndicator()),
                          );
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
                        _showPhotoPicker(context);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit Profile Image"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String get schoolId => widget.schoolId;
  StaffListCubit get cubit => widget.cubit;

  @override
  Widget build(BuildContext context) {
    final initials = staff.name.trim().isNotEmpty
        ? staff.name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';

    final hasPhoto = staff.profilePhotoUrl != null && staff.profilePhotoUrl!.isNotEmpty;

    return GestureDetector(
      onTap: () async {
        final editStaff = StaffDetailModel(
          id: staff.id,
          uuid: staff.uuid,
          name: staff.name,
          designation: staff.designation,
          department: staff.department,
          email: staff.email,
          phone: staff.phone,
          whatsappPhone: staff.whatsappPhone,
          address: staff.address,
          profilePhotoUrl: staff.profilePhotoUrl ?? '',
          roleName: staff.roleName,
          roleId: staff.roleId,
          status: staff.status,
          emergencyContacts: [],
          dob: staff.dob,
          fatherName: staff.fatherName,
          motherName: staff.motherName,
          husbandName: staff.husbandName,
          gender: staff.gender,
          bloodGroup: staff.bloodGroup,
          pincode: staff.pincode,
          employeeId: staff.employeeId,
          nationalCode: staff.nationalCode,
          loginId: staff.loginId,
          dateOfJoining: staff.dateOfJoining,
        );
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddStaffFormPage(editStaff: editStaff, schoolId: schoolId),
          ),
        );
        if ((result == true || result is StaffDetailModel) && mounted) {
          widget.cubit.fetchStaff(schoolId: schoolId);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (staff.profilePhotoUrl != null &&
                        staff.profilePhotoUrl!.isNotEmpty) {
                      _showImagePreview(context, staff.profilePhotoUrl!);
                    } else {
                      Future.delayed(Duration.zero, _fromCamera);
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: _isUploading
                        ? const SizedBox(
                            height: 60,
                            width: 60,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : (staff.profilePhotoUrl != null &&
                                staff.profilePhotoUrl!.isNotEmpty)
                            ? Image.network(
                                staff.profilePhotoUrl!,
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _placeholder(initials),
                              )
                            : _placeholder(initials),
                  ),
                ),
                // 📸 Edit icon
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () {
                      if (staff.profilePhotoUrl != null &&
                          staff.profilePhotoUrl!.isNotEmpty) {
                        _showImagePreview(context, staff.profilePhotoUrl!);
                      } else {
                        Future.delayed(Duration.zero, _fromCamera);
                      }
                    },
                    child: Container(
                      height: 22,
                      width: 22,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        (staff.profilePhotoUrl != null && staff.profilePhotoUrl!.isNotEmpty)
                            ? Icons.preview
                            : Icons.camera_alt,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
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
                          staff.name,
                          style: MyStyles.boldText(size: 16, color: AppTheme.black_Color),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (staff.department.isNotEmpty) ...[
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '• ${staff.department}',
                            style: MyStyles.boldText(size: 14, color: AppTheme.btnColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  if ([staff.designation, staff.roleName].any((s) => s.isNotEmpty))
                    Text(
                      [staff.designation, staff.roleName]
                          .where((s) => s.isNotEmpty)
                          .join(' • '),
                      style: MyStyles.regularText(size: 12, color: AppTheme.graySubTitleColor),
                    ),
                  const SizedBox(height: 3),
                  if (staff.phone.isNotEmpty)
                    Text(
                      'Phone: ${staff.phone}',
                      style: MyStyles.regularText(size: 12, color: AppTheme.graySubTitleColor),
                    ),
                ],
              ),
            ),

            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onSelected: (value) async {
                if (value == 'delete') {
                  _confirmDelete(context);
                } else if (value == 'change_password') {
                  _showChangePasswordDialog(context);
                } else if (value == 'assign_classes') {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => AssignClassesSheet(
                      schoolId: schoolId,
                      staffUuid: staff.uuid,
                      staffName: staff.name,
                      cubit: cubit,
                    ),
                  );
                } else if (value == 'upload_signature') {
                  _showSignaturePicker(context);
                } else if (value == 'toggle') {
                  final success = await cubit.toggleStaffStatus(
                    schoolId: schoolId,
                    uuid: staff.uuid,
                    currentStatus: staff.status,
                  );
                  if (success) {
                    final updated = cubit.state.list.firstWhere(
                      (s) => s.uuid == staff.uuid,
                      orElse: () => staff,
                    );
                    setState(() => staff = updated);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Status updated' : 'Failed to update status'),
                        backgroundColor: success ? Colors.green : Colors.red,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        staff.status == 1 ? Icons.toggle_on : Icons.toggle_off,
                        size: 22,
                        color: staff.status == 1 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(staff.status == 1 ? 'Deactivate' : 'Activate'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'assign_classes',
                  child: Row(children: [
                    Icon(Icons.class_outlined, size: 16, color: Colors.purple),
                    SizedBox(width: 8),
                    Text('Assign Classes'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'upload_signature',
                  child: Row(children: [
                    Icon(Icons.draw_outlined, size: 16, color: Colors.teal),
                    SizedBox(width: 8),
                    Text('Upload Signature'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'change_password',
                  child: Row(children: [
                    Icon(Icons.lock_outline, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Change Password'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 50,
                      color: Colors.red.shade400,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Are you sure you want to\ndelete this staff?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      title: "Yes, I'm sure",
                      color: Colors.red,
                      onTap: () async {
                        Navigator.pop(context);
                        final success = await cubit.deleteStaff(
                          schoolId: schoolId,
                          uuid: staff.uuid,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? 'Staff deleted successfully'
                                  : 'Failed to delete staff'),
                              backgroundColor: success ? Colors.green : Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      title: 'No, cancel',
                      color: Colors.grey.shade300,
                      onTap: () => Navigator.pop(context),
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

  void _showChangePasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscurePassword = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 50,
                    color: Colors.blue.shade400,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Change Password',
                  style: MyStyles.boldText(size: 16, color: AppTheme.black_Color),
                ),
                const SizedBox(height: 4),
                Text(
                  staff.name,
                  textAlign: TextAlign.center,
                  style: MyStyles.regularText(size: 13, color: AppTheme.graySubTitleColor),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('New Password', style: MyStyles.mediumText(size: 13, color: AppTheme.black_Color)),
                ),
                const SizedBox(height: 6),
                AppTextField(
                  controller: passwordController,
                  hintText: '••••••••',
                  obscureText: obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.graySubTitleColor,
                    ),
                    onPressed: () => setDialogState(() => obscurePassword = !obscurePassword),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Confirm Password', style: MyStyles.mediumText(size: 13, color: AppTheme.black_Color)),
                ),
                const SizedBox(height: 6),
                AppTextField(
                  controller: confirmPasswordController,
                  hintText: '••••••••',
                  obscureText: obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.graySubTitleColor,
                    ),
                    onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        title: 'Change',
                        color: AppTheme.btnColor,
                        onTap: () async {
                          final password = passwordController.text.trim();
                          final confirm = confirmPasswordController.text.trim();

                          if (password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a password'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          if (password != confirm) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Passwords do not match'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          Navigator.pop(dialogContext);
                          final success = await cubit.changeStaffPassword(
                            schoolId: schoolId,
                            uuid: staff.uuid,
                            password: password,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? 'Password changed successfully'
                                    : 'Failed to change password'),
                                backgroundColor: success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        title: 'Cancel',
                        color: AppTheme.backBtnBgColor,
                        onTap: () => Navigator.pop(dialogContext),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSignaturePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Upload Signature',
                style: MyStyles.boldText(size: 14, color: Colors.black)),
            const SizedBox(height: 15),
            _pickerItem(
              icon: 'assets/icons/camera_single.svg',
              title: 'Camera',
              onTap: () {
                Navigator.pop(sheetCtx);
                Future.delayed(const Duration(milliseconds: 300), () async {
                  final picked = await ImagePicker()
                      .pickImage(source: ImageSource.camera);
                  if (picked != null && context.mounted) {
                    _uploadSignature(context, picked.path);
                  }
                });
              },
            ),
            _divider(),
            _pickerItem(
              icon: 'assets/icons/choose_from_gallery.svg',
              title: 'Gallery',
              onTap: () {
                Navigator.pop(sheetCtx);
                Future.delayed(const Duration(milliseconds: 300), () async {
                  final picked = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (picked != null && context.mounted) {
                    _uploadSignature(context, picked.path);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickerItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          SvgPicture.asset(icon),
          const SizedBox(width: 10),
          Text(title, style: MyStyles.regularText(size: 14, color: color)),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 1,
        color: Colors.grey.shade300,
      );

  Future<void> _uploadSignature(BuildContext context, String path) async {
    final signatureUrl = await cubit.uploadStaffSignature(
      schoolId: schoolId,
      uuid: staff.uuid,
      imagePath: path,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(signatureUrl != null
              ? 'Signature uploaded successfully'
              : 'Failed to upload signature'),
          backgroundColor: signatureUrl != null ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Widget _placeholder(String initials) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: AppTheme.btnColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          initials,
          style: MyStyles.boldText(size: 18, color: AppTheme.btnColor),
        ),
      ),
    );
  }
}


class _StaffCorrectionTab extends StatefulWidget {
  final String schoolId;
  final bool isSchool;
  const _StaffCorrectionTab({required this.schoolId, this.isSchool = false});

  @override
  State<_StaffCorrectionTab> createState() => _StaffCorrectionTabState();
}

class _StaffCorrectionTabState extends State<_StaffCorrectionTab> {
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        context.read<StaffCorrectionCubit>().fetchStaffCorrection(
          schoolId: widget.schoolId,
          isLoadMore: true,
          search: _searchCtrl.text.trim(),
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

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<StaffCorrectionCubit>().fetchStaffCorrection(
        schoolId: widget.schoolId,
        search: value.trim(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StaffCorrectionCubit, StaffCorrectionState>(
      listenWhen: (p, c) =>
          p.sendOrderSuccess != c.sendOrderSuccess ||
          p.sendOrderError != c.sendOrderError,
      listener: (context, state) {
        if (state.sendOrderSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Order created successfully!'),
            backgroundColor: AppTheme.btnColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(12),
          ));
        }
        if (state.sendOrderError != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.sendOrderError!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(12),
          ));
        }
      },
      child: Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            style: MyStyles.regularText(size: 14, color: AppTheme.black_Color),
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.whiteColor,
              contentPadding: const EdgeInsets.all(12),
              hintText: 'Search staff...',
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
          ),
        ),
        // List
        Expanded(
          child: BlocBuilder<StaffCorrectionCubit, StaffCorrectionState>(
            builder: (context, state) {
              if (state.loading && state.items.isEmpty) {
                return const ShimmerList(expanded: false, itemCount: 6);
              }

              if (state.error != null && state.items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                        const SizedBox(height: 12),
                        Text(
                          state.error!,
                          style: MyStyles.regularText(size: 14, color: AppTheme.black_Color),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.read<StaffCorrectionCubit>().fetchStaffCorrection(
                            schoolId: widget.schoolId,
                          ),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.btnColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state.items.isEmpty) {
                return RefreshIndicator(
                  color: AppTheme.btnColor,
                  onRefresh: () async => context.read<StaffCorrectionCubit>().fetchStaffCorrection(
                    schoolId: widget.schoolId,
                    search: _searchCtrl.text.trim(),
                  ),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('assets/images/no_data.png', height: 160),
                              const SizedBox(height: 12),
                              Text(
                                'No correction entries found',
                                style: MyStyles.mediumText(size: 14, color: AppTheme.graySubTitleColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppTheme.btnColor,
                onRefresh: () async => context.read<StaffCorrectionCubit>().fetchStaffCorrection(
                  schoolId: widget.schoolId,
                  search: _searchCtrl.text.trim(),
                ),
                child: Column(
                  children: [
                    if (state.selectedIds.isNotEmpty)
                      Container(
                        color: AppTheme.btnColor.withOpacity(0.08),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Text(
                              '${state.selectedIds.length} selected',
                              style: MyStyles.mediumText(size: 13, color: AppTheme.btnColor),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => context.read<StaffCorrectionCubit>().selectAll(),
                              child: Text('Select All', style: MyStyles.mediumText(size: 12, color: AppTheme.btnColor)),
                            ),
                            TextButton(
                              onPressed: () => context.read<StaffCorrectionCubit>().clearSelection(),
                              child: Text('Clear', style: MyStyles.mediumText(size: 12, color: Colors.grey)),
                            ),
                            const SizedBox(width: 4),
                            state.sendOrderLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.btnColor))
                                : GestureDetector(
                                    onTap: () => _showCreateOrderDialog(context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                      decoration: BoxDecoration(color: AppTheme.btnColor, borderRadius: BorderRadius.circular(20)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.send_rounded, size: 13, color: Colors.white),
                                          const SizedBox(width: 5),
                                          Text('Create Order', style: MyStyles.mediumText(size: 12, color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollCtrl,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: state.items.length + (state.hasMore ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i < state.items.length) {
                            final item = state.items[i];
                            final isSelected = state.selectedIds.contains(item.id);
                            return _StaffCorrectionItemCard(
                              item: item,
                              schoolId: widget.schoolId,
                              isSelected: isSelected,
                              onToggle: () => context.read<StaffCorrectionCubit>().toggleSelection(item.id),
                            );
                          }
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator(color: AppTheme.btnColor, strokeWidth: 2)),
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
      ), // Column
    ); // BlocListener
  }

  void _showCreateOrderDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: ctx.read<StaffCorrectionCubit>(),
        child: _StaffCreateOrderDialog(schoolId: widget.schoolId),
      ),
    );
  }
}

class _CorrectionItemCard extends StatelessWidget {
  final CorrectionStudentItem item;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback? onTapCard;
  const _CorrectionItemCard({
    required this.item,
    required this.isSelected,
    required this.onToggle,
    this.onTapCard,
  });

  @override
  Widget build(BuildContext context) {
    final s = item.student;
    final className = s?.studentClass?.nameWithPrefix ?? '';
    final sectionName = s?.section?.name ?? '';
    final photoUrl = s?.photoUrl ?? s?.photo ?? '';
    final fatherPhone = s?.fatherPhone ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.btnColor.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isSelected ? AppTheme.btnColor : Colors.transparent, width: 1.5),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: SizedBox(
                width: 24, height: 24,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => onToggle(),
                  activeColor: AppTheme.btnColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  side: BorderSide(color: AppTheme.graySubTitleColor),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTapCard?.call(),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: photoUrl.isNotEmpty
                        ? Image.network(photoUrl, height: 60, width: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder())
                        : _placeholder(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(child: Text(s?.name ?? '', style: MyStyles.boldText(size: 16, color: AppTheme.black_Color), overflow: TextOverflow.ellipsis)),
                            if (className.isNotEmpty) ...[
                              const SizedBox(width: 5),
                              Flexible(child: Text('• $className${sectionName.isNotEmpty ? ' ($sectionName)' : ''}',
                                  style: MyStyles.boldText(size: 14, color: AppTheme.btnColor), overflow: TextOverflow.ellipsis)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        if (fatherPhone.isNotEmpty)
                          Row(children: [
                            const Icon(Icons.phone, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(fatherPhone, style: MyStyles.regularText(size: 12, color: AppTheme.graySubTitleColor)),
                          ]),
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
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(height: 60, width: 60, color: Colors.grey.shade200, child: const Icon(Icons.person, color: Colors.grey));
}

class _StaffCorrectionItemCard extends StatefulWidget {
  final StaffCorrectionItem item;
  final String schoolId;
  final bool isSelected;
  final VoidCallback? onToggle;
  const _StaffCorrectionItemCard({
    required this.item,
    required this.schoolId,
    this.isSelected = false,
    this.onToggle,
  });

  @override
  State<_StaffCorrectionItemCard> createState() => _StaffCorrectionItemCardState();
}

class _StaffCorrectionItemCardState extends State<_StaffCorrectionItemCard> {
  String? _uploadedPhotoUrl;
  bool _isUploading = false;
  File? _photoFile;

  Color _statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  String? get _currentPhotoUrl =>
      _uploadedPhotoUrl ?? widget.item.staff?.profilePhotoUrl;

  Future<void> _fromCamera() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) await _uploadPhoto(picked.path);
  }

  Future<void> _fromGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _photoFile = File(picked.path);
      await _cropAndUpload();
    }
  }

  Future<void> _cropAndUpload() async {
    if (_photoFile == null) return;
    final cropped = await ImageCropper().cropImage(
      sourcePath: _photoFile!.path,
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
    if (cropped != null) await _uploadPhoto(cropped.path);
  }

  Future<void> _uploadPhoto(String path) async {
    final staff = widget.item.staff;
    if (staff == null) return;
    setState(() => _isUploading = true);
    try {
      final token = await UserSecureStorage.fetchToken();
      final url = Config.baseUrl + Routes.uploadStaffPhoto(widget.schoolId, staff.uuid);
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.files.add(await http.MultipartFile.fromPath('photo', path));
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        String? newUrl = jsonData['data']?['profile_photo_url'] as String?;
        if (newUrl != null) {
          final regex = RegExp(r'https?://');
          final matches = regex.allMatches(newUrl).toList();
          if (matches.length > 1) newUrl = newUrl.substring(matches.last.start);
          newUrl = newUrl
              .replaceAll('http://127.0.0.1:8000', 'https://idmitra.com')
              .replaceAll('http://localhost:8000', 'https://idmitra.com')
              .replaceAll('http://localhost', 'https://idmitra.com');
        }
        if (newUrl != null && mounted) {
          setState(() => _uploadedPhotoUrl = newUrl);
        }
      }
    } catch (e) {
      debugPrint('correction uploadPhoto error: $e');
    }
    if (mounted) setState(() => _isUploading = false);
  }

  void _showPhotoPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose Image', style: MyStyles.boldText(size: 14, color: Colors.black)),
            const SizedBox(height: 15),
            _pickerItem(
              icon: 'assets/icons/camera_single.svg',
              title: 'Camera',
              onTap: () {
                Navigator.pop(sheetCtx);
                Future.delayed(const Duration(milliseconds: 300), _fromCamera);
              },
            ),
            Container(margin: const EdgeInsets.symmetric(vertical: 10), height: 1, color: Colors.grey.shade300),
            _pickerItem(
              icon: 'assets/icons/choose_from_gallery.svg',
              title: 'Gallery',
              onTap: () {
                Navigator.pop(sheetCtx);
                Future.delayed(const Duration(milliseconds: 300), _fromGallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickerItem({required String icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          SvgPicture.asset(icon),
          const SizedBox(width: 10),
          Text(title, style: MyStyles.regularText(size: 14, color: Colors.black)),
        ],
      ),
    );
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
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
                      _showPhotoPicker(context);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile Image'),
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
    final staff = widget.item.staff;
    final photoUrl = _currentPhotoUrl;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    final initials = (staff?.name ?? '').trim().isNotEmpty
        ? staff!.name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';

    return GestureDetector(
      onTap: () {
        if (staff == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StaffProfilePage(staff: staff, schoolId: widget.schoolId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.isSelected ? AppTheme.btnColor.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isSelected ? AppTheme.btnColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: widget.onToggle,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: widget.isSelected,
                    onChanged: (_) => widget.onToggle?.call(),
                    activeColor: AppTheme.btnColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    side: BorderSide(color: AppTheme.graySubTitleColor),
                  ),
                ),
              ),
            ),
            // Profile photo with tap + edit icon
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (hasPhoto) {
                      _showImagePreview(context, photoUrl!);
                    } else {
                      Future.delayed(Duration.zero, _fromCamera);
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: _isUploading
                        ? const SizedBox(
                            height: 60,
                            width: 60,
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : hasPhoto
                            ? Image.network(
                                photoUrl!,
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _placeholder(initials),
                              )
                            : _placeholder(initials),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () {
                      if (hasPhoto) {
                        _showImagePreview(context, photoUrl!);
                      } else {
                        Future.delayed(Duration.zero, _fromCamera);
                      }
                    },
                    child: Container(
                      height: 22,
                      width: 22,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        hasPhoto ? Icons.preview : Icons.camera_alt,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
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
                          staff?.name ?? 'Unknown',
                          style: MyStyles.boldText(size: 15, color: AppTheme.black_Color),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if ((staff?.department ?? '').isNotEmpty) ...[
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '• ${staff!.department}',
                            style: MyStyles.boldText(size: 13, color: AppTheme.btnColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  if ([staff?.designation ?? '', staff?.roleName ?? ''].any((s) => s.isNotEmpty))
                    Text(
                      [staff?.designation ?? '', staff?.roleName ?? '']
                          .where((s) => s.isNotEmpty)
                          .join(' • '),
                      style: MyStyles.regularText(size: 12, color: AppTheme.graySubTitleColor),
                    ),
                  if ((staff?.phone ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Phone: ${staff!.phone}',
                      style: MyStyles.regularText(size: 12, color: AppTheme.graySubTitleColor),
                    ),
                  ],
                  if ((widget.item.remark ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Remark: ${widget.item.remark}',
                      style: MyStyles.regularText(size: 11, color: AppTheme.graySubTitleColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(widget.item.status).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                (widget.item.status ?? 'N/A').toUpperCase(),
                style: MyStyles.mediumText(size: 10, color: _statusColor(widget.item.status)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(String initials) => Container(
    height: 60,
    width: 60,
    color: AppTheme.btnColor.withOpacity(0.12),
    child: Center(
      child: Text(initials, style: MyStyles.boldText(size: 18, color: AppTheme.btnColor)),
    ),
  );
}

class _DownloadChecklistDialog extends StatefulWidget {
  final String schoolId;
  const _DownloadChecklistDialog({required this.schoolId});

  @override
  State<_DownloadChecklistDialog> createState() => _DownloadChecklistDialogState();
}

class _DownloadChecklistDialogState extends State<_DownloadChecklistDialog> {
  Set<String> _selectedColumns = {};
  String _printType = '';

  @override
  void initState() {
    super.initState();
    context.read<CorrectionCubit>().fetchDownloadColumns(schoolId: widget.schoolId);
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
        if (!state.columnsLoading && state.downloadColumns.isNotEmpty && _selectedColumns.isEmpty) {
          setState(() {
            _selectedColumns = state.downloadColumns.map((c) => c.key).toSet();
          });
        }
        if (!state.downloadLoading && state.downloadUrl != null && state.downloadUrl!.isNotEmpty) {
          Navigator.of(context).pop();
          final uri = Uri.tryParse(state.downloadUrl!);
          if (uri != null) {
            try { await launchUrl(uri, mode: LaunchMode.externalApplication); } catch (_) {}
          }
        }
        if (!state.downloadLoading && state.downloadError != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.downloadError!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(12),
          ));
        }
      },
      builder: (context, state) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Download Checklist', style: MyStyles.boldText(size: 16, color: AppTheme.black_Color)),
                const SizedBox(height: 16),
                if (state.columnsLoading)
                  const Center(child: CircularProgressIndicator(color: AppTheme.btnColor))
                else if (state.downloadColumns.isEmpty)
                  Text('No columns available', style: MyStyles.regularText(size: 13, color: AppTheme.graySubTitleColor))
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: state.downloadColumns.map((col) {
                          final selected = _selectedColumns.contains(col.key);
                          return FilterChip(
                            label: Text(col.label, style: MyStyles.regularText(size: 12, color: selected ? Colors.white : AppTheme.black_Color)),
                            selected: selected,
                            onSelected: (_) => _toggleColumn(col.key),
                            selectedColor: AppTheme.btnColor,
                            backgroundColor: Colors.grey.shade100,
                            checkmarkColor: Colors.white,
                            side: BorderSide.none,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: state.downloadLoading || _selectedColumns.isEmpty
                            ? null
                            : () => context.read<CorrectionCubit>().downloadCorrectionList(
                                  schoolId: widget.schoolId,
                                  columns: _selectedColumns.toList(),
                                  printType: _printType,
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.btnColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: state.downloadLoading
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Download'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class _StaffOrdersTab extends StatefulWidget {
  final String schoolId;
  final bool isSchool;
  const _StaffOrdersTab({required this.schoolId, this.isSchool = false});

  @override
  State<_StaffOrdersTab> createState() => _StaffOrdersTabState();
}

class _StaffOrdersTabState extends State<_StaffOrdersTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _dateFromCtrl = TextEditingController();
  final TextEditingController _dateToCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  Timer? _debounce;

  List<OrderStaffItem> _orders = [];
  bool _loading = false;
  bool _hasMore = true;
  int _page = 1;
  int _total = 0;
  String? _error;
  String _selectedStatus = '';

  bool get _hasActiveFilters =>
      _selectedStatus.isNotEmpty ||
      _dateFromCtrl.text.isNotEmpty ||
      _dateToCtrl.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        _fetch();
      }
    });
    _fetch(reset: true);
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
    setState(() { _orders = []; _page = 1; _hasMore = true; _error = null; _loading = false; });
    _fetch(reset: true);
  }

  void _clearFilters() {
    setState(() { _selectedStatus = ''; _dateFromCtrl.clear(); _dateToCtrl.clear(); });
    _resetAndFetch();
  }

  Future<void> _fetch({bool reset = false}) async {
    if (!reset && (_loading || !_hasMore)) return;
    setState(() { _loading = true; _error = null; });
    try {
      final currentPage = reset ? 1 : _page;
      // Both partner and school use the same school endpoint for staff orders
      String url = '${Config.baseUrl}auth/school/${widget.schoolId}/staff/orders?page=$currentPage';
      if (_selectedStatus.isNotEmpty) url += '&status=$_selectedStatus';
      if (_searchCtrl.text.trim().isNotEmpty) url += '&search=${_searchCtrl.text.trim()}';
      if (_dateFromCtrl.text.isNotEmpty) url += '&start_date=${_dateFromCtrl.text}';
      if (_dateToCtrl.text.isNotEmpty) url += '&end_date=${_dateToCtrl.text}';

      var response = await ApiManager().getRequest(url);

      if (response == null) {
        setState(() { _loading = false; _error = 'Failed to load staff orders'; });
        return;
      }

      final json = jsonDecode(response.body);
      final isSuccess = (json['status'] == true || json['success'] == true);
      if (!isSuccess) {
        setState(() { _loading = false; _error = json['message'] ?? 'Failed to load staff orders'; });
        return;
      }

      final data = json['data'] as Map<String, dynamic>?;
      if (data == null) {
        setState(() { _loading = false; _error = 'Invalid response format'; });
        return;
      }

      List rawList = [];
      int total = 0, lastPage = 1, respPage = 1;

      if (data.containsKey('list') && data['list'] is Map) {
        final listData = data['list'] as Map<String, dynamic>;
        rawList = listData['data'] ?? [];
        total = listData['total'] ?? 0;
        lastPage = listData['last_page'] ?? 1;
        respPage = listData['current_page'] ?? 1;
      } else if (data.containsKey('orders')) {
        final ordersData = data['orders'];
        if (ordersData is List) {
          rawList = ordersData;
          total = rawList.length;
        } else if (ordersData is Map) {
          rawList = ordersData['data'] ?? [];
          total = ordersData['total'] ?? 0;
          lastPage = ordersData['last_page'] ?? 1;
          respPage = ordersData['current_page'] ?? 1;
        }
      } else if (data.containsKey('data') && data['data'] is List) {
        rawList = data['data'] as List;
        total = data['total'] ?? rawList.length;
        lastPage = data['last_page'] ?? 1;
        respPage = data['current_page'] ?? 1;
      }

      final newOrders = rawList.map((e) => OrderStaffItem.fromJson(e as Map<String, dynamic>)).toList();
      setState(() {
        _loading = false;
        _total = total;
        _page = respPage + 1;
        _hasMore = respPage < lastPage;
        _orders = reset ? newOrders : [..._orders, ...newOrders];
      });
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StaffCountRow(total: _total, label: 'Total Orders'),
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
              _statusDropdown(),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppTheme.lightRedColor, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.close, size: 12, color: AppTheme.cancelTextColor),
                          const SizedBox(width: 4),
                          Text('Clear Filters', style: MyStyles.mediumText(size: 11, color: AppTheme.cancelTextColor)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (!_loading && _total > 0)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.btnColor.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.badge_outlined, size: 14, color: AppTheme.btnColor),
                  const SizedBox(width: 6),
                  Text('Total: $_total', style: MyStyles.mediumText(size: 12, color: AppTheme.btnColor)),
                ],
              ),
            ),
          ),
        Expanded(
          child: _error != null && _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                      const SizedBox(height: 12),
                      Text(_error!, style: MyStyles.regularText(size: 14, color: Colors.red), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _resetAndFetch,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.btnColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                )
              : _orders.isEmpty && !_loading
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/images/no_data.png', height: 160),
                          const SizedBox(height: 12),
                          Text('No staff orders found',
                              style: MyStyles.mediumText(size: 14, color: AppTheme.graySubTitleColor)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: AppTheme.btnColor,
                      onRefresh: () async => _resetAndFetch(),
                      child: ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                        itemCount: _orders.length + (_hasMore ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i < _orders.length) {
                            return _StaffOrderItemCard(order: _orders[i], schoolId: widget.schoolId);
                          }
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator(color: AppTheme.btnColor, strokeWidth: 2)),
                          );
                        },
                      ),
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
      hintText: 'Search staff orders...',
      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppTheme.graySubTitleColor),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.backBtnBgColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppTheme.btnColor),
        borderRadius: BorderRadius.circular(12),
      ),
      hintStyle: MyStyles.regularText(size: 13, color: AppTheme.graySubTitleColor),
    ),
  );

  Widget _statusDropdown() => Container(
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: AppTheme.appBackgroundColor,
      border: Border.all(color: AppTheme.backBtnBgColor.withOpacity(0.5)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedStatus,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppTheme.graySubTitleColor),
        style: MyStyles.regularText(size: 13, color: AppTheme.black_Color),
        items: kOrderFilterStatuses
            .map((s) => DropdownMenuItem<String>(value: s.value, child: Text(s.label, overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: (v) { setState(() => _selectedStatus = v ?? ''); _resetAndFetch(); },
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
          _StaffListDotDateFormatter(),
        ],
        suffixIcon: ctrl.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  ctrl.clear(); setLocal(() {});
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 200), _resetAndFetch);
                },
                child: const Icon(Icons.close, size: 16),
              )
            : null,
        onChanged: (_) {
          setLocal(() {});
          if (ctrl.text.length == 10 || ctrl.text.isEmpty) {
            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 400), _resetAndFetch);
          }
        },
      ),
    );
  }
}

class _StaffOrderItemCard extends StatefulWidget {
  final OrderStaffItem order;
  final String schoolId;
  const _StaffOrderItemCard({required this.order, required this.schoolId});

  @override
  State<_StaffOrderItemCard> createState() => _StaffOrderItemCardState();
}

class _StaffOrderItemCardState extends State<_StaffOrderItemCard> {
  late String _currentStatus;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
  }

  Color get _statusColor {
    switch (_currentStatus) {
      case 'completed': return const Color(0xFF2DC24E);
      case 'cancelled': return AppTheme.cancelTextColor;
      case 'work_in_process': return AppTheme.btnColor;
      case 're_order': return AppTheme.PendingDotColor;
      default: return AppTheme.graySubTitleColor;
    }
  }

  Color get _statusBg {
    switch (_currentStatus) {
      case 'completed': return const Color(0xFFE8F9ED);
      case 'cancelled': return AppTheme.lightRedColor;
      case 'work_in_process': return AppTheme.lightBlueColor;
      case 're_order': return AppTheme.PendingLightColor;
      default: return AppTheme.appBackgroundColor;
    }
  }

  String get _statusLabel => kOrderStatuses
      .firstWhere(
        (s) => s.value == _currentStatus,
        orElse: () => OrderStatusOption(_currentStatus, _currentStatus.replaceAll('_', ' ')),
      )
      .label;

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _updating = true);
    try {
      final api = ApiManager();
      final url = '${Config.baseUrl}auth/partner/orders/${widget.order.uuid}/status';
      final response = await api.patchRequestWithBody(url, {'status': newStatus});
      if (!mounted) return;
      bool success = false;
      if (response != null) {
        final json = jsonDecode(response.body);
        success = json['success'] == true;
      }
      setState(() {
        _updating = false;
        if (success) _currentStatus = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Status updated successfully' : 'Failed to update status'),
        backgroundColor: success ? AppTheme.btnColor : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ));
    } catch (_) {
      if (!mounted) return;
      setState(() => _updating = false);
    }
  }

  List<PopupMenuEntry<String>> _buildStatusMenuItems() {
    return kOrderStatuses
        .where((s) => s.value != _currentStatus)
        .map((s) => PopupMenuItem<String>(
              value: s.value,
              child: Row(
                children: [
                  Icon(_statusIcon(s.value), size: 16, color: AppTheme.graySubTitleColor),
                  const SizedBox(width: 10),
                  Text(s.label),
                ],
              ),
            ))
        .toList();
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'completed': return Icons.check_circle_outline;
      case 'cancelled': return Icons.cancel_outlined;
      case 're_order': return Icons.refresh_rounded;
      case 'work_in_process': return Icons.hourglass_top_rounded;
      case 'order_created': return Icons.add_circle_outline;
      default: return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StaffOrderDetailPage(uuid: widget.order.uuid, schoolId: widget.schoolId),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: (widget.order.staffPhoto != null && widget.order.staffPhoto!.isNotEmpty)
                  ? Image.network(widget.order.staffPhoto!, height: 60, width: 60, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
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
                        child: Text(widget.order.staffName ?? '-',
                            style: MyStyles.boldText(size: 16, color: AppTheme.black_Color),
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text('• ${widget.order.typeLabel}',
                            style: MyStyles.boldText(size: 14, color: AppTheme.btnColor),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  if (widget.order.schoolName != null)
                    Text(widget.order.schoolName!,
                        style: MyStyles.regularText(size: 12, color: AppTheme.graySubTitleColor),
                        overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text('#${widget.order.id}',
                      style: MyStyles.regularText(size: 12, color: AppTheme.graySubTitleColor)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: _statusBg, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 5, height: 5,
                                decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text(_statusLabel, style: MyStyles.mediumText(size: 11, color: _statusColor)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.calendar_today_outlined, size: 11, color: AppTheme.graySubTitleColor),
                      const SizedBox(width: 3),
                      Text(widget.order.orderedAt,
                          style: MyStyles.regularText(size: 11, color: AppTheme.graySubTitleColor)),
                    ],
                  ),
                ],
              ),
            ),
            _updating
                ? const Padding(
                    padding: EdgeInsets.all(4),
                    child: SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.btnColor),
                    ),
                  )
                : PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    offset: const Offset(0, 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 8,
                    onSelected: _updateStatus,
                    itemBuilder: (_) => _buildStatusMenuItems(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    height: 60, width: 60,
    color: Colors.grey.shade300,
    child: const Icon(Icons.person, color: Colors.grey),
  );
}

class _StaffTabCountBanner extends StatefulWidget {
  final TabController tabController;
  const _StaffTabCountBanner({required this.tabController});

  @override
  State<_StaffTabCountBanner> createState() => _StaffTabCountBannerState();
}

class _StaffTabCountBannerState extends State<_StaffTabCountBanner> {
  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = widget.tabController.index;

    if (index == 0) {
      return BlocBuilder<StaffListCubit, StaffListState>(
        buildWhen: (p, c) => p.total != c.total,
        builder: (_, s) => _banner('Total Staff', s.total),
      );
    }

    if (index == 1) {
      return BlocBuilder<StaffCorrectionCubit, StaffCorrectionState>(
        buildWhen: (p, c) => p.total != c.total,
        builder: (_, s) => _banner('Total Corrections', s.total),
      );
    }

    // index == 2 (Staff Orders) — uses local _total from _StaffOrdersTabState
    // We show a static banner; _StaffOrdersTab already has its own _StaffCountRow
    return const SizedBox.shrink();
  }

  Widget _banner(String label, int count) => Container(
    width: double.infinity,
    color: AppTheme.btnColor.withOpacity(0.08),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Text(
      '$label: $count',
      style: MyStyles.mediumText(size: 13, color: AppTheme.btnColor),
    ),
  );
}

class _StaffListDotDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('/', '-').replaceAll('.', '-');
    return newValue.copyWith(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}


// ── Staff Create Order Dialog ─────────────────────────────────────────────────
class _StaffCreateOrderDialog extends StatefulWidget {
  final String schoolId;
  const _StaffCreateOrderDialog({required this.schoolId});

  @override
  State<_StaffCreateOrderDialog> createState() => _StaffCreateOrderDialogState();
}

class _StaffCreateOrderDialogState extends State<_StaffCreateOrderDialog> {
  static const _cardTypes = [
    {'value': '', 'label': '-Select card Type-'},
    {'value': 'pvc_card', 'label': 'Pvc Card'},
    {'value': 'rfid_card', 'label': 'RFID Card'},
    {'value': 'pasting_card', 'label': 'Pasting card'},
    {'value': 'acrylic_card', 'label': 'Acrylic Card'},
    {'value': 'nfc_card', 'label': 'NFC Card'},
    {'value': 'my_fair_card', 'label': 'My Fair Card'},
  ];

  static const _cardForOptions = [
    {'value': 'student_card', 'label': 'Student Card'},
    {'value': 'parent_card', 'label': 'Parent Card'},
    {'value': 'admit_card', 'label': 'Admit Card'},
  ];

  String _selectedCardType = '';
  final Set<String> _selectedCardFor = {'student_card', 'parent_card'};

  void _toggleCardFor(String value) {
    setState(() {
      if (_selectedCardFor.contains(value)) {
        _selectedCardFor.remove(value);
      } else {
        _selectedCardFor.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffCorrectionCubit, StaffCorrectionState>(
      listenWhen: (p, c) =>
          p.sendOrderLoading != c.sendOrderLoading ||
          p.sendOrderSuccess != c.sendOrderSuccess ||
          p.sendOrderError != c.sendOrderError,
      listener: (ctx, state) {
        if (!state.sendOrderLoading && state.sendOrderSuccess) {
          Navigator.of(context).pop();
        }
        if (!state.sendOrderLoading && state.sendOrderError != null) {
          Navigator.of(context).pop();
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
              // Header
              Row(
                children: [
                  Text('Create Order', style: MyStyles.boldText(size: 18, color: AppTheme.black_Color)),
                  const Spacer(),
                  GestureDetector(
                    onTap: state.sendOrderLoading ? null : () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Card Type Dropdown
              Text('Create Card Order For', style: MyStyles.mediumText(size: 13, color: AppTheme.black_Color)),
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
                    value: _selectedCardType,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.graySubTitleColor),
                    style: MyStyles.regularText(size: 14, color: AppTheme.black_Color),
                    items: _cardTypes.map((t) => DropdownMenuItem<String>(
                      value: t['value']!,
                      child: Text(
                        t['label']!,
                        style: MyStyles.regularText(
                          size: 14,
                          color: t['value']!.isEmpty ? AppTheme.graySubTitleColor : AppTheme.black_Color,
                        ),
                      ),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedCardType = v ?? ''),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Card For Checkboxes
              ..._cardForOptions.map((opt) {
                final isSelected = _selectedCardFor.contains(opt['value']);
                return GestureDetector(
                  onTap: () => _toggleCardFor(opt['value']!),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.btnColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: isSelected ? AppTheme.btnColor : Colors.grey.shade400,
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Text(opt['label']!, style: MyStyles.regularText(size: 14, color: AppTheme.black_Color)),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: state.sendOrderLoading ? null : () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.refresh, size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Text('Cancel', style: MyStyles.mediumText(size: 14, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: state.sendOrderLoading
                        ? null
                        : () {
                            if (_selectedCardType.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: const Text('Please select a card type'),
                                backgroundColor: Colors.orange,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                margin: const EdgeInsets.all(12),
                              ));
                              return;
                            }
                            if (_selectedCardFor.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: const Text('Please select at least one card option'),
                                backgroundColor: Colors.orange,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                margin: const EdgeInsets.all(12),
                              ));
                              return;
                            }
                            context.read<StaffCorrectionCubit>().processOrder(
                              schoolId: widget.schoolId,
                              cardType: _selectedCardType,
                              cardFor: _selectedCardFor.toList(),
                            );
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: state.sendOrderLoading ? Colors.grey : const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: state.sendOrderLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add_circle_outline, size: 14, color: Colors.white),
                                const SizedBox(width: 6),
                                Text('Create', style: MyStyles.mediumText(size: 14, color: Colors.white)),
                              ],
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
