import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
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
import 'package:idmitra/models/staff/StaffListModel.dart';
import 'package:idmitra/components/text_filed.dart';
import 'package:idmitra/providers/staff_list/staff_list_cubit.dart';
import 'package:idmitra/utils/common_widgets/app_button.dart';
import 'add_staff_form.dart';
import 'assign_classes_sheet.dart';
import 'staff_profile_page.dart';

class StaffListingPage extends StatefulWidget {
  final String schoolId;
  final bool showAppBar;
  const StaffListingPage({super.key, required this.schoolId, this.showAppBar = true});

  @override
  State<StaffListingPage> createState() => _StaffListingPageState();
}

class _StaffListingPageState extends State<StaffListingPage> {
  late final StaffListCubit _cubit;
  String? _schoolId;

  @override
  void initState() {
    super.initState();
    _cubit = StaffListCubit();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_schoolId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return BlocProvider.value(
      value: _cubit,
      child: _StaffListBody(
        schoolId: _schoolId!,
        cubit: _cubit,
        showAppBar: widget.showAppBar,
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
          editStudent: null,
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
            // Search bar
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

            // List
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
