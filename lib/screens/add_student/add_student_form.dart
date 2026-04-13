import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/components/text_filed.dart';
import 'package:idmitra/models/student_form/StudentFormFieldsModel.dart';
import 'package:idmitra/providers/student_form/student_form_cubit.dart';
import 'package:idmitra/utils/common_widgets/LogoUploadView.dart';
import 'package:idmitra/utils/common_widgets/app_button.dart';
import 'package:idmitra/utils/common_widgets/drop_down/drop_down.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/add_student/StudentFormDataModel.dart';
import '../../providers/add_student/add_student_cubit.dart';
import '../../providers/student_form/student_form_data_cubit.dart';

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

class AddStudentFormPage extends StatefulWidget {
  final String schoolId;
  const AddStudentFormPage({super.key, required this.schoolId});

  @override
  State<AddStudentFormPage> createState() => _AddStudentFormPageState();
}

class _AddStudentFormPageState extends State<AddStudentFormPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> _ctrl = {};
  final Map<String, dynamic> _selectVal = {};
  final Map<String, File?> _files = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in _ctrl.values) c.dispose();
    super.dispose();
  }

  void _clearForm() {
    for (final c in _ctrl.values) c.clear();
    setState(() {
      _selectVal.clear();
      _files.clear();
    });
  }

  void _showImagePicker(String fieldName) {
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
  }) => InkWell(
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
    if (cropped != null) setState(() => _files[fieldName] = File(cropped.path));
  }

  TextEditingController _ctrlFor(String name) {
    _ctrl.putIfAbsent(name, () => TextEditingController());
    return _ctrl[name]!;
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

  Widget _stringDropdown(String name, List<String> options) {
    final val = (_selectVal[name] as String?);
    return Dropdown<String>(
      value: (val != null && options.contains(val)) ? val : null,
      items: options,
      hintText: options.first,
      onChange: (v) => setState(() => _selectVal[name] = v ?? options.first),
      displayText: (_, o) => o,
      showClearButton: false,
    );
  }

  Widget _sessionDropdown(List<SessionOption> sessions) {
    if (sessions.isEmpty) return _loadingTile('Loading sessions...');
    final val = (_selectVal['session'] as int?);
    final selected = (val != null && sessions.any((s) => s.value == val))
        ? sessions.firstWhere((s) => s.value == val)
        : null;
    return Dropdown<SessionOption>(
      value: selected,
      items: sessions,
      hintText: 'Select Session',
      onChange: (v) => setState(() => _selectVal['session'] = v?.value),
      displayText: (_, o) => o.label,
      showClearButton: false,
    );
  }

  Widget _classDropdown(List<ClassOption> classes) {
    if (classes.isEmpty) return _loadingTile('Loading classes...');
    final seen = <String>{};
    final unique = classes.where((c) => seen.add(c.nameWithPrefix)).toList();
    final val = (_selectVal['class'] as int?);
    final selected = (val != null && unique.any((c) => c.id == val))
        ? unique.firstWhere((c) => c.id == val)
        : null;
    return Dropdown<ClassOption>(
      value: selected,
      items: unique,
      hintText: 'Select Class',
      onChange: (v) {
        setState(() {
          _selectVal['class'] = v?.id;
          _selectVal['class_section'] = null;
        });
      },
      displayText: (_, o) => o.nameWithPrefix,
      showClearButton: false,
    );
  }

  Widget _houseDropdown(List<HouseOption> houses) {
    if (houses.isEmpty) return _loadingTile('Loading houses...');
    final seen = <String>{};
    final unique = houses.where((h) => seen.add(h.name)).toList();
    final val = (_selectVal['house'] as int?);
    final selected = (val != null && unique.any((h) => h.id == val))
        ? unique.firstWhere((h) => h.id == val)
        : null;
    return Dropdown<HouseOption>(
      value: selected,
      items: unique,
      hintText: 'Select House',
      onChange: (v) => setState(() => _selectVal['house'] = v?.id),
      displayText: (_, o) => o.name,
      showClearButton: false,
    );
  }

  Widget _sectionDropdown(List<SectionOption> sections) {
    final List<SectionOption> opts = sections.isNotEmpty
        ? sections
        : [
            'A',
            'B',
            'C',
            'D',
            'E',
          ].map((n) => SectionOption(id: n.codeUnitAt(0), name: n)).toList();

    final val = (_selectVal['class_section'] as int?);
    final selected = (val != null && opts.any((s) => s.id == val))
        ? opts.firstWhere((s) => s.id == val)
        : null;
    return Dropdown<SectionOption>(
      value: selected,
      items: opts,
      hintText: 'Select Section',
      onChange: (v) => setState(() => _selectVal['class_section'] = v?.id),
      displayText: (_, o) => o.name,
      showClearButton: false,
    );
  }

  Widget _loadingTile(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    decoration: BoxDecoration(
      border: Border.all(color: AppTheme.backBtnBgColor),
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
    ),
    child: Text(
      text,
      style: MyStyles.regularText(size: 14, color: AppTheme.graySubTitleColor),
    ),
  );

  Widget _dateField(String name, String hint) => AppTextField(
    controller: _ctrlFor(name),
    hintText: 'DD.MM.YYYY',
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'[\d.\-/]')),
      LengthLimitingTextInputFormatter(10),
      _DotDateFormatter(),
    ],
  );

  Widget _photoField(String name, String label) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _label(label),
      GestureDetector(
        onTap: () => _showImagePicker(name),
        child: Container(
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.backBtnBgColor),
          ),
          child: _files[name] != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _files[name]!,
                        width: double.infinity,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _files[name] = null),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black54,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt, color: Colors.grey, size: 22),
                    const SizedBox(height: 4),
                    Text('Add Photo',
                        style: MyStyles.regularText(size: 11, color: Colors.grey)),
                  ],
                ),
        ),
      ),
    ],
  );

  Widget _buildField(StudentFormField f, StudentFormDataModel? data) {
    switch (f.type) {
      case 'select':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(f.label, required: f.required),
            _dynamicSelectField(f.name, data),
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
              mxLine: 1,
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
            AppTextField(
              controller: _ctrlFor(f.name),
              hintText: '${f.label}...',
              keyboardType: TextInputType.emailAddress,
              mxLine: 1,
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
            AppTextField(
              controller: _ctrlFor(f.name),
              hintText: '${f.label}...',
              mxLine: 1,
              textCapitalization: TextCapitalization.words,
            ),
          ],
        );
    }
  }

  Widget _dynamicSelectField(String name, StudentFormDataModel? data) {
    switch (name) {
      case 'session':
        return _sessionDropdown(data?.sessions ?? []);
      case 'class':
        return _classDropdown(data?.classes ?? []);
      case 'house':
        return _houseDropdown(data?.houses ?? []);
      case 'gender':
        return _stringDropdown(name, _kGenderOptions);
      case 'transport_mode':
        return _stringDropdown(name, _kTransportOptions);
      case 'blood_group':
        return _stringDropdown(name, _kBloodGroupOptions);
      case 'is_rte_student':
        return _stringDropdown(name, _kRteOptions);
      case 'class_section':
        final selectedClassId = (_selectVal['class'] as int?);
        final selectedClass = data?.classes.firstWhere(
          (c) => c.id == selectedClassId,
          orElse: () => ClassOption(id: -1, name: '', nameWithPrefix: ''),
        );

        var sections = selectedClass?.sections ?? [];
        if (sections.isEmpty &&
            (selectedClass?.sectionsIds.isNotEmpty ?? false)) {
          sections = selectedClass!.sectionsIds
              .map((id) => SectionOption(id: id, name: 'Section $id'))
              .toList();
        }
        return _sectionDropdown(sections);
      default:
        return _stringDropdown(name, ['-Select-']);
    }
  }

  Widget _twoColGrid(
    List<StudentFormField> fields,
    StudentFormDataModel? data,
  ) {
    final rows = <Widget>[];
    int i = 0;
    while (i < fields.length) {
      final f = fields[i];
      if (f.type == 'textarea') {
        rows.add(_buildField(f, data));
        rows.add(const SizedBox(height: 12));
        i++;
      } else {
        final hasNext =
            i + 1 < fields.length && fields[i + 1].type != 'textarea';
        final next = hasNext ? fields[i + 1] : null;
        rows.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildField(f, data)),
              if (next != null) ...[
                const SizedBox(width: 12),
                Expanded(child: _buildField(next, data)),
              ] else
                const Expanded(child: SizedBox()),
            ],
          ),
        );
        rows.add(const SizedBox(height: 12));
        i += next != null ? 2 : 1;
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }

  Widget _sectionCard({required String title, required Widget child}) =>
      Container(
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

  Widget _mainInfoTab(
    List<StudentFormField> currentFields,
    StudentFormDataModel? data,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: _sectionCard(
          title: 'Main Information',
          child: currentFields.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No fields configured. Please configure student form fields first.',
                      style: MyStyles.regularText(
                        size: 13,
                        color: AppTheme.graySubTitleColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _twoColGrid(currentFields, data),
        ),
      ),
    );
  }

  Widget _additionalInfoTab(
    List<StudentFormField> fields,
    StudentFormDataModel? data,
  ) {
    const groupOrder = [
      'Personal Details',
      'Parent Details',
      'Address Details',
      'Academic Details',
    ];

    final Map<String, List<StudentFormField>> grouped = {};
    for (final f in fields) {
      String g = f.groupLabel.isNotEmpty ? f.groupLabel : 'Other';
      // Normalize group labels
      if (g == 'School')  g = 'Academic Details';
      if (g == 'Student') g = 'Personal Details';
      if (g == 'Parent')  g = 'Parent Details';
      if (g == 'Address') g = 'Address Details';
      grouped.putIfAbsent(g, () => []).add(f);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final ai = groupOrder.indexOf(a);
        final bi = groupOrder.indexOf(b);
        if (ai == -1 && bi == -1) return a.compareTo(b);
        if (ai == -1) return 1;
        if (bi == -1) return -1;
        return ai.compareTo(bi);
      });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: sortedKeys
            .map(
              (key) => _sectionCard(
                title: key,
                child: _twoColGrid(grouped[key]!, data),
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentFormDataCubit, StudentFormDataState>(
      builder: (context, dataState) {
        return BlocBuilder<StudentFormCubit, StudentFormState>(
          builder: (context, formState) {
            final data = dataState.data;
            final currentFields = formState.fields;
            final additionalFields = formState.availableFields
                .where((f) => !currentFields.any((c) => c.name == f.name))
                .toList();

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
                      labelStyle: MyStyles.boldText(
                        size: 13,
                        color: Colors.white,
                      ),
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
                    child: (dataState.loading || formState.loading)
                        ? const Center(child: CircularProgressIndicator())
                        : dataState.error != null && dataState.data == null
                        ? Center(
                            child: Text(
                              dataState.error!,
                              style: MyStyles.regularText(
                                size: 14,
                                color: Colors.red,
                              ),
                            ),
                          )
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _mainInfoTab(currentFields, data),
                              additionalFields.isEmpty
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : _additionalInfoTab(additionalFields, data),
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
                          child: BlocConsumer<AddStudentCubit, AddStudentState>(
                            listener: (ctx, state) {
                              if (state.success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      state.message ??
                                          'Student added successfully',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pop(context);
                              }
                              if (state.error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(state.error!),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            builder: (ctx, state) => AppButton(
                              title: 'Submit',
                              isLoading: state.loading,
                              color: AppTheme.btnColor,
                              onTap: state.loading
                                  ? () {}
                                  : () {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        final allFields = {
                                          ..._ctrl.map(
                                            (k, v) => MapEntry(k, v.text),
                                          ),
                                          ..._selectVal,
                                        };
                                        ctx.read<AddStudentCubit>().submit(
                                          schoolId: widget.schoolId,
                                          fields: allFields,
                                          files: _files,
                                        );
                                      }
                                    },
                            ),
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
      },
    );
  }
}

// Converts / or - to . while typing date
class _DotDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Replace / and - with .
    final text = newValue.text.replaceAll('/', '.').replaceAll('-', '.');
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
