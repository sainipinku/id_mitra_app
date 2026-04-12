import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/components/text_filed.dart';
import 'package:idmitra/models/student_form/StudentFormFieldsModel.dart';
import 'package:idmitra/providers/student_form/student_form_cubit.dart';
import 'package:idmitra/utils/common_widgets/LogoUploadView.dart';
import 'package:idmitra/utils/common_widgets/app_button.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:idmitra/helpers/keyboard.dart';

const List<Map<String, String>> _kMainFields = [
  {'name': 'student_name', 'label': 'Student Name', 'type': 'text'},
  {'name': 'sr_number', 'label': 'Sr. Number', 'type': 'text'},
  {'name': 'admission_number', 'label': 'Admission Number', 'type': 'text'},
  {'name': 'transport_mode', 'label': 'Transport Mode', 'type': 'select'},
  {'name': 'date_of_birth', 'label': 'Date of Birth', 'type': 'date'},
  {'name': 'gender', 'label': 'Gender', 'type': 'select'},
];

const List<String> _kGenderOptions = [
  '-Select Gender-',
  'Male',
  'Female',
  'Transgender',
];
const List<String> _kTransportOptions = [
  'Select Mode',
  'Self Pickup',
  'School Transport',

];
const List<String> _kBloodGroupOptions = [
  'Select Blood Group',
  'A+',
  'A-',
  'AB+',
  'AB-',
  'B+',
  'B-',
  'O+',
  'O-',
];
const List<String> _kRteOptions = ['-Select-', 'Yes', 'No'];
const List<String> _kSessionOptions = [
  'Select Session',
  '2024-25',
  '2025-26',
  '2026-27',
];
const List<String> _kClassOptions = [
  'Select Class',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '10',
  '11',
  '12',
];
const List<String> _kSectionOptions = [
  'Select Class Section',
  'A',
  'B',
  'C',
  'D',
];
const List<String> _kHouseOptions = [
  'Select House',
  'Red',
  'Blue',
  'Green',
  'Yellow',
];

class AddStudentFormPage extends StatefulWidget {
  const AddStudentFormPage({super.key});

  @override
  State<AddStudentFormPage> createState() => _AddStudentFormPageState();
}

