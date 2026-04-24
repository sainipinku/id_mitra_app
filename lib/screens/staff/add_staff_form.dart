import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/api_mamanger/UserLocal.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/components/text_filed.dart';
import 'package:idmitra/models/staff/StaffDetailModel.dart';
import 'package:idmitra/models/student_form/StudentFormFieldsModel.dart';
import 'package:idmitra/providers/staff_form/staff_form_cubit.dart';
import 'package:idmitra/providers/add_staff/add_staff_cubit.dart';
import 'package:idmitra/utils/common_widgets/app_button.dart';
import 'package:idmitra/utils/common_widgets/drop_down/drop_down.dart';

const List<String> _kGenderOptions = [
  '-Select Gender-',
  'Male',
  'Female',
  'Transgender',
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
const List<String> _kRelationOptions = [
  '- Select Relation -',
  'Father',
  'Mother',
  'Spouse',
  'Sibling',
  'Friend',
  'Other',
];

class _EmergencyContact {
  String relation;
  String name;
  String phone;
  _EmergencyContact({this.relation = '', this.name = '', this.phone = ''});
}

class AddStaffFormPage extends StatefulWidget {
  final String schoolId;
  final StaffDetailModel? editStudent;
  const AddStaffFormPage({
    super.key,
    required this.editStudent,
    required this.schoolId,
  });

  @override
  State<AddStaffFormPage> createState() => _AddStaffFormPageState();
}

class _AddStaffFormPageState extends State<AddStaffFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final StaffFormCubit _staffFormCubit;
  late final AddStaffCubit _addStaffCubit;
  String _schoolId = '';

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _selectValues = {};

  final _whatsapp = TextEditingController();
  final _fatherName = TextEditingController();
  final _motherName = TextEditingController();
  final _husbandName = TextEditingController();
  final _dob = TextEditingController();
  final _doj = TextEditingController();
  final _address = TextEditingController();
  final _pincode = TextEditingController();
  final _employeeId = TextEditingController();
  final _nationalCode = TextEditingController();

  String? _selectedGender;
  String? _selectedBloodGroup;

  final List<_EmergencyContact> _emergencyContacts = [_EmergencyContact()];

  bool get _isEditMode => widget.editStudent != null;

  @override
  void initState() {
    super.initState();
    _staffFormCubit = StaffFormCubit();
    _addStaffCubit = AddStaffCubit();
    _prefillFromEdit();
    _initSchoolAndLoad();
  }

  void _prefillFromEdit() {
    final s = widget.editStudent;
    if (s == null) return;

    _whatsapp.text = s.whatsappPhone ?? '';
    _fatherName.text = s.fatherName ?? '';
    _motherName.text = s.motherName ?? '';
    _husbandName.text = s.husbandName ?? '';
    _dob.text = s.dob ?? '';
    _doj.text = s.dateOfJoining ?? '';
    _address.text = s.address ?? '';
    _pincode.text = s.pincode ?? '';
    _employeeId.text = s.employeeId ?? '';
    _nationalCode.text = s.nationalCode ?? '';

    if (s.gender != null) {
      final matched = _kGenderOptions.firstWhere(
        (g) => g.toLowerCase() == s.gender!.toLowerCase(),
        orElse: () => '',
      );
      _selectedGender = matched.isEmpty ? null : matched;
    }

    if (s.bloodGroup != null && _kBloodGroupOptions.contains(s.bloodGroup)) {
      _selectedBloodGroup = s.bloodGroup;
    }

    if (s.roleName.isNotEmpty) {
      _selectValues['role'] = s.roleName;
    }

    if (s.emergencyContacts.isNotEmpty) {
      _emergencyContacts
        ..clear()
        ..addAll(
          s.emergencyContacts.map(
            (c) => _EmergencyContact(
              relation: c.relation,
              name: c.name,
              phone: c.phone,
            ),
          ),
        );
    }
  }

  Future<void> _initSchoolAndLoad() async {
    final school = await UserLocal.getSchool();
    final id = school['schoolId'] ?? '';
    if (id.isNotEmpty) {
      _schoolId = id;
      _staffFormCubit.loadFields(id);
    }
  }

  @override
  void dispose() {
    _staffFormCubit.close();
    _addStaffCubit.close();
    for (final c in _controllers.values) c.dispose();
    for (final c in [
      _whatsapp,
      _fatherName,
      _motherName,
      _husbandName,
      _dob,
      _doj,
      _address,
      _pincode,
      _employeeId,
      _nationalCode,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _ctrl(String name) {
    return _controllers.putIfAbsent(name, () {
      final ctrl = TextEditingController();
      if (_isEditMode) {
        final s = widget.editStudent!;
        switch (name) {
          case 'name':
            ctrl.text = s.name;
            break;
          case 'email':
            ctrl.text = s.email;
            break;
          case 'phone':
            ctrl.text = s.phone;
            break;
          case 'designation':
            ctrl.text = s.designation;
            break;
          case 'department':
            ctrl.text = s.department;
            break;
          case 'login_id':
            ctrl.text = s.loginId ?? '';
            break;
          case 'whatsapp':
            ctrl.text = s.whatsappPhone ?? '';
            break;
        }
      }
      return ctrl;
    });
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

  Widget _twoCol(Widget left, Widget right) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: left),
      const SizedBox(width: 12),
      Expanded(child: right),
    ],
  );

  Widget _dateField(TextEditingController ctrl) => AppTextField(
    controller: ctrl,
    hintText: 'DD.MM.YYYY',
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
      LengthLimitingTextInputFormatter(10),
      _DotDateFormatter(),
    ],
  );

  Widget _stringDropdown(
    String hint,
    List<String> options,
    String? value,
    void Function(String?) onChange,
  ) {
    return Dropdown<String>(
      value: (value != null && options.contains(value)) ? value : null,
      items: options,
      hintText: options.first,
      onChange: onChange,
      displayText: (_, o) => o,
      showClearButton: false,
    );
  }

  Widget _buildDynamicField(StudentFormField field, List<StaffRole> roles) {
    switch (field.type) {
      case 'select':
        if (field.name == 'role') {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label(field.label, required: field.required),
              Dropdown<StaffRole>(
                value: roles.isNotEmpty && _selectValues['role'] != null
                    ? roles.firstWhere(
                        (r) =>
                            r.id.toString() == _selectValues['role'] ||
                            r.name == _selectValues['role'],
                        orElse: () => roles.first,
                      )
                    : null,
                items: roles,
                hintText: '-Select Role-',
                onChange: (r) =>
                    setState(() => _selectValues['role'] = r?.id.toString()),
                displayText: (_, r) => r.name,
                showClearButton: false,
              ),
            ],
          );
        }
        final options = ['-Select-'];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(field.label, required: field.required),
            _stringDropdown(
              options.first,
              options,
              _selectValues[field.name],
              (v) => setState(() => _selectValues[field.name] = v),
            ),
          ],
        );
      case 'phone':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(field.label, required: field.required),
            phoneNumberTextField(
              controller: _ctrl(field.name),
              hintName: '${field.label}...',
            ),
          ],
        );
      case 'email':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(field.label, required: field.required),
            AppTextField(
              controller: _ctrl(field.name),
              hintText: '${field.label}...',
              keyboardType: TextInputType.emailAddress,
              mxLine: 1,
            ),
          ],
        );
      case 'password':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(field.label, required: field.required),
            AppTextField(
              controller: _ctrl(field.name),
              hintText: '••••••••',
              obscureText: true,
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(field.label, required: field.required),
            AppTextField(
              controller: _ctrl(field.name),
              hintText: '${field.label}...',
              mxLine: 1,
            ),
          ],
        );
    }
  }

  List<Widget> _buildDynamicFieldRows(
    List<StudentFormField> fields,
    List<StaffRole> roles,
  ) {
    final rows = <Widget>[];
    for (int i = 0; i < fields.length; i += 2) {
      final left = _buildDynamicField(fields[i], roles);
      final right = i + 1 < fields.length
          ? _buildDynamicField(fields[i + 1], roles)
          : const SizedBox.shrink();
      rows.add(_twoCol(left, right));
      if (i + 2 < fields.length) rows.add(const SizedBox(height: 12));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _staffFormCubit),
        BlocProvider.value(value: _addStaffCubit),
      ],
      child: BlocListener<AddStaffCubit, AddStaffState>(
        listener: (context, state) {
          if (state.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message ??
                      (_isEditMode
                          ? 'Staff updated successfully'
                          : 'Staff added successfully'),
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: _buildScaffold(context),
      ),
    );
  }

  Widget _buildScaffold(BuildContext ctx) {
    return Scaffold(
      backgroundColor: AppTheme.appBackgroundColor,
      appBar: CommonAppBar(
        title: _isEditMode ? 'Edit Staff' : 'Add Staff',
        backgroundColor: Colors.white,
        showText: true,
      ),
      body: BlocBuilder<StaffFormCubit, StaffFormState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _sectionCard(
                          title: 'Staff Details',
                          child: state.loading
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : state.error != null
                              ? Center(
                                  child: Text(
                                    state.error!,
                                    style: MyStyles.regularText(
                                      size: 13,
                                      color: Colors.red,
                                    ),
                                  ),
                                )
                              : Column(
                                  children: _buildDynamicFieldRows(
                                    state.fields,
                                    state.roles,
                                  ),
                                ),
                        ),
                        _sectionCard(
                          title: 'Basic Information',
                          child: Column(
                            children: [
                              _twoCol(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('WhatsApp Number'),
                                    phoneNumberTextField(
                                      controller: _whatsapp,
                                      hintName: 'WhatsApp Number...',
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Father Name'),
                                    AppTextField(
                                      controller: _fatherName,
                                      hintText: 'Father Name...',
                                      mxLine: 1,
                                      textCapitalization:
                                          TextCapitalization.words,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              _twoCol(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Mother Name'),
                                    AppTextField(
                                      controller: _motherName,
                                      hintText: 'Mother Name...',
                                      mxLine: 1,
                                      textCapitalization:
                                          TextCapitalization.words,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Husband Name'),
                                    AppTextField(
                                      controller: _husbandName,
                                      hintText: 'Husband Name...',
                                      mxLine: 1,
                                      textCapitalization:
                                          TextCapitalization.words,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              _twoCol(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Date of Birth'),
                                    _dateField(_dob),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Blood Group'),
                                    _stringDropdown(
                                      'Select Blood Group',
                                      _kBloodGroupOptions,
                                      _selectedBloodGroup,
                                      (v) => setState(
                                        () => _selectedBloodGroup = v,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              _twoCol(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Date of Joining'),
                                    _dateField(_doj),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Gender'),
                                    _stringDropdown(
                                      '-Select Gender-',
                                      _kGenderOptions,
                                      _selectedGender,
                                      (v) =>
                                          setState(() => _selectedGender = v),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Address'),
                                  AppTextField(
                                    controller: _address,
                                    hintText: 'Full address...',
                                    mxLine: 4,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(100),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _twoCol(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Pincode'),
                                    AppTextField(
                                      controller: _pincode,
                                      hintText: '6-digit Pincode',
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(6),
                                      ],
                                      mxLine: 1,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('Employee Id'),
                                    AppTextField(
                                      controller: _employeeId,
                                      hintText: 'Employee Id',
                                      mxLine: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              _twoCol(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label('National Code'),
                                    AppTextField(
                                      controller: _nationalCode,
                                      hintText: 'National Code',
                                      mxLine: 1,
                                    ),
                                  ],
                                ),
                                const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),

                        _sectionCard(
                          title: 'Emergency Contact Details',
                          child: Column(
                            children: [
                              ..._emergencyContacts.asMap().entries.map((
                                entry,
                              ) {
                                final i = entry.key;
                                final contact = entry.value;
                                return _EmergencyContactRow(
                                  contact: contact,
                                  showRemove: _emergencyContacts.length > 1,
                                  onRemove: () => setState(
                                    () => _emergencyContacts.removeAt(i),
                                  ),
                                );
                              }),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () => setState(
                                  () => _emergencyContacts.add(
                                    _EmergencyContact(),
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.btnColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '+ Add Emergency Contact',
                                        style: MyStyles.mediumText(
                                          size: 13,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                        title: 'Cancel',
                        color: AppTheme.backBtnBgColor,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BlocBuilder<AddStaffCubit, AddStaffState>(
                        builder: (context, addState) => AppButton(
                          title: _isEditMode ? 'Update' : 'Add',
                          color: AppTheme.btnColor,
                          isLoading: addState.loading,
                          onTap: () {
                            if (!addState.loading &&
                                (_formKey.currentState?.validate() ?? false)) {
                              _submitForm(context);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _submitForm(BuildContext context) {
    final fields = <String, dynamic>{};

    for (final entry in _controllers.entries) {
      fields[entry.key] = entry.value.text;
    }
    for (final entry in _selectValues.entries) {
      if (entry.value != null) fields[entry.key] = entry.value;
    }

    fields['whatsapp'] = _whatsapp.text;
    fields['father_name'] = _fatherName.text;
    fields['mother_name'] = _motherName.text;
    fields['husband_name'] = _husbandName.text;
    fields['date_of_birth'] = _dob.text;
    fields['date_of_joining'] = _doj.text;
    fields['address'] = _address.text;
    fields['pincode'] = _pincode.text;
    fields['employee_id'] = _employeeId.text;
    fields['national_code'] = _nationalCode.text;
    if (_selectedGender != null) fields['gender'] = _selectedGender;
    if (_selectedBloodGroup != null)
      fields['blood_group'] = _selectedBloodGroup;

    final emergencyContacts = _emergencyContacts
        .where((e) => e.name.isNotEmpty || e.phone.isNotEmpty)
        .map(
          (e) => <String, String>{
            'relation': e.relation,
            'name': e.name,
            'phone': e.phone,
          },
        )
        .toList();

    if (_isEditMode) {
      _addStaffCubit.update(
        schoolId: _schoolId,
        uuid: widget.editStudent!.uuid,
        fields: fields,
        emergencyContacts: emergencyContacts,
      );
    } else {
      _addStaffCubit.submit(
        schoolId: _schoolId,
        fields: fields,
        emergencyContacts: emergencyContacts,
      );
    }
  }
}

class _EmergencyContactRow extends StatefulWidget {
  final _EmergencyContact contact;
  final bool showRemove;
  final VoidCallback onRemove;
  const _EmergencyContactRow({
    required this.contact,
    required this.showRemove,
    required this.onRemove,
  });

  @override
  State<_EmergencyContactRow> createState() => _EmergencyContactRowState();
}

class _EmergencyContactRowState extends State<_EmergencyContactRow> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.contact.name);
    _phoneCtrl = TextEditingController(text: widget.contact.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.appBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.backBtnBgColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Relation',
                      style: MyStyles.mediumText(
                        size: 12,
                        color: AppTheme.black_Color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Dropdown<String>(
                      value: widget.contact.relation.isNotEmpty
                          ? widget.contact.relation
                          : null,
                      items: _kRelationOptions,
                      hintText: '- Select Relation -',
                      onChange: (v) =>
                          setState(() => widget.contact.relation = v ?? ''),
                      displayText: (_, o) => o,
                      showClearButton: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name',
                      style: MyStyles.mediumText(
                        size: 12,
                        color: AppTheme.black_Color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: _nameCtrl,
                      hintText: 'Enter full name',
                      mxLine: 1,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (v) => widget.contact.name = v,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phone',
                      style: MyStyles.mediumText(
                        size: 12,
                        color: AppTheme.black_Color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: _phoneCtrl,
                      hintText: '10-digit phone number',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      mxLine: 1,
                      onChanged: (v) => widget.contact.phone = v,
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
          if (widget.showRemove) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: widget.onRemove,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.redBtnBgColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 14,
                        color: AppTheme.redBtnBgColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Remove',
                        style: MyStyles.regularText(
                          size: 12,
                          color: AppTheme.redBtnBgColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DotDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '.').replaceAll('-', '.');
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
