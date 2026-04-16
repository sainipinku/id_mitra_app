import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/components/text_filed.dart';
import 'package:idmitra/utils/common_widgets/app_button.dart';
import 'package:idmitra/utils/common_widgets/drop_down/drop_down.dart';

const List<String> _kRoleOptions = ['-Select Role-', 'Teacher', 'Principal', 'Vice Principal', 'Librarian', 'Accountant', 'Peon', 'Guard', 'Other'];
const List<String> _kGenderOptions = ['-Select Gender-', 'Male', 'Female', 'Transgender'];
const List<String> _kBloodGroupOptions = ['Select Blood Group', 'A+', 'A-', 'AB+', 'AB-', 'B+', 'B-', 'O+', 'O-'];
const List<String> _kRelationOptions = ['- Select Relation -', 'Father', 'Mother', 'Spouse', 'Sibling', 'Friend', 'Other'];

class _EmergencyContact {
  String relation;
  String name;
  String phone;
  _EmergencyContact({this.relation = '', this.name = '', this.phone = ''});
}

class AddStaffFormPage extends StatefulWidget {
  const AddStaffFormPage({super.key});

  @override
  State<AddStaffFormPage> createState() => _AddStaffFormPageState();
}

class _AddStaffFormPageState extends State<AddStaffFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _designation = TextEditingController();
  final _department = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
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
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  String? _selectedRole;
  String? _selectedGender;
  String? _selectedBloodGroup;

  final List<_EmergencyContact> _emergencyContacts = [_EmergencyContact()];

  @override
  void dispose() {
    for (final c in [_designation, _department, _name, _phone, _email, _whatsapp,
        _fatherName, _motherName, _husbandName, _dob, _doj, _address, _pincode,
        _employeeId, _nationalCode, _password, _confirmPassword]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _label(String text, {bool required = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 4),
        child: RichText(
          text: TextSpan(
            text: text,
            style: MyStyles.mediumText(size: 13, color: AppTheme.black_Color),
            children: required
                ? [TextSpan(text: ' *', style: MyStyles.mediumText(size: 13, color: Colors.red))]
                : [],
          ),
        ),
      );

  Widget _sectionCard({required String title, required Widget child}) => Container(
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
              child: Text(title, style: MyStyles.boldText(size: 15, color: AppTheme.black_Color)),
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

  Widget _stringDropdown(String hint, List<String> options, String? value, void Function(String?) onChange) {
    return Dropdown<String>(
      value: (value != null && options.contains(value)) ? value : null,
      items: options,
      hintText: options.first,
      onChange: onChange,
      displayText: (_, o) => o,
      showClearButton: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.appBackgroundColor,
      appBar: CommonAppBar(
        title: 'Add Staff',
        backgroundColor: Colors.white,
        showText: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ── Basic Info ──────────────────────────────────────
                    _sectionCard(
                      title: 'Basic Information',
                      child: Column(
                        children: [
                          _twoCol(
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('Designation'),
                              AppTextField(controller: _designation, hintText: 'Designation...', mxLine: 1),
                            ]),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('Department'),
                              AppTextField(controller: _department, hintText: 'Department...', mxLine: 1),
                            ]),
                          ),
                          const SizedBox(height: 12),
                          _twoCol(
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('Name', required: true),
                              AppTextField(controller: _name, hintText: 'Name...', mxLine: 1, textCapitalization: TextCapitalization.words),
                            ]),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('Phone'),
                              phoneNumberTextField(controller: _phone, hintName: 'Phone...'),
                            ]),
                          ),
                          const SizedBox(height: 12),
                          _twoCol(
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('Email'),
                              AppTextField(controller: _email, hintText: 'Email...', keyboardType: TextInputType.emailAddress, mxLine: 1),
                            ]),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('Select Your Role', required: true),
                              _stringDropdown('-Select Role-', _kRoleOptions, _selectedRole,
                                  (v) => setState(() => _selectedRole = v)),
                            ]),
                          ),
                          const SizedBox(height: 12),
                          _twoCol(
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('WhatsApp Number'),
                              phoneNumberTextField(controller: _whatsapp, hintName: 'WhatsApp Number...'),
                            ]),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('Father Name'),
                              AppTextField(controller: _fatherName, hintText: 'Father Name...', mxLine: 1, textCapitalization: TextCapitalization.words),
                            ]),
                          ),
                          const SizedBox(height: 12),
                          _twoCol(
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('Mother Name'),
                              AppTextField(controller: _motherName, hintText: 'Mother Name...', mxLine: 1, textCapitalization: TextCapitalization.words),
                            ]),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('Husband Name'),
                              AppTextField(controller: _husbandName, hintText: 'Husband Name...', mxLine: 1, textCapitalization: TextCapitalization.words),
                            ]),
                          ),
                          const SizedBox(height: 12),
                          _twoCol(
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('Date of Birth'),
                              _dateField(_dob),
                            ]),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('Blood Group'),
                              _stringDropdown('Select Blood Group', _kBloodGroupOptions, _selectedBloodGroup,
                                  (v) => setState(() => _selectedBloodGroup = v)),
                            ]),
                          ),
                          const SizedBox(height: 12),
                          _twoCol(
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('Date of Joining'),
                              _dateField(_doj),
                            ]),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('Gender'),
                              _stringDropdown('Select Gender', _kGenderOptions, _selectedGender,
                                  (v) => setState(() => _selectedGender = v)),
                            ]),
                          ),
                          const SizedBox(height: 12),
                          // Address full width (textarea like AddStudentFormPage)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Address'),
                              AppTextField(
                                controller: _address,
                                hintText: 'Full address...',
                                mxLine: 4,
                                inputFormatters: [LengthLimitingTextInputFormatter(100)],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _twoCol(
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('Pincode'),
                              AppTextField(controller: _pincode, hintText: '6-digit Pincode', keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)], mxLine: 1),
                            ]),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('Employee Id'),
                              AppTextField(controller: _employeeId, hintText: 'Employee Id', mxLine: 1),
                            ]),
                          ),
                          const SizedBox(height: 12),
                          _twoCol(
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('National Code'),
                              AppTextField(controller: _nationalCode, hintText: 'National Code', mxLine: 1),
                            ]),
                            const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 12),
                          _twoCol(
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('Password'),
                              AppTextField(controller: _password, hintText: '••••••••', obscureText: true),
                            ]),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _label('Confirm Password'),
                              AppTextField(controller: _confirmPassword, hintText: '••••••••', obscureText: true),
                            ]),
                          ),
                        ],
                      ),
                    ),

                    // ── Emergency Contact ───────────────────────────────
                    _sectionCard(
                      title: 'Emergency Contact Details',
                      child: Column(
                        children: [
                          ..._emergencyContacts.asMap().entries.map((entry) {
                            final i = entry.key;
                            final contact = entry.value;
                            return _EmergencyContactRow(
                              contact: contact,
                              showRemove: _emergencyContacts.length > 1,
                              onRemove: () => setState(() => _emergencyContacts.removeAt(i)),
                            );
                          }),
                          const SizedBox(height: 12),
                          // Add Emergency Contact button
                          GestureDetector(
                            onTap: () => setState(() => _emergencyContacts.add(_EmergencyContact())),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.btnColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text('+ Add Emergency Contact',
                                      style: MyStyles.mediumText(size: 13, color: Colors.white)),
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

          // ── Bottom buttons ──────────────────────────────────────────────
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
                  child: AppButton(
                    title: 'Add',
                    color: AppTheme.btnColor,
                    onTap: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Staff added successfully'), backgroundColor: Colors.green),
                        );
                        Navigator.pop(context);
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
  }
}

// ─── Emergency Contact Row ────────────────────────────────────────────────────
class _EmergencyContactRow extends StatefulWidget {
  final _EmergencyContact contact;
  final bool showRemove;
  final VoidCallback onRemove;
  const _EmergencyContactRow({required this.contact, required this.showRemove, required this.onRemove});

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
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Relation', style: MyStyles.mediumText(size: 12, color: AppTheme.black_Color)),
                  const SizedBox(height: 6),
                  Dropdown<String>(
                    value: widget.contact.relation.isNotEmpty ? widget.contact.relation : null,
                    items: _kRelationOptions,
                    hintText: '- Select Relation -',
                    onChange: (v) => setState(() => widget.contact.relation = v ?? ''),
                    displayText: (_, o) => o,
                    showClearButton: false,
                  ),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Name', style: MyStyles.mediumText(size: 12, color: AppTheme.black_Color)),
                  const SizedBox(height: 6),
                  AppTextField(
                    controller: _nameCtrl,
                    hintText: 'Enter full name',
                    mxLine: 1,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (v) => widget.contact.name = v,
                  ),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Phone', style: MyStyles.mediumText(size: 12, color: AppTheme.black_Color)),
                  const SizedBox(height: 6),
                  AppTextField(
                    controller: _phoneCtrl,
                    hintText: '10-digit phone number',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                    mxLine: 1,
                    onChanged: (v) => widget.contact.phone = v,
                  ),
                ]),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.redBtnBgColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline, size: 14, color: AppTheme.redBtnBgColor),
                      const SizedBox(width: 4),
                      Text('Remove', style: MyStyles.regularText(size: 12, color: AppTheme.redBtnBgColor)),
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

// ─── Date formatter ───────────────────────────────────────────────────────────
class _DotDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('/', '.').replaceAll('-', '.');
    return newValue.copyWith(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
