import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:idmitra/api_mamanger/api_manager.dart';
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/helpers/keyboard.dart';
import 'package:idmitra/models/students/StudentsListModel.dart';
import 'package:idmitra/providers/students/students_cubit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:idmitra/screens/home/student_profile_page.dart';
import 'package:idmitra/utils/common_widgets/app_button.dart';
import '../../providers/students/students_state.dart';

class StudentCard extends StatefulWidget {
  StudentDetailsData studentData;
  final String schoolId;
  final VoidCallback? onEdit;
  StudentCard({super.key, required this.studentData, required this.schoolId, this.onEdit});

  @override
  State<StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
  late StudentDetailsData studentDetailsData;
  File? studentProfileImageFile;
  CroppedFile? croppedProfileFile;
  bool isUploading = false;

  /// 📸 Camera
  Future<void> _fromCamera() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      studentProfileImageFile = File(pickedFile.path);
      _cropImage();
    }
  }

  /// 🖼 Gallery
  Future<void> _fromGallery() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      studentProfileImageFile = File(pickedFile.path);
      _cropImage();
    }
  }

  /// ✂️ Crop + Upload
  Future<void> _cropImage() async {
    if (studentProfileImageFile == null) return;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: studentProfileImageFile!.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: AppTheme.MainColor,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(title: 'Cropper', aspectRatioLockEnabled: true),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        croppedProfileFile = croppedFile;
        isUploading = true;
      });

      try {
        var response = await ApiManager().multiRequestRoute(
          croppedFile.path,
          Config.baseUrl +
              Routes.updateStudentProfile(studentDetailsData.uuid ?? ''),
        );
        print(
          'proifle---------${Config.baseUrl + Routes.updateStudentProfile(studentDetailsData.uuid ?? '')}',
        );
        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          print('proifle---------${jsonData['data']['profile_photo_url']}');
          setState(() {
            studentDetailsData = studentDetailsData.copyWith(
              profilePhotoUrl: jsonData['data']['profile_photo_url'],
            );
          });
        }
      } catch (e) {
        debugPrint("Upload error: $e");
      }

      setState(() => isUploading = false);
    }
  }

  /// 📂 Bottom Sheet
  void showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choose Image",
                style: MyStyles.boldText(size: 18, color: Colors.black),
              ),

              const SizedBox(height: 15),

              _pickerItem(
                icon: 'assets/icons/camera_single.svg',
                title: "Camera",
                onTap: () {
                  Navigator.pop(context);
                  _fromCamera();
                },
              ),

              _divider(),

              _pickerItem(
                icon: 'assets/icons/choose_from_gallery.svg',
                title: "Gallery",
                onTap: () {
                  Navigator.pop(context);
                  _fromGallery();
                },
              ),

              _divider(),

              _pickerItem(
                icon: 'assets/icons/remove_image.svg',
                title: "Remove Photo",
                color: Colors.red,
                onTap: () {
                  setState(() {
                    studentProfileImageFile = null;
                    croppedProfileFile = null;
                    studentDetailsData = studentDetailsData.copyWith(
                      profilePhotoUrl: "",
                    );
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
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

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: 1,
      color: Colors.grey.shade300,
    );
  }

  @override
  void initState() {
    studentDetailsData = widget.studentData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentProfilePage(
                student: studentDetailsData,
                schoolId: widget.schoolId,
              ),
          ),
        );
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
          /// 👤 PROFILE IMAGE
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (studentDetailsData.photo != null &&
                      studentDetailsData.photo!.isNotEmpty) {
                    _showImagePreview(
                      context,
                      studentDetailsData.profilePhotoUrl!,
                    );
                  } else {
                    showPicker(context);
                  }
                },
                child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: isUploading
                    ? const SizedBox(
                        height: 60,
                        width: 60,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : (studentDetailsData.profilePhotoUrl != null &&
                          studentDetailsData.profilePhotoUrl!.isNotEmpty)
                    ? Image.network(
                        studentDetailsData.profilePhotoUrl!,
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              ),

              /// 📸 Edit Icon
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    if (studentDetailsData.photo != null &&
                        studentDetailsData.photo!.isNotEmpty) {
                      _showImagePreview(
                        context,
                        studentDetailsData.profilePhotoUrl!,
                      );
                    } else {
                      showPicker(context);
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
                      studentDetailsData.photo != null
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
                        studentDetailsData.name ?? '',
                        style: MyStyles.boldText(
                          size: 16,
                          color: AppTheme.black_Color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        "• ${studentDetailsData.datumClass?.nameWithprefix ?? ''}-${studentDetailsData.section?.name ?? ''}",
                        style: MyStyles.boldText(
                          size: 16,
                          color: AppTheme.btnColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  "Father name : ${studentDetailsData.fatherName ?? ''}",
                  style: MyStyles.regularText(
                    size: 12,
                    color: AppTheme.graySubTitleColor,
                  ),
                ),
                const SizedBox(height: 3),
                studentDetailsData.missingFields!.isNotEmpty ?
                Text(
                  "Missing details: ${studentDetailsData.missingFields?.map((e) => _formatField(e.toString())).join(', ') ?? ''}",
                  style: MyStyles.regularText(
                    size: 12,
                    color: AppTheme.redBtnBgColor,
                  ),
                ) : SizedBox(),
              ],
            ),
          ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (value) async {
              if (value == 'delete') {
                _confirmDelete(context);
              } else if (value == 'toggle') {
                final success = await context
                    .read<StudentsCubit>()
                    .toggleStudentStatus(
                      studentDetailsData.uuid ?? '',
                      studentDetailsData.schoolId?.toString() ?? '',
                      studentDetailsData.status ?? 0,
                    );
                if (success) {
                  final updated = context
                      .read<StudentsCubit>()
                      .state
                      .studentsList
                      .firstWhere(
                        (s) => s.uuid == studentDetailsData.uuid,
                        orElse: () => studentDetailsData,
                      );
                  setState(() => studentDetailsData = updated);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Status updated' : 'Failed to update status',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(
                      (studentDetailsData.status ?? 0) == 1
                          ? Icons.toggle_on
                          : Icons.toggle_off,
                      size: 22,
                      color: (studentDetailsData.status ?? 0) == 1
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      (studentDetailsData.status ?? 0) == 1
                          ? 'Deactivate'
                          : 'Activate',
                    ),
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

  String _formatField(String text) {
    return text
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '',
        )
        .join(' ');
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
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Are you sure you want to\ndelete this student?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
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
                        final success = await context
                            .read<StudentsCubit>()
                            .deleteStudent(
                              studentDetailsData.uuid ?? '',
                              studentDetailsData.schoolId?.toString() ?? '',
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Student deleted successfully'
                                    : 'Failed to delete student',
                              ),
                              backgroundColor: success
                                  ? Colors.green
                                  : Colors.red,
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

  Widget _placeholder() {
    return Container(
      height: 60,
      width: 60,
      color: Colors.grey.shade300,
      child: const Icon(Icons.person, color: Colors.grey),
    );
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),

              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  showPicker(context);
                },
                icon: Icon(Icons.edit),
                label: Text("Edit Profile Image"),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
