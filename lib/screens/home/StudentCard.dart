import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:idmitra/api_mamanger/api_manager.dart';
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/helpers/keyboard.dart';
import 'package:idmitra/models/students/StudentsListModel.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class StudentCard extends StatefulWidget {
  StudentDetailsData studentDetailsData;
  StudentCard({super.key, required this.studentDetailsData});

  @override
  State<StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
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
          Config.baseUrl + Routes.updateStudentProfile(widget.studentDetailsData.uuid ?? ''),
        );
        print('proifle---------${Config.baseUrl + Routes.updateStudentProfile(widget.studentDetailsData.uuid ?? '')}');
        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          print('proifle---------${jsonData['data']['profile_photo_url']}');
          setState(() {
            widget.studentDetailsData = widget.studentDetailsData.copyWith(
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
                    widget.studentDetailsData = widget.studentDetailsData
                        .copyWith(profilePhotoUrl: "");
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
  Widget build(BuildContext context) {
    return Container(
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
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: isUploading
                    ? const SizedBox(
                        height: 60,
                        width: 60,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : (widget.studentDetailsData.profilePhotoUrl != null &&
                          widget.studentDetailsData.profilePhotoUrl!.isNotEmpty)
                    ? Image.network(
                        widget.studentDetailsData.profilePhotoUrl!,
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),

              /// 📸 Edit Icon
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () => showPicker(context),
                  child: Container(
                    height: 22,
                    width: 22,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          /// STUDENT DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.studentDetailsData.name ?? '',
                      style: MyStyles.boldText(
                        size: 16,
                        color: AppTheme.black_Color,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      "• ${widget.studentDetailsData.datumClass?.nameWithprefix ?? ''}-${widget.studentDetailsData.section?.name ?? ''}",
                      style: MyStyles.boldText(
                        size: 16,
                        color: AppTheme.btnColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  "Father name : ${widget.studentDetailsData.fatherName ?? ''}",
                  style: MyStyles.regularText(
                    size: 12,
                    color: AppTheme.graySubTitleColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Missing details: ${widget.studentDetailsData.missingFields
                      ?.map((e) => _formatField(e.toString()))
                      .join(', ') ?? ''}",
                  style: MyStyles.regularText(
                    size: 12,
                    color: AppTheme.redBtnBgColor,
                  ),
                ),
              ],
            ),
          ),

          /// STATUS BADGE Container( padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration( color: AppTheme.activeBtn10perOpacityColor, borderRadius: BorderRadius.circular(20), ), child: Text( "ACTIVE", style: MyStyles.boldText(size: 10, color: AppTheme.activeBtn), ), ) ], ),
        ],
      ),
    );
  }
  String _formatField(String text) {
    return text
        .replaceAll('_', ' ') // remove underscore
        .split(' ')
        .map((word) =>
    word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : '')
        .join(' ');
  }
  Widget _placeholder() {
    return Container(
      height: 60,
      width: 60,
      color: Colors.grey.shade300,
      child: const Icon(Icons.person, color: Colors.grey),
    );
  }
}