class _AddStudentFormPageState extends State<AddStudentFormPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> _ctrl = {};
  final Map<String, String> _selectVal = {};
  final Map<String, File?> _files = {};

  bool _additionalExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    for (final f in _kMainFields) {
      _ctrl[f['name']!] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in _ctrl.values) c.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String fieldName) async {
    _showPicker(fieldName);
  }

  void _showPicker(String fieldName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (bc) => SingleChildScrollView(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Choose Your Picker',
                    style: MyStyles.boldText(
                      size: 20,
                      color: AppTheme.black_Color,
                    ),
                  ),
                ),
                _pickerOption(
                  'assets/icons/camera_single.svg',
                  'Camera',
                  () async {
                    Navigator.pop(bc);
                    final f = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                    );
                    if (f != null) _cropAndSet(fieldName, File(f.path));
                  },
                ),
                _divider(),
                _pickerOption(
                  'assets/icons/choose_from_gallery.svg',
                  'Choose From Gallery',
                  () async {
                    Navigator.pop(bc);
                    final f = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (f != null) _cropAndSet(fieldName, File(f.path));
                  },
                ),
                _divider(),
                _pickerOption(
                  'assets/icons/remove_image.svg',
                  'Remove Photo',
                  () {
                    setState(() => _files[fieldName] = null);
                    Navigator.pop(bc);
                  },
                  isRemove: true,
                ),
                _divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pickerOption(
    String svg,
    String label,
    VoidCallback onTap, {
    bool isRemove = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SvgPicture.asset(svg, allowDrawingOutsideViewBox: true),
            const SizedBox(width: 10),
            Text(
              label,
              style: MyStyles.regularText(
                size: 14,
                color: isRemove ? AppTheme.redBtnBgColor : AppTheme.black_Color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
    height: 1,
    margin: const EdgeInsets.symmetric(vertical: 4),
    color: AppTheme.cardBgSecColor,
  );

  Future<void> _cropAndSet(String fieldName, File file) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop',
          toolbarColor: AppTheme.MainColor,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(title: 'Crop', aspectRatioLockEnabled: true),
      ],
    );
    if (cropped != null) {
      setState(() => _files[fieldName] = File(cropped.path));
    }
  }

  TextEditingController _ctrlFor(String name) {
    _ctrl.putIfAbsent(name, () => TextEditingController());
    return _ctrl[name]!;
  }

  String _selectFor(String name, String defaultVal) {
    _selectVal.putIfAbsent(name, () => defaultVal);
    return _selectVal[name]!;
  }

  Widget _label(String text, {bool required = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 4),
    child: RichText(
      text: TextSpan(
        text: text,
        style: MyStyles.mediumText(size: 13, color: AppTheme.black_Color),
        children: required
            ? [
                TextSpan(
                  text: ' *',
                  style: MyStyles.mediumText(size: 13, color: Colors.red),
                ),
              ]
            : [],
      ),
    ),
  );

  Widget _selectField(String name, List<String> options) {
    final val = _selectFor(name, options.first);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.backBtnBgColor),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: val,
          isExpanded: true,
          style: MyStyles.regularText(
            size: 14,
            color: AppTheme.graySubTitleColor,
          ),
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) =>
              setState(() => _selectVal[name] = v ?? options.first),
        ),
      ),
    );
  }

  Widget _dateField(String name, String hint) {
    final ctrl = _ctrlFor(name);
    return AppTextField(
      controller: ctrl,
      hintText: hint,
      keyboardType: TextInputType.datetime,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d/]')),
        LengthLimitingTextInputFormatter(10),
      ],
      suffixIcon: const Icon(
        Icons.calendar_today,
        size: 18,
        color: Colors.grey,
      ),
    );
  }

  Widget _photoField(String name, String label) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
      LogoUploadView(
        imageUrl: _files[name],
        onAddPhoto: () => _pickImage(name),
        onRemove: () => setState(() => _files[name] = null),
      ),
    ],
  );

  Widget _buildField(StudentFormField f) {
    switch (f.type) {
      case 'select':
        final opts = _optionsFor(f.name);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(f.label, required: f.required),
            _selectField(f.name, opts),
          ],
        );
      case 'date':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(f.label, required: f.required),
            _dateField(f.name, 'DD/MM/YYYY'),
          ],
        );
      case 'file':
        return _photoField(f.name, f.label);
      case 'textarea':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(f.label, required: f.required),
            AppTextField(
              controller: _ctrlFor(f.name),
              hintText: '${f.label}...',
              mxLine: 4,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
            ),
          ],
        );
      case 'digits':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(f.label, required: f.required),
            AppTextField(
              controller: _ctrlFor(f.name),
              hintText: '${f.label}...',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        );
      case 'phone':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(f.label, required: f.required),
            phoneNumberTextField(
              controller: _ctrlFor(f.name),
              hintName: '${f.label}...',
              isRequired: f.required,
            ),
          ],
        );
      case 'email':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(f.label, required: f.required),
            emailTextField(
              controller: _ctrlFor(f.name),
              isRequired: f.required,
            ),
          ],
        );
      case 'password':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(f.label, required: f.required),
            AppTextField(
              controller: _ctrlFor(f.name),
              hintText: '••••••',
              obscureText: true,
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(f.label, required: f.required),
            nameTextField(
              controller: _ctrlFor(f.name),
              hintName: '${f.label}...',
              isRequired: f.required,
            ),
          ],
        );
    }
  }

  List<String> _optionsFor(String name) {
    switch (name) {
      case 'gender':
        return _kGenderOptions;
      case 'transport_mode':
        return _kTransportOptions;
      case 'blood_group':
        return _kBloodGroupOptions;
      case 'is_rte_student':
        return _kRteOptions;
      case 'session':
        return _kSessionOptions;
      case 'class':
        return _kClassOptions;
      case 'class_section':
        return _kSectionOptions;
      case 'house':
        return _kHouseOptions;
      default:
        return ['-Select-'];
    }
  }

  Widget _twoColGrid(List<Widget> items) {
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: items[i]),
            const SizedBox(width: 12),
            Expanded(
              child: i + 1 < items.length ? items[i + 1] : const SizedBox(),
            ),
          ],
        ),
      );
      rows.add(const SizedBox(height: 12));
    }
    return Column(children: rows);
  }

  Widget _mainInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(
              title: 'Main Information',
              child: _twoColGrid(
                _kMainFields.map((f) {
                  final sf = StudentFormField(
                    name: f['name']!,
                    label: f['label']!,
                    type: f['type']!,
                    group: '',
                    groupLabel: '',
                    required:
                        f['name'] == 'date_of_birth' || f['name'] == 'gender',
                    order: 0,
                  );
                  return _buildField(sf);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _additionalInfoTab(List<StudentFormField> fields) {
    final Map<String, List<StudentFormField>> grouped = {};
    for (final f in fields) {
      final g = f.groupLabel.isNotEmpty ? f.groupLabel : 'Other';
      grouped.putIfAbsent(g, () => []).add(f);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: grouped.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _sectionCard(
              title: entry.key,
              child: _twoColGrid(entry.value.map(_buildField).toList()),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.backBtnBgColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(
              title,
              style: MyStyles.boldText(size: 15, color: AppTheme.black_Color),
            ),
          ),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentFormCubit, StudentFormState>(
      builder: (context, state) {
        final additionalFields = state.availableFields;

        return Scaffold(
          appBar: CommonAppBar(
            title: 'Add Student',
            backgroundColor: Colors.transparent,
            showText: true,
          ),
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                decoration: BoxDecoration(
                  color: AppTheme.appBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.btnColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppTheme.graySubTitleColor,
                  labelStyle: MyStyles.boldText(size: 13, color: Colors.white),
                  unselectedLabelStyle: MyStyles.regularText(
                    size: 13,
                    color: AppTheme.graySubTitleColor,
                  ),
                  tabs: const [
                    Tab(text: 'Main Information'),
                    Tab(text: 'Additional Information'),
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _mainInfoTab(),
                    additionalFields.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : _additionalInfoTab(additionalFields),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        title: 'Cancel',
                        isLoading: false,
                        color: AppTheme.backBtnBgColor,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        title: 'Submit',
                        isLoading: false,
                        color: AppTheme.btnColor,
                        onTap: () {
                          if (_formKey.currentState?.validate() ?? false) {
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
