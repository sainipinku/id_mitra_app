import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:idmitra/Widgets/AppTextStyles.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/api_mamanger/UserLocal.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/custom_button.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/components/text_filed.dart';
import 'package:idmitra/helpers/keyboard.dart';
import 'package:idmitra/providers/manage_profile/manage_profile_cubit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
class AdminEditProfilePage extends StatefulWidget {
  const AdminEditProfilePage({super.key});

  @override
  State<AdminEditProfilePage> createState() => _AdminEditProfilePageState();
}

class _AdminEditProfilePageState extends State<AdminEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  File? profileImageFile;
  CroppedFile? croppedProfileFile;
  String gender = "Male";
  String? dob;
  bool _isDialogShowing = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  Future<void> _fromCamera(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => profileImageFile = File(pickedFile.path));
      await _cropImage();
    }
  }

  Future<void> _cropImage() async {
    if (profileImageFile == null) return;
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: profileImageFile!.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: AppTheme.MainColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.ratio4x3,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(
          title: 'Cropper',
          minimumAspectRatio: 1.1,
          aspectRatioLockEnabled: true,
          resetButtonHidden: true,
        ),
      ],
    );
    if (croppedFile != null) {
      setState(() => croppedProfileFile = croppedFile);
    }
  }

  Future<void> _fromGallery(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => profileImageFile = File(pickedFile.path));
      await _cropImage();
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext bc) {
        return SingleChildScrollView(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text('Choose Your Picker',
                          style: MyStyles.boldText(
                              size: 14, color: AppTheme.black_Color)),
                    ),
                    InkWell(
                      onTap: () {
                        _fromCamera(context);
                        KeyboardUtil.hideKeyboard(context);
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset('assets/icons/camera_single.svg'),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text('Camera',
                                style: MyStyles.regularText(
                                    size: 14, color: AppTheme.black_Color)),
                          ),
                        ],
                      ),
                    ),
                    _pickerDivider(),
                    InkWell(
                      onTap: () {
                        _fromGallery(context);
                        KeyboardUtil.hideKeyboard(context);
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(
                              'assets/icons/choose_from_gallery.svg'),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text('Choose From Gallery',
                                style: MyStyles.regularText(
                                    size: 14, color: AppTheme.black_Color)),
                          ),
                        ],
                      ),
                    ),
                    _pickerDivider(),
                    InkWell(
                      onTap: () {
                        setState(() {});
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset('assets/icons/remove_image.svg',
                              allowDrawingOutsideViewBox: true),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text('Remove Photo',
                                style: MyStyles.regularText(
                                    size: 14,
                                    color: AppTheme.redBtnBgColor)),
                          ),
                        ],
                      ),
                    ),
                    _pickerDivider(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _pickerDivider() => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(vertical: 10),
        color: AppTheme.cardBgSecColor,
      );

  String profile = '';

  Future<void> _getUserDetails() async {
    final token = await UserLocal.getUser();
    setState(() {
      profile = token['profileImage'] ?? '';
      nameController.text = token['name'] ?? '';
      emailController.text = token['email'] ?? '';
      phoneController.text = token['phone'] ?? '';
      dob = token['dob'] ?? '';
    });
  }

  @override
  void initState() {
    _getUserDetails();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Profile"),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: _saveButton(),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ManageProfileCubit, ManageProfileState>(
            listener: (context, state) {
              if (state is ManageProfileLoading) {
                if (!_isDialogShowing) {
                  _isDialogShowing = true;
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (_ctx) => const Dialog(
                      backgroundColor: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text('Loading...'),
                          ],
                        ),
                      ),
                    ),
                  ).then((_) => _isDialogShowing = false);
                }
              } else if (state is ManageProfileSuccess) {
                if (_isDialogShowing) {
                  _isDialogShowing = false;
                  Navigator.of(context, rootNavigator: true).pop();
                }
                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.userProfileModel.message ?? 'Profile updated')),
                );
              } else if (state is ManageProfileFailed) {
                if (_isDialogShowing) {
                  _isDialogShowing = false;
                  Navigator.of(context, rootNavigator: true).pop();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message ?? 'Something went wrong')),
                );
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _profileImage(),
                const SizedBox(height: 30),
                RequiredLabel('Name'),
                nameTextField(
                    controller: nameController, hintName: 'Enter Name'),
                TextLabel('Email Address'),
                nameTextField(controller: emailController),
                TextLabel('Phone Number'),
                phoneNumberTextField(controller: phoneController),
                TextLabel('Select Gender'),
                _genderDropdown(),
                TextLabel('Select DOB'),
                _dobPicker(),
                const SizedBox(height: 80),
              ]
                  .map((e) =>
                      Padding(padding: const EdgeInsets.only(bottom: 8), child: e))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileImage() {
    return Center(
      child: SizedBox(
        width: 125,
        height: 125,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            croppedProfileFile != null
                ? CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        FileImage(File(croppedProfileFile!.path)),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Center(
                      child: FadeInImage(
                        image: NetworkImage(profile),
                        fit: BoxFit.fill,
                        placeholder: const AssetImage(
                            "assets/images/defult_img.png"),
                        imageErrorBuilder: (context, error, stackTrace) =>
                            Image.asset("assets/images/defult_img.png"),
                      ),
                    ),
                  ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showPicker(context),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.camera_alt,
                      size: 25, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderDropdown() {
    return DropdownButtonFormField<String>(
      value: gender,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.whiteColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: _appBorder(AppTheme.backBtnBgColor, 15),
        enabledBorder: _appBorder(AppTheme.backBtnBgColor, 15),
        focusedBorder: _appBorder(AppTheme.backBtnBgColor, 15),
      ),
      items: ["Male", "Female", "Other"]
          .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
          .toList(),
      onChanged: (value) => setState(() => gender = value!),
    );
  }

  OutlineInputBorder _appBorder(Color color, double radius) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  Widget _dobPicker() {
    return InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (selected != null) {
          setState(() => dob = DateFormat('dd-MM-yyyy').format(selected));
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: AppTheme.whiteColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: _appBorder(AppTheme.backBtnBgColor, 15),
          enabledBorder: _appBorder(AppTheme.backBtnBgColor, 15),
          focusedBorder: _appBorder(AppTheme.backBtnBgColor, 15),
        ),
        child: Text(
          dob ?? "Select date",
          style: TextStyle(fontSize: 14, color: AppTheme.black_Color),
        ),
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: 'Save'.toUpperCase(),
        color: AppTheme.black_Color,
        textColor: AppTheme.whiteColor,
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final payload = {
              "name": nameController.text.trim(),
              "phone": phoneController.text.trim(),
              "email": emailController.text.trim(),
              "gender": gender,
              "dob": dob ?? '',
            };
            final imageFile = croppedProfileFile != null
                ? File(croppedProfileFile!.path)
                : null;
            context.read<ManageProfileCubit>().updateProfile(payload, imageFile);
          }
        },
        isLoading: false,
      ),
    );
  }
}
