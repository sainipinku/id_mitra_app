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
import 'package:idmitra/models/staff/StaffListModel.dart';
import 'package:idmitra/providers/correction/correction_cubit.dart';
import 'package:idmitra/providers/correction/correction_state.dart';
import 'package:idmitra/providers/orders/orders_cubit.dart';
import 'package:idmitra/providers/staff_list/staff_list_cubit.dart';
import 'package:idmitra/screens/orders/order_staff_page.dart';
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
  late final TabController _tabController;
  String? _schoolId;

  @override
  void initState() {
    super.initState();
    _cubit = StaffListCubit();
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
      }
    }
  }

  @override
  void dispose() {
    _cubit.close();
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
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Staff List
          BlocProvider.value(
            value: _cubit,
            child: _StaffListBody(
              schoolId: _schoolId!,
              cubit: _cubit,
              showAppBar: false,
            ),
          ),
          // Tab 2: Correction List
          BlocProvider(
            create: (_) => CorrectionCubit()
              ..fetchCorrectionStudents(schoolId: _schoolId!),
            child: _StaffCorrectionTab(schoolId: _schoolId!, isSchool: widget.isSchool),
          ),
          // Tab 3: Staff Orders
          _StaffOrdersTab(schoolId: _schoolId!, isSchool: widget.isSchool),
        ],
      ),
    );
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
      body: RefreshIndicator(
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
  String? _uploadedPhotoUrl; // locally uploaded URL — survives list refresh

  @override
  void initState() {
    super.initState();
    staff = widget.staff;
  }

  @override
  void didUpdateWidget(covariant _StaffCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When list refreshes, keep our locally uploaded photo URL
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
        status: widget.staff.status,
        assignedClasses: widget.staff.assignedClasses,
      );
    } else {
      staff = widget.staff;
    }
  }

  // ── Photo upload (same as StudentCard) ────────────────────────────────────
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
        // Fix malformed/localhost URL
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
            _uploadedPhotoUrl = newUrl; // persist across list refreshes
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
              status: staff.status,
              assignedClasses: staff.assignedClasses,
            );
          });
          // Also update cubit state so list rebuild uses correct URL
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
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StaffProfilePage(staff: staff, schoolId: schoolId),
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
          children: [
            // Profile photo — same as StudentCard
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (staff.profilePhotoUrl != null &&
                        staff.profilePhotoUrl!.isNotEmpty) {
                      _showImagePreview(context, staff.profilePhotoUrl!);
                    } else {
                      _showPhotoPicker(context);
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
                        _showPhotoPicker(context);
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
    return BlocListener<CorrectionCubit, CorrectionState>(
      listenWhen: (p, c) =>
          p.sendOrderSuccess != c.sendOrderSuccess || p.sendOrderError != c.sendOrderError,
      listener: (context, state) async {
        if (state.sendOrderSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Order sent successfully!'),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _searchBar()),
                const SizedBox(width: 8),
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
                    child: svgIcon(icon: 'assets/icons/filtter.svg', clr: AppTheme.black_Color),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<CorrectionCubit, CorrectionState>(
              builder: (context, state) {
                if (state.studentsLoading && state.students.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.btnColor));
                }
                if (state.studentsError != null && state.students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                        const SizedBox(height: 12),
                        Text(state.studentsError!, style: MyStyles.regularText(size: 14, color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.read<CorrectionCubit>().fetchCorrectionStudents(schoolId: widget.schoolId),
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
                  );
                }
                if (state.students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/no_data.png', height: 160),
                        const SizedBox(height: 12),
                        Text('No students found',
                            style: MyStyles.mediumText(size: 14, color: AppTheme.graySubTitleColor)),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  color: AppTheme.btnColor,
                  onRefresh: () async => context.read<CorrectionCubit>().fetchCorrectionStudents(schoolId: widget.schoolId),
                  child: Column(
                    children: [
                      if (state.selectedStudentIds.isNotEmpty)
                        Container(
                          color: AppTheme.btnColor.withOpacity(0.08),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              Text('${state.selectedStudentIds.length} selected',
                                  style: MyStyles.mediumText(size: 13, color: AppTheme.btnColor)),
                              const Spacer(),
                              TextButton(
                                onPressed: () => context.read<CorrectionCubit>().selectAllStudents(),
                                child: Text('Select All', style: MyStyles.mediumText(size: 12, color: AppTheme.btnColor)),
                              ),
                              TextButton(
                                onPressed: () => context.read<CorrectionCubit>().clearStudentSelection(),
                                child: Text('Clear', style: MyStyles.mediumText(size: 12, color: Colors.grey)),
                              ),
                              const SizedBox(width: 4),
                              state.sendOrderLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.btnColor))
                                  : GestureDetector(
                                      onTap: () {},
                                   //   => context.read<CorrectionCubit>().processOrder(schoolId: widget.schoolId),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                        decoration: BoxDecoration(color: AppTheme.btnColor, borderRadius: BorderRadius.circular(20)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.send_rounded, size: 13, color: Colors.white),
                                            const SizedBox(width: 5),
                                            Text('Send Order', style: MyStyles.mediumText(size: 12, color: Colors.white)),
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
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                          itemCount: state.students.length + (state.studentsHasMore ? 1 : 0),
                          itemBuilder: (_, i) {
                            if (i < state.students.length) {
                              final item = state.students[i];
                              final isSelected = state.selectedStudentIds.contains(item.id);
                              return _CorrectionItemCard(
                                item: item,
                                isSelected: isSelected,
                                onToggle: () => context.read<CorrectionCubit>().toggleStudentSelection(item.id),
                              );
                            }
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator(color: AppTheme.btnColor, strokeWidth: 2,)),
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
      hintStyle: MyStyles.regularText(size: 14, color: AppTheme.graySubTitleColor),
    ),
  );
}

class _CorrectionItemCard extends StatelessWidget {
  final CorrectionStudentItem item;
  final bool isSelected;
  final VoidCallback onToggle;
  const _CorrectionItemCard({required this.item, required this.isSelected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final s = item.student;
    final className = s?.studentClass?.nameWithPrefix ?? '';
    final sectionName = s?.section?.name ?? '';
    final photoUrl = s?.photoUrl ?? s?.photo ?? '';
    final fatherPhone = s?.fatherPhone ?? '';

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.btnColor.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppTheme.btnColor : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24, height: 24,
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => onToggle(),
                activeColor: AppTheme.btnColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: BorderSide(color: AppTheme.graySubTitleColor),
              ),
            ),
            const SizedBox(width: 10),
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
    );
  }

  Widget _placeholder() => Container(height: 60, width: 60, color: Colors.grey.shade200, child: const Icon(Icons.person, color: Colors.grey));
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

class _StaffOrderItemCard extends StatelessWidget {
  final OrderStaffItem order;
  final String schoolId;
  const _StaffOrderItemCard({required this.order, required this.schoolId});

  Color get _statusColor {
    switch (order.status) {
      case 'completed': return const Color(0xFF2DC24E);
      case 'cancelled': return AppTheme.cancelTextColor;
      case 'work_in_process': return AppTheme.btnColor;
      case 're_order': return AppTheme.PendingDotColor;
      default: return AppTheme.graySubTitleColor;
    }
  }

  Color get _statusBg {
    switch (order.status) {
      case 'completed': return const Color(0xFFE8F9ED);
      case 'cancelled': return AppTheme.lightRedColor;
      case 'work_in_process': return AppTheme.lightBlueColor;
      case 're_order': return AppTheme.PendingLightColor;
      default: return AppTheme.appBackgroundColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StaffOrderDetailPage(uuid: order.uuid, schoolId: schoolId),
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
              child: (order.staffPhoto != null && order.staffPhoto!.isNotEmpty)
                  ? Image.network(order.staffPhoto!, height: 60, width: 60, fit: BoxFit.cover,
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
                        child: Text(order.staffName ?? '-',
                            style: MyStyles.boldText(size: 16, color: AppTheme.black_Color),
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text('• ${order.typeLabel}',
                            style: MyStyles.boldText(size: 14, color: AppTheme.btnColor),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  if (order.schoolName != null)
                    Text(order.schoolName!,
                        style: MyStyles.regularText(size: 12, color: AppTheme.graySubTitleColor),
                        overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text('#${order.id}',
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
                            Text(order.statusLabel, style: MyStyles.mediumText(size: 11, color: _statusColor)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.calendar_today_outlined, size: 11, color: AppTheme.graySubTitleColor),
                      const SizedBox(width: 3),
                      Text(order.orderedAt,
                          style: MyStyles.regularText(size: 11, color: AppTheme.graySubTitleColor)),
                    ],
                  ),
                ],
              ),
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

class _StaffListDotDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('/', '-').replaceAll('.', '-');
    return newValue.copyWith(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
