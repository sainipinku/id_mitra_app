import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/Widgets/shimmer_loader.dart';
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
  final StaffDetailModel? editStaff;
  final String schoolId;
  const AddStaffFormPage({super.key, this.editStaff, this.schoolId = ''});

  @override
  State<AddStaffFormPage> createState() => _AddStaffFormPageState();
}

class _AddStaffFormPageState extends State<AddStaffFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final StaffFormCubit _staffFormCubit;
  late final AddStaffCubit _addStaffCubit;
  String _schoolId = '';
  StreamSubscription<StaffFormState>? _formFieldsSub;

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

  final Map<String, bool> _obscureMap = {};

  bool _additionalExpanded = false;
  bool _basicInfoExpanded = false;

  final List<_EmergencyContact> _emergencyContacts = [_EmergencyContact()];

  @override
  void initState() {
    super.initState();
    _staffFormCubit = StaffFormCubit();
    _addStaffCubit = AddStaffCubit();
    if (widget.editStaff != null) {
      _basicInfoExpanded = true;
    }
    _initSchoolAndLoad();
  }

  Future<void> _initSchoolAndLoad() async {
    String id = widget.schoolId;

    if (id.isEmpty) {
      final school = await UserLocal.getSchool();
      id = school['schoolId'] ?? '';
    }

    if (id.isNotEmpty) {
      _schoolId = id;

      _formFieldsSub = _staffFormCubit.stream.listen((state) {
        if (!state.loading && state.fields.isNotEmpty) {
          for (final c in _controllers.values) {
            c.dispose();
          }
          _controllers.clear();
          _selectValues.clear();
          _prefillDynamicFields(state.roles);
          _formFieldsSub?.cancel();
        }
      });
      await _staffFormCubit.loadFields(id);
      final currentState = _staffFormCubit.state;
      if (!currentState.loading && currentState.fields.isNotEmpty) {
        for (final c in _controllers.values) {
          c.dispose();
        }
        _controllers.clear();
        _selectValues.clear();
        _prefillDynamicFields(currentState.roles);
        _formFieldsSub?.cancel();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('School ID not found. Please select a school first.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    final e = widget.editStaff;
    if (e != null) {
      _whatsapp.text = e.whatsappPhone ?? '';
      _fatherName.text = e.fatherName ?? '';
      _motherName.text = e.motherName ?? '';
      _husbandName.text = e.husbandName ?? '';
      _dob.text = e.dob ?? '';
      _doj.text = e.dateOfJoining ?? '';
      _address.text = e.address ?? '';
      _pincode.text = e.pincode ?? '';
      _employeeId.text = e.employeeId ?? '';
      _nationalCode.text = e.nationalCode ?? '';
      if (e.gender != null) {
        final g =
            e.gender![0].toUpperCase() + e.gender!.substring(1).toLowerCase();
        if (_kGenderOptions.contains(g)) setState(() => _selectedGender = g);
      }
      if (e.bloodGroup != null && _kBloodGroupOptions.contains(e.bloodGroup)) {
        setState(() => _selectedBloodGroup = e.bloodGroup);
      }
      if (e.roleId != null) {
        _selectValues['role'] = e.roleId.toString();
      }
      if (e.emergencyContacts.isNotEmpty) {
        _emergencyContacts.clear();
        for (final c in e.emergencyContacts) {
          _emergencyContacts.add(
            _EmergencyContact(
              relation: c.relation,
              name: c.name,
              phone: c.phone,
            ),
          );
        }
      }
    }
  }

  void _prefillDynamicFields(List<StaffRole> roles) {
    final e = widget.editStaff;
    if (e == null) return;

    final Map<String, String> staffFieldMap = {
      'name': e.name,
      'email': e.email,
      'phone': e.phone,
      'designation': e.designation,
      'department': e.department,
      'login_id': e.loginId ?? '',
    };

    bool changed = false;
    for (final entry in staffFieldMap.entries) {
      if (entry.value.isNotEmpty) {
        _ctrl(entry.key).text = entry.value;
        changed = true;
      }
    }

    if (roles.isNotEmpty && _selectValues['role'] == null) {
      StaffRole? matchedRole;
      if (e.roleId != null) {
        try {
          matchedRole = roles.firstWhere((r) => r.id == e.roleId);
        } catch (_) {}
      }
      if (matchedRole == null && e.roleName.isNotEmpty) {
        try {
          matchedRole = roles.firstWhere(
            (r) => r.name.toLowerCase() == e.roleName.toLowerCase(),
          );
        } catch (_) {}
      }
      if (matchedRole != null) {
        _selectValues['role'] = matchedRole.id.toString();
        changed = true;
      }
    }

    if (changed && mounted) setState(() {});
  }

  @override
  void dispose() {
    _formFieldsSub?.cancel();
    _staffFormCubit.close();
    _addStaffCubit.close();
    for (final c in _controllers.values) {
      c.dispose();
    }
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
    return _controllers.putIfAbsent(name, () => TextEditingController());
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
      FilteringTextInputFormatter.allow(RegExp(r'[\d.\-/]')),
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

  Widget _buildFullShimmer() {
    Widget shimmerField() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        shimmerBox(height: 12, width: 90),
        const SizedBox(height: 8),
        shimmerBox(height: 48, radius: 10),
      ],
    );

    Widget shimmerRow() => Row(
      children: [
        Expanded(child: shimmerField()),
        const SizedBox(width: 12),
        Expanded(child: shimmerField()),
      ],
    );

    Widget shimmerSection(String title, int rowCount) => Container(
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
            child: shimmerBox(height: 14, width: 120),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: List.generate(
                rowCount,
                (i) => Padding(
                  padding: EdgeInsets.only(bottom: i < rowCount - 1 ? 14 : 0),
                  child: shimmerRow(),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      children: [
        shimmerSection('Main Information', 4),
        shimmerSection('Basic Information', 5),
        shimmerSection('Emergency Contact Details', 2),
      ],
    );
  }

  bool _isObscure(String key) => _obscureMap[key] ?? true;

  Widget _visibilityToggle(String key) => IconButton(
    icon: Icon(
      _isObscure(key)
          ? Icons.visibility_off_outlined
          : Icons.visibility_outlined,
      size: 20,
      color: AppTheme.graySubTitleColor,
    ),
    onPressed: () => setState(() => _obscureMap[key] = !_isObscure(key)),
  );

  Widget _buildDynamicField(StudentFormField field, List<StaffRole> roles) {
    final isPasswordField =
        field.type == 'password' ||
        field.name.toLowerCase().contains('password');

    if (isPasswordField) {
      final isConfirm =
          field.name.toLowerCase().contains('confirm') ||
          field.name == 'password_confirmation';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(field.label, required: field.required),
          AppTextField(
            controller: _ctrl(field.name),
            hintText: '••••••••',
            obscureText: _isObscure(field.name),
            suffixIcon: _visibilityToggle(field.name),
            validator: field.required
                ? (v) {
                    if (v == null || v.trim().isEmpty) {
                      return '${field.label} is required';
                    }
                    if (isConfirm) {
                      final pwCtrl = _controllers.entries
                          .firstWhere(
                            (e) =>
                                e.key.toLowerCase().contains('password') &&
                                !e.key.toLowerCase().contains('confirm') &&
                                e.key != 'password_confirmation',
                            orElse: () => MapEntry('', TextEditingController()),
                          )
                          .value;
                      if (v != pwCtrl.text) return 'Passwords do not match';
                    }
                    return null;
                  }
                : null,
          ),
        ],
      );
    }

    if (field.type == 'select') {
      if (field.name == 'role') {
        if (roles.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label(field.label, required: field.required),
              AppTextField(
                controller: _ctrl(field.name),
                hintText: '${field.label}...',
                mxLine: 1,
                validator: field.required
                    ? (v) => (v == null || v.trim().isEmpty)
                          ? '${field.label} is required'
                          : null
                    : null,
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(field.label, required: field.required),
            Dropdown<StaffRole>(
              value: () {
                if (_selectValues['role'] == null) return null;
                try {
                  return roles.firstWhere(
                    (r) => r.id.toString() == _selectValues['role'],
                  );
                } catch (_) {
                  return null;
                }
              }(),
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(field.label, required: field.required),
          _stringDropdown(
            '-Select-',
            ['-Select-'],
            _selectValues[field.name],
            (v) => setState(() => _selectValues[field.name] = v),
          ),
        ],
      );
    }

    if (field.type == 'phone') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(field.label, required: field.required),
          AppTextField(
            controller: _ctrl(field.name),
            hintText: '${field.label}...',
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
              FilteringTextInputFormatter.digitsOnly,
            ],
            mxLine: 1,
            validator: field.required
                ? (v) => (v == null || v.trim().isEmpty)
                      ? '${field.label} is required'
                      : null
                : null,
          ),
        ],
      );
    }

    if (field.type == 'email') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(field.label, required: field.required),
          AppTextField(
            controller: _ctrl(field.name),
            hintText: '${field.label}...',
            keyboardType: TextInputType.emailAddress,
            mxLine: 1,
            validator: field.required
                ? (v) => (v == null || v.trim().isEmpty)
                      ? '${field.label} is required'
                      : null
                : null,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(field.label, required: field.required),
        AppTextField(
          controller: _ctrl(field.name),
          hintText: '${field.label}...',
          mxLine: 1,
          validator: field.required
              ? (v) => (v == null || v.trim().isEmpty)
                    ? '${field.label} is required'
                    : null
              : null,
        ),
      ],
    );
  }

  List<Widget> _buildStaticMainFields(List<StudentFormField> apiFields) {
    bool has(String name) => apiFields.any((f) => f.name == name);

    final showEmployeeId = !has('employee_id');
    final showAddress = !has('address');
    final showDob = !has('date_of_birth');
    final showFatherName = !has('father_name');

    final rows = <Widget>[];

    if (showEmployeeId || showAddress) {
      if (apiFields.isNotEmpty) rows.add(const SizedBox(height: 12));
      rows.add(
        _twoCol(
          showEmployeeId
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Employee Id'),
                    AppTextField(
                      controller: _employeeId,
                      hintText: 'Employee Id',
                      mxLine: 1,
                    ),
                  ],
                )
              : const SizedBox.shrink(),
          showAddress
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Address'),
                    AppTextField(
                      controller: _address,
                      hintText: 'Full address...',
                      mxLine: 2,
                      inputFormatters: [LengthLimitingTextInputFormatter(100)],
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      );
    }

    if (showDob || showFatherName) {
      rows.add(const SizedBox(height: 12));
      rows.add(
        _twoCol(
          showDob
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_label('Date of Birth'), _dateField(_dob)],
                )
              : const SizedBox.shrink(),
          showFatherName
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Father Name'),
                    AppTextField(
                      controller: _fatherName,
                      hintText: 'Father Name...',
                      mxLine: 1,
                      textCapitalization: TextCapitalization.words,
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      );
    }

    return rows;
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

  Widget _twoColGrid(List<StudentFormField> fields, List<StaffRole> roles) {
    final groupOrder = <String>[];
    final groups = <String, List<StudentFormField>>{};
    for (final f in fields) {
      final key = f.groupLabel.isNotEmpty ? f.groupLabel : 'Details';
      if (!groups.containsKey(key)) groupOrder.add(key);
      groups.putIfAbsent(key, () => []).add(f);
    }

    final sections = <Widget>[];
    final hasMultipleGroups = groupOrder.length > 1;

    for (final groupLabel in groupOrder) {
      final groupFields = groups[groupLabel]!;

      if (hasMultipleGroups && sections.isNotEmpty) {
        sections.add(const SizedBox(height: 4));
        sections.add(const Divider());
        sections.add(const SizedBox(height: 4));
      }
      if (hasMultipleGroups) {
        sections.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              groupLabel,
              style: MyStyles.boldText(
                size: 13,
                color: AppTheme.graySubTitleColor,
              ),
            ),
          ),
        );
      }

      int i = 0;
      while (i < groupFields.length) {
        final f = groupFields[i];
        if (f.type == 'textarea') {
          sections.add(_buildDynamicField(f, roles));
          sections.add(const SizedBox(height: 12));
          i++;
        } else {
          final hasNext =
              i + 1 < groupFields.length &&
              groupFields[i + 1].type != 'textarea';
          final next = hasNext ? groupFields[i + 1] : null;
          sections.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildDynamicField(f, roles)),
                if (next != null) ...[
                  const SizedBox(width: 12),
                  Expanded(child: _buildDynamicField(next, roles)),
                ] else
                  const Expanded(child: SizedBox()),
              ],
            ),
          );
          sections.add(const SizedBox(height: 12));
          i += next != null ? 2 : 1;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections,
    );
  }

  Widget _additionalCollapsible(
    List<StudentFormField> fields,
    List<StaffRole> roles,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.backBtnBgColor),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () =>
                setState(() => _additionalExpanded = !_additionalExpanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Additional Information',
                      style: MyStyles.boldText(
                        size: 15,
                        color: AppTheme.black_Color,
                      ),
                    ),
                  ),
                  Icon(
                    _additionalExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppTheme.graySubTitleColor,
                  ),
                ],
              ),
            ),
          ),
          if (_additionalExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _twoColGrid(fields, roles),
            ),
          ],
        ],
      ),
    );
  }

  Widget _basicInfoCollapsible() {
    final content = Column(
      children: [
        _twoCol(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('WhatsApp Number'),
              AppTextField(
                controller: _whatsapp,
                hintText: 'WhatsApp Number...',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                mxLine: 1,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Mother Name'),
              AppTextField(
                controller: _motherName,
                hintText: 'Mother Name...',
                mxLine: 1,
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _twoCol(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Husband Name'),
              AppTextField(
                controller: _husbandName,
                hintText: 'Husband Name...',
                mxLine: 1,
                textCapitalization: TextCapitalization.words,
              ),
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
                (v) => setState(() => _selectedBloodGroup = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _twoCol(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_label('Date of Joining'), _dateField(_doj)],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Gender'),
              _stringDropdown(
                '-Select Gender-',
                _kGenderOptions,
                _selectedGender,
                (v) => setState(() => _selectedGender = v),
              ),
            ],
          ),
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
              _label('National Code'),
              AppTextField(
                controller: _nationalCode,
                hintText: 'National Code',
                mxLine: 1,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Emergency Contact Details',
            style: MyStyles.boldText(size: 14, color: AppTheme.black_Color),
          ),
        ),
        const SizedBox(height: 10),
        ..._emergencyContacts.asMap().entries.map((entry) {
          final i = entry.key;
          final contact = entry.value;
          return _EmergencyContactRow(
            contact: contact,
            showRemove: _emergencyContacts.length > 1,
            onRemove: () => setState(() => _emergencyContacts.removeAt(i)),
          );
        }),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () =>
              setState(() => _emergencyContacts.add(_EmergencyContact())),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  style: MyStyles.mediumText(size: 13, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.backBtnBgColor),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () =>
                setState(() => _basicInfoExpanded = !_basicInfoExpanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Basic Information',
                      style: MyStyles.boldText(
                        size: 15,
                        color: AppTheme.black_Color,
                      ),
                    ),
                  ),
                  Icon(
                    _basicInfoExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppTheme.graySubTitleColor,
                  ),
                ],
              ),
            ),
          ),
          if (_basicInfoExpanded) ...[
            const Divider(height: 1),
            Padding(padding: const EdgeInsets.all(16), child: content),
          ],
        ],
      ),
    );
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
                      (widget.editStaff != null
                          ? 'Staff updated successfully'
                          : 'Staff added successfully'),
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(
              context,
              widget.editStaff != null ? state.updatedStaff : true,
            );
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
        title: widget.editStaff != null ? 'Edit Staff' : 'Add Staff',
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
                  child: state.loading
                      ? _buildFullShimmer()
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
                      : Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _sectionCard(
                                title: 'Main Information',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (state.fields.isNotEmpty)
                                      _twoColGrid(state.fields, state.roles),
                                    ..._buildStaticMainFields(state.fields),
                                    if (state.fields.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          'No dynamic fields configured.',
                                          style: MyStyles.regularText(
                                            size: 12,
                                            color: AppTheme.graySubTitleColor,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              if (() {
                                final additionalFields = state.availableFields
                                    .where(
                                      (f) => !state.fields.any(
                                        (c) => c.name == f.name,
                                      ),
                                    )
                                    .toList();
                                return additionalFields.isNotEmpty;
                              }())
                                Builder(
                                  builder: (ctx) {
                                    final additionalFields = state
                                        .availableFields
                                        .where(
                                          (f) => !state.fields.any(
                                            (c) => c.name == f.name,
                                          ),
                                        )
                                        .toList();
                                    return _additionalCollapsible(
                                      additionalFields,
                                      state.roles,
                                    );
                                  },
                                ),

                              _basicInfoCollapsible(),
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
                        builder: (context, addState) =>
                            BlocBuilder<StaffFormCubit, StaffFormState>(
                              builder: (context, formState) => AppButton(
                                title: widget.editStaff != null
                                    ? 'Update'
                                    : 'Add',
                                color: AppTheme.btnColor,
                                isLoading: addState.loading,
                                onTap: () {
                                  if (addState.loading) return;

                                  if (formState.fields.isEmpty) {
                                    _submitForm(context);
                                  } else {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      _submitForm(context);
                                    }
                                  }
                                },
                              ),
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
    if (_schoolId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('School ID not found. Cannot add staff.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }


    String? roleId = _selectValues['role'];

    if (roleId == null || roleId.isEmpty) {
      final roles = _staffFormCubit.state.roles;
      final e = widget.editStaff;

      if (e != null) {
        if (e.roleId != null) {
          roleId = e.roleId.toString();
        }
        if ((roleId == null || roleId.isEmpty) &&
            e.roleName.isNotEmpty &&
            roles.isNotEmpty) {
          try {
            final matched = roles.firstWhere(
              (r) => r.name.toLowerCase() == e.roleName.toLowerCase(),
            );
            roleId = matched.id.toString();
          } catch (_) {}
        }
      }
      if ((roleId == null || roleId.isEmpty) && roles.length == 1) {
        roleId = roles.first.id.toString();
      }
    }


    final hasStaffDetailsFields = _staffFormCubit.state.fields.isNotEmpty;

    if (hasStaffDetailsFields && (roleId == null || roleId.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a role'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final fields = <String, dynamic>{};

    for (final entry in _controllers.entries) {
      if (entry.key == 'role') continue;
      fields[entry.key] = entry.value.text;
    }
    if (roleId != null && roleId.isNotEmpty) {
      fields['role'] = roleId;
    }
    for (final entry in _selectValues.entries) {
      if (entry.key == 'role') continue;
      if (entry.value != null) fields[entry.key] = entry.value;
    }

    final apiFieldNames = _staffFormCubit.state.fields
        .map((f) => f.name)
        .toSet();
    fields['whatsapp'] = _whatsapp.text;
    fields['mother_name'] = _motherName.text;
    fields['husband_name'] = _husbandName.text;
    fields['date_of_joining'] = _doj.text;
    fields['pincode'] = _pincode.text;
    fields['national_code'] = _nationalCode.text;
    if (!apiFieldNames.contains('father_name')) {
      fields['father_name'] = _fatherName.text;
    }
    if (!apiFieldNames.contains('date_of_birth')) {
      fields['date_of_birth'] = _dob.text;
    }
    if (!apiFieldNames.contains('address')) fields['address'] = _address.text;
    if (!apiFieldNames.contains('employee_id')) {
      fields['employee_id'] = _employeeId.text;
    }
    if (_selectedGender != null) fields['gender'] = _selectedGender;
    if (_selectedBloodGroup != null) {
      fields['blood_group'] = _selectedBloodGroup;
    }

    for (int i = 0; i < _emergencyContacts.length; i++) {
      final ec = _emergencyContacts[i];
      if (ec.name.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Emergency Contact ${i + 1}: Name is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (ec.phone.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Emergency Contact ${i + 1}: Phone is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (ec.phone.trim().length < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Emergency Contact ${i + 1}: Enter valid 10-digit phone number',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final emergencyContacts = _emergencyContacts
        .map(
          (e) => {
            'relation': e.relation,
            'name': e.name.trim(),
            'phone': e.phone.trim(),
          },
        )
        .toList();

    if (widget.editStaff != null) {
      _addStaffCubit.update(
        schoolId: _schoolId,
        uuid: widget.editStaff!.uuid,
        fields: fields,
        emergencyContacts: emergencyContacts,
        roleId: roleId,
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
                    RichText(
                      text: TextSpan(
                        text: 'Name',
                        style: MyStyles.mediumText(
                          size: 12,
                          color: AppTheme.black_Color,
                        ),
                        children: [
                          TextSpan(
                            text: ' *',
                            style: MyStyles.mediumText(
                              size: 12,
                              color: Colors.red,
                            ),
                          ),
                        ],
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
                    RichText(
                      text: TextSpan(
                        text: 'Phone',
                        style: MyStyles.mediumText(
                          size: 12,
                          color: AppTheme.black_Color,
                        ),
                        children: [
                          TextSpan(
                            text: ' *',
                            style: MyStyles.mediumText(
                              size: 12,
                              color: Colors.red,
                            ),
                          ),
                        ],
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
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 8) digits = digits.substring(0, 8);

    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) formatted += '.';
      formatted += digits[i];
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
