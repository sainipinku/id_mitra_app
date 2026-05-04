import 'dart:io';

import 'package:flutter/material.dart';
import 'package:idmitra/Widgets/AppTextStyles.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/components/text_filed.dart';
import 'package:idmitra/models/students/StudentsListModel.dart';
import 'package:idmitra/utils/common_widgets/app_button.dart';
import 'package:idmitra/utils/navigation_utils.dart';
import 'package:image_picker/image_picker.dart';

import 'edit_student.dart';

class AddNewStudent extends StatefulWidget {
  const AddNewStudent({super.key});

  @override
  State<AddNewStudent> createState() => _AddNewStudentState();
}

class _AddNewStudentState extends State<AddNewStudent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController rollNumberController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController parentsNameController = TextEditingController();
  final TextEditingController parentsPhoneController = TextEditingController();

  File? studentImageFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    studentNameController.dispose();
    classController.dispose();
    sectionController.dispose();
    rollNumberController.dispose();
    phoneNumberController.dispose();
    parentsNameController.dispose();
    parentsPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        studentImageFile = File(pickedFile.path);
      });
    }
  }

  void _saveStudent() {
    setState(() => isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isLoading = false);
      final savedStudent = StudentDetailsData(
        name: studentNameController.text,
        rollNo: rollNumberController.text,
        phone: phoneNumberController.text,
        fatherName: parentsNameController.text,
        fatherPhone: parentsPhoneController.text,
        datumClass: Class(name: classController.text),
        section: Section(name: sectionController.text),
      );
      navigatePushReplacement(context: context, page: EditStudent(student: savedStudent));
    });
  }

  void _cancel() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Add New Students',
        backgroundColor: Colors.transparent,
        showText: true,
      ),
      body: Column(
        children: [
          Material(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.btnColor,
              unselectedLabelColor: AppTheme.graySubTitleColor,
              indicatorColor: AppTheme.btnColor,
              indicatorWeight: 2.5,
              labelStyle: MyStyles.mediumText(size: 13, color: Colors.white),
              unselectedLabelStyle: MyStyles.regularText(size: 13, color: Colors.white),
              tabs: const [
                Tab(text: 'Main Information'),
                Tab(text: 'Other Student'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Main Information
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RequiredLabel("Student Name"),
                            const SizedBox(height: 6),
                            nameTextField(controller: studentNameController, hintName: 'e.g. Sumit Sharma'),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextLabel("Class"),
                                      const SizedBox(height: 6),
                                      nameTextField(controller: classController, hintName: '8'),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextLabel("Section"),
                                      const SizedBox(height: 6),
                                      nameTextField(controller: sectionController, hintName: 'A'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextLabel("Roll Number"),
                            const SizedBox(height: 6),
                            nameTextField(controller: rollNumberController, hintName: 'e.g. 55'),
                            const SizedBox(height: 16),
                            TextLabel("Phone Number"),
                            const SizedBox(height: 6),
                            phoneNumberTextField(
                              controller: phoneNumberController,
                              hintName: 'e.g. +91 9376475677',
                              isRequired: false,
                            ),
                            const SizedBox(height: 16),
                            TextLabel("Parents name"),
                            const SizedBox(height: 6),
                            nameTextField(controller: parentsNameController, hintName: 'e.g. Shubham Sharma'),
                            const SizedBox(height: 16),
                            TextLabel("Parents Phone"),
                            const SizedBox(height: 6),
                            phoneNumberTextField(
                              controller: parentsPhoneController,
                              hintName: 'e.g. +91 9987874874',
                              isRequired: false,
                            ),
                            const SizedBox(height: 16),
                            TextLabel("Upload Image"),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppTheme.whiteColor,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: AppTheme.backBtnBgColor),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.all(8),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.backBtnBgColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Choose file',
                                        style: MyStyles.regularText(size: 14, color: AppTheme.black_Color),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        studentImageFile != null
                                            ? studentImageFile!.path.split('/').last
                                            : 'No file choosen',
                                        style: MyStyles.regularText(size: 14, color: AppTheme.graySubTitleColor),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              title: "Cancel",
                              isLoading: false,
                              color: AppTheme.backBtnBgColor,
                              onTap: _cancel,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppButton(
                              title: "Save Student",
                              isLoading: isLoading,
                              color: AppTheme.btnColor,
                              onTap: _saveStudent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Tab 2: Other Student
                const Center(child: Text('No other students')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
