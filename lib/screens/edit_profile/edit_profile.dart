import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:idmitra/providers/home/home_cubit.dart';
import 'package:idmitra/providers/manage_profile/manage_profile_cubit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  File? profileImageFile;
  CroppedFile? croppedProfileFile;
  String gender = "Male";
  String? dob;

  final nameController = TextEditingController(text: "John Doe");
  final emailController = TextEditingController(text: "doejohn@gmail.com");
  final phoneController = TextEditingController(text: "9876543210");

  // ✅ Camera se image lo
  _FromCamera(BuildContext context) async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        profileImageFile = File(pickedFile.path);
      });
      _cropImage();
    }
  }

  // ✅ Image crop karo
  Future<void> _cropImage() async {
    if (profileImageFile == null) return;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
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
      setState(() {
        croppedProfileFile = croppedFile;
      });
      print("✅ Cropped image path: ${croppedProfileFile!.path}");
    }
  }

  // ✅ Gallery se image lo
  _FromGallery(BuildContext context) async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImageFile = File(pickedFile.path);
      });
      _cropImage();
    }
  }

  // ✅ Image picker bottom sheet
  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Choose Your Picher',
                        style: MyStyles.boldText(
                            size: 14, color: AppTheme.black_Color),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _FromCamera(context);
                        KeyboardUtil.hideKeyboard(context);
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset('assets/icons/camera_single.svg'),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              'Camera',
                              style: MyStyles.regularText(
                                  size: 14, color: AppTheme.black_Color),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 1,
                      margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      width: MediaQuery.of(context).size.width,
                      color: AppTheme.cardBgSecColor,
                    ),
                    InkWell(
                      onTap: () async {
                        _FromGallery(context);
                        KeyboardUtil.hideKeyboard(context);
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                              'assets/icons/choose_from_gallery.svg'),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              "Choose From Gallery",
                              style: MyStyles.regularText(
                                  size: 14, color: AppTheme.black_Color),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 1,
                      margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      width: MediaQuery.of(context).size.width,
                      color: AppTheme.cardBgSecColor,
                    ),
                    InkWell(
                      onTap: () {
                        // ✅ Remove photo — local file clear karo
                        setState(() {
                          croppedProfileFile = null;
                          profileImageFile = null;
                        });
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/remove_image.svg',
                            allowDrawingOutsideViewBox: true,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              'Remove Photo',
                              style: MyStyles.regularText(
                                  size: 14, color: AppTheme.redBtnBgColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 1,
                      margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      width: MediaQuery.of(context).size.width,
                      color: AppTheme.cardBgSecColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String profile = '';
  String name = '';
  String email = '';

  // ✅ SharedPrefs se user details load karo
  getUserDetails() async {
    var token = await UserLocal.getUser();
    print('user------$token');
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
    getUserDetails();
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

      /// ✅ Fixed Bottom Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: _saveButton(),
      ),

      body: MultiBlocListener(
        listeners: [
          BlocListener<ManageProfileCubit, ManageProfileState>(
            listener: (context, state) async {
              if (state is ManageProfileLoading) {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (_ctx) {
                    return Dialog(
                      backgroundColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                                color: AppTheme.btnColor),
                            SizedBox(height: 10.h),
                            const Text('Loading...'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else if (state is ManageProfileSuccess) {
                // ✅ Loading dialog band karo
                Navigator.of(context, rootNavigator: true).pop();

                // ✅ Naya photo URL server se ya state se lo
                final updatedPhotoUrl = state.updatedPhotoUrl ?? '';

                if (updatedPhotoUrl.isNotEmpty) {
                  // ✅ CachedNetworkImage ka purana cache evict karo
                  await CachedNetworkImage.evictFromCache(updatedPhotoUrl);

                  if (mounted) {
                    setState(() {
                      profile = updatedPhotoUrl; // ✅ local variable update
                      croppedProfileFile = null; // ✅ local file clear
                      profileImageFile = null;
                    });
                  }
                }

                // ✅ HomeCubit refresh karo taaki ProfileSetting screen bhi update ho
                if (mounted) {
                  await context.read<HomeCubit>().loadHomeData();
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.userProfileModel.message ??
                            'Profile updated successfully',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // ✅ True return karo — ProfileSetting refresh karega
                  Navigator.pop(context, true);
                }
              } else if (state is ManageProfileFailed) {
                // ✅ Loading dialog band karo
                Navigator.of(context, rootNavigator: true).pop();

                // ✅ Error dikhao — page pop mat karo retry ke liye
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message ?? 'Something went wrong'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else if (state is ManageProfileOnHold) {
                Navigator.of(context, rootNavigator: true).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account on hold. Contact owner.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
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
                  .map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: e,
              ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- PROFILE IMAGE ----------------
  Widget _profileImage() {
    return Center(
      child: SizedBox(
        width: 125,
        height: 125,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // ✅ Pehle local cropped file dikhao, nahi to network image
            croppedProfileFile != null
                ? CircleAvatar(
              radius: 60,
              backgroundImage:
              FileImage(File(croppedProfileFile!.path)),
            )
                : profile.isNotEmpty
                ? CachedNetworkImage(
              // ✅ ValueKey — URL change hone par widget rebuild hoga
              key: ValueKey(profile),
              imageUrl: profile,
              imageBuilder: (context, imageProvider) => CircleAvatar(
                radius: 60,
                backgroundImage: imageProvider,
              ),
              placeholder: (context, url) => CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                child: const CircularProgressIndicator(
                    strokeWidth: 2),
              ),
              errorWidget: (context, url, error) => CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.person,
                    size: 50, color: Colors.grey),
              ),
            )
                : CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.person,
                  size: 50, color: Colors.grey),
            ),

            // ✅ Camera edit icon
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  _showPicker(context);
                },
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.camera_alt,
                    size: 25,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- TEXT FIELD ----------------
  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Required";
          }
          return null;
        },
      ),
    );
  }

  // ---------------- GENDER ----------------
  Widget _genderDropdown() {
    return DropdownButtonFormField<String>(
      value: gender,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.whiteColor,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: appBorder(AppTheme.backBtnBgColor, 15),
        enabledBorder: appBorder(AppTheme.backBtnBgColor, 15),
        focusedBorder: appBorder(AppTheme.backBtnBgColor, 15),
      ),
      items: ["Male", "Female", "Other"]
          .map(
            (e) => DropdownMenuItem<String>(
          value: e,
          child: Text(e),
        ),
      )
          .toList(),
      onChanged: (value) {
        setState(() => gender = value!);
      },
    );
  }

  OutlineInputBorder appBorder(Color color, double radius) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  // ---------------- DOB ----------------
  Widget _dobPicker() {
    final hasDate = dob != null && dob!.isNotEmpty;
    return InkWell(
      onTap: () async {
        DateTime? initial;
        if (hasDate) {
          try {
            initial = DateFormat('dd-MM-yyyy').parse(dob!);
          } catch (_) {}
        }
        final selected = await showDatePicker(
          context: context,
          initialDate: initial ?? DateTime(2000),
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
          border: appBorder(AppTheme.backBtnBgColor, 15),
          enabledBorder: appBorder(AppTheme.backBtnBgColor, 15),
          focusedBorder: appBorder(AppTheme.backBtnBgColor, 15),
          suffixIcon: Icon(Icons.calendar_today_outlined,
              size: 18, color: AppTheme.graySubTitleColor),
        ),
        child: Text(
          hasDate ? dob! : 'DD-MM-YYYY',
          style: TextStyle(
            fontSize: 14,
            color:
            hasDate ? AppTheme.black_Color : AppTheme.graySubTitleColor,
          ),
        ),
      ),
    );
  }

  // ---------------- SAVE BUTTON ----------------
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
            // ✅ Cropped image file pass karo
            final imageFile = croppedProfileFile != null
                ? File(croppedProfileFile!.path)
                : null;
            context
                .read<ManageProfileCubit>()
                .updateProfile(payload, imageFile);
          }
        },
        isLoading: false,
      ),
    );
  }
}