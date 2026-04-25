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

  final nameController =
  TextEditingController(text: "John Doe");
  final emailController =
  TextEditingController(text: "doejohn@gmail.com");
  final phoneController =
  TextEditingController(text: "9876543210");
  _FromCamera(BuildContext context) async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        profileImageFile = pickedFile != null ? File(pickedFile.path) : null;
        _cropImage();
      });
    }
  }
  Future<void> _cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: profileImageFile!.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: AppTheme.MainColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio4x3,
            lockAspectRatio: true,
            hideBottomControls: true),
        IOSUiSettings(
            title: 'Cropper',
            minimumAspectRatio: 1.1,
            aspectRatioLockEnabled: true,
            resetButtonHidden: true
        )
      ],
    );
    if (profileImageFile != null) {
      if (croppedFile != null) {
        setState(() {
          croppedProfileFile = croppedFile;
        });
        final path = croppedProfileFile!.path;

      }
    }

  }
  _FromGallery(BuildContext context) async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImageFile = pickedFile != null ? File(pickedFile.path) : null;
        _cropImage();
      });
    }
  }
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppTheme.whiteColor,
        shape: const RoundedRectangleBorder( // <-- SEE HERE
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        builder: (BuildContext bc) {
          return  SingleChildScrollView(
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Center(
                child: Padding(padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Text('Choose Your Picher',
                            style: MyStyles.boldText(size: 14, color: AppTheme.black_Color)),
                      ),
                      InkWell(
                        onTap: (){
                          //checkCameraPermission(context);
                          _FromCamera(context);
                          KeyboardUtil.hideKeyboard(context);
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children:  [
                            SvgPicture.asset(
                              'assets/icons/camera_single.svg',
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Text('Camera',
                                  style: MyStyles.regularText(size: 14, color: AppTheme.black_Color)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 1,
                        margin: const EdgeInsets.only(top: 10.0,bottom: 10.0),
                        width: MediaQuery.of(context).size.width,
                        color: AppTheme.cardBgSecColor,
                      ),
                      InkWell(
                        onTap: () async{
                          _FromGallery(context);
                          // checkGalleryPermission(context);
                          KeyboardUtil.hideKeyboard(context);
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children:  [
                            SvgPicture.asset(
                              'assets/icons/choose_from_gallery.svg',
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Text("Choose From Gallery",
                                  style: MyStyles.regularText(size: 14, color: AppTheme.black_Color)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 1,
                        margin: const EdgeInsets.only(top: 10.0,bottom: 10.0),
                        width: MediaQuery.of(context).size.width,
                        color: AppTheme.cardBgSecColor,
                      ),
                      InkWell(
                        onTap: (){
                          setState((){
                            Navigator.of(context).pop();

                          });

                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children:  [
                            SvgPicture.asset(
                              'assets/icons/remove_image.svg',
                              allowDrawingOutsideViewBox:
                              true,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Text('Remove Photo',
                                  style: MyStyles.regularText(size: 14, color: AppTheme.redBtnBgColor)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 1,
                        margin: const EdgeInsets.only(top: 10.0,bottom: 10.0),
                        width: MediaQuery.of(context).size.width,
                        color: AppTheme.cardBgSecColor,
                      )

                    ],
                  ) ,)
                ,
              ),
            )
            ,
          );
        });
  }


  String profile = '';
  String name = '';
  String email = '';
  getUserDetails() async{
    var token = await UserLocal.getUser();
    print('user------$token');
    setState(() {
      profile = token['profileImage'] ?? '';
      nameController.text = token['name'] ?? '';
      emailController.text = token['email'] ?? '';
      phoneController.text = token['phone'] ?? '';
     // gender = token['gender'] ?? '';
      dob = token['dob'] ?? '';
    });

  }
  @override
  void initState() {
    // TODO: implement initState
    getUserDetails();
    super.initState();
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
            listener: (context, state) {
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
                            CircularProgressIndicator(color: AppTheme.bgColor),
                            SizedBox(height: 10.h),
                            const Text('Loading...'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }else if (state is ManageProfileSuccess){
                /// 🔥 Close ONLY dialog
                Navigator.of(context, rootNavigator: true).pop();

                /// 🔥 VERY IMPORTANT: return true
                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.userProfileModel.message ?? '')),
                );
              }
              else if (state is ManageProfileFailed){
                /// 🔥 Close ONLY dialog
                Navigator.of(context, rootNavigator: true).pop();

                /// 🔥 VERY IMPORTANT: return true
                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message ?? '')),
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

                const SizedBox(height: 80), // 👈 space for bottom button
              ].map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: e,
              ))
                  .toList(),
            ),
          ),
        ),
      )
      ,
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
            croppedProfileFile != null ?
            CircleAvatar(
              radius: 60,
              backgroundImage: FileImage(File(croppedProfileFile!.path)),
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Center(
                child: FadeInImage(
                  image: NetworkImage(profile),
                  fit: BoxFit.fill,
                  placeholder:
                  const AssetImage("assets/images/defult_img.png"),
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset("assets/images/defult_img.png");
                  },
                ),
              ),
            ),

            // Agar edit icon chahiye ho
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: (){
                  _showPicker(context);
                },
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: Icon(
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

        /// 🔲 Border
        border: appBorder(AppTheme.backBtnBgColor, 15),

        /// 🔲 Enabled Border
        enabledBorder: appBorder(AppTheme.backBtnBgColor, 15),

        /// 🔲 Focus Border
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
    return InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );

        if (selected != null) {
          String formattedDate = DateFormat('dd-MM-yyyy').format(selected);

          setState(() {
            dob = formattedDate; // agar DateTime bhi rakhna hai

          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: AppTheme.whiteColor,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),

          /// 🔲 Border
          border: appBorder(AppTheme.backBtnBgColor, 15),

          /// 🔲 Enabled Border
          enabledBorder: appBorder(AppTheme.backBtnBgColor, 15),

          /// 🔲 Focus Border
          focusedBorder: appBorder(AppTheme.backBtnBgColor, 15),
        ),
        child: Text(
          dob ?? "Select date",
          style:  TextStyle(fontSize: 14,color: AppTheme.black_Color,),
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
