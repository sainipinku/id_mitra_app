import 'package:flutter/material.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/utils/common_widgets/app_button.dart';

class StudentForm extends StatefulWidget {
  const StudentForm({super.key});

  @override
  State<StudentForm> createState() => _StudentFormState();
}

class _FieldItem {
  final String name;
  final String type;
  final IconData icon;
  bool isRequired;
  bool isSelected;

  _FieldItem({
    required this.name,
    required this.type,
    required this.icon,
    this.isRequired = false,
    this.isSelected = true,
  });
}

class _StudentFormState extends State<StudentForm> {
  final List<_FieldItem> _allFields = [
    _FieldItem(
      name: "Student Name",
      type: "text",
      icon: Icons.person,
      isRequired: true,
    ),
    _FieldItem(
      name: "Father Name",
      type: "text",
      icon: Icons.face,
      isRequired: false,
    ),
    _FieldItem(
      name: "Date of Birth",
      type: "date",
      icon: Icons.cake,
      isRequired: false,
    ),
    _FieldItem(
      name: "Session",
      type: "select",
      icon: Icons.calendar_month,
      isRequired: true,
    ),
    _FieldItem(
      name: "Class",
      type: "select",
      icon: Icons.menu_book,
      isRequired: true,
    ),
    _FieldItem(
      name: "Class Section",
      type: "select",
      icon: Icons.crop_square,
      isRequired: false,
    ),
    _FieldItem(
      name: "Father Phone",
      type: "phone",
      icon: Icons.phone_android,
      isRequired: false,
    ),
    _FieldItem(
      name: "Address",
      type: "text",
      icon: Icons.location_on,
      isRequired: false,
    ),
    _FieldItem(
      name: "Password",
      type: "text",
      icon: Icons.lock,
      isRequired: false,
    ),
    _FieldItem(
      name: "Confirm Password",
      type: "text",
      icon: Icons.lock_outline,
      isRequired: false,
    ),
  ];

  final List<_FieldItem> _availableFields = [
    _FieldItem(
      name: "Student Email",
      type: "email",
      icon: Icons.email,
      isSelected: false,
    ),
    _FieldItem(
      name: "Aadhar Card Number",
      type: "digits",
      icon: Icons.credit_card,
      isSelected: false,
    ),
    _FieldItem(
      name: "UID Number",
      type: "text",
      icon: Icons.badge,
      isSelected: false,
    ),
    _FieldItem(
      name: "Student Photo",
      type: "file",
      icon: Icons.photo_camera,
      isSelected: false,
    ),
    _FieldItem(
      name: "Student Signature",
      type: "file",
      icon: Icons.draw,
      isSelected: false,
    ),
    _FieldItem(
      name: "NIC ID",
      type: "text",
      icon: Icons.phone_android,
      isSelected: false,
    ),
    _FieldItem(
      name: "Caste",
      type: "text",
      icon: Icons.label,
      isSelected: false,
    ),
    _FieldItem(
      name: "Religion",
      type: "text",
      icon: Icons.church,
      isSelected: false,
    ),
    _FieldItem(
      name: "Blood Group",
      type: "select",
      icon: Icons.bloodtype,
      isSelected: false,
    ),
    _FieldItem(
      name: "Mother Name",
      type: "text",
      icon: Icons.face_3,
      isSelected: false,
    ),
  ];

  List<_FieldItem> get _currentFields =>
      _allFields.where((f) => f.isSelected).toList();

  void _openAddFields(StateSetter setSheetState, List<_FieldItem> tempFields) {
    final TextEditingController searchController = TextEditingController();
    List<_FieldItem> filteredFields = List.from(_availableFields);
    final Set<int> selectedIndexes = {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (context, setAddState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Add Multiple Fields",
                                style: MyStyles.boldText(
                                  size: 16,
                                  color: AppTheme.black_Color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Select one or more fields to add to the student registration form",
                                style: MyStyles.regularText(
                                  size: 12,
                                  color: AppTheme.graySubTitleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.black),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Search Fields",
                          style: MyStyles.regularText(
                            size: 13,
                            color: AppTheme.black_Color,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: searchController,
                          style: MyStyles.regularText(
                            size: 14,
                            color: AppTheme.black_Color,
                          ),
                          onChanged: (value) {
                            setAddState(() {
                              filteredFields = _availableFields
                                  .where(
                                    (f) => f.name.toLowerCase().contains(
                                      value.toLowerCase(),
                                    ),
                                  )
                                  .toList();
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppTheme.whiteColor,
                            contentPadding: const EdgeInsets.all(12),
                            hintText: 'Search by field name...',
                            prefixIcon: const Icon(Icons.search),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppTheme.backBtnBgColor,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppTheme.backBtnBgColor,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            hintStyle: MyStyles.regularText(
                              size: 14,
                              color: AppTheme.graySubTitleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredFields.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final field = filteredFields[index];
                        final isChecked = selectedIndexes.contains(index);
                        return GestureDetector(
                          onTap: () {
                            setAddState(() {
                              if (isChecked) {
                                selectedIndexes.remove(index);
                              } else {
                                selectedIndexes.add(index);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.backBtnBgColor),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: isChecked,
                                    activeColor: AppTheme.redBtnBgColor,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    onChanged: (val) {
                                      setAddState(() {
                                        if (val == true) {
                                          selectedIndexes.add(index);
                                        } else {
                                          selectedIndexes.remove(index);
                                        }
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.drag_indicator, color: Colors.grey, size: 20),
                                const SizedBox(width: 6),
                                Icon(field.icon, size: 18, color: AppTheme.graySubTitleColor),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    field.name,
                                    style: MyStyles.boldText(size: 13, color: AppTheme.black_Color),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.appBackgroundColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppTheme.backBtnBgColor),
                                  ),
                                  child: Text(
                                    field.type,
                                    style: MyStyles.regularText(size: 10, color: AppTheme.graySubTitleColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppButton(
                            title: "+ Add Fields",
                            isLoading: false,
                            color: selectedIndexes.isEmpty
                                ? AppTheme.backBtnBgColor
                                : AppTheme.btnColor,
                            onTap: selectedIndexes.isEmpty
                                ? () {}
                                : () {
                                    setSheetState(() {
                                      for (final i in selectedIndexes) {
                                        final f = filteredFields[i];
                                        final alreadyExists = tempFields.any(
                                          (t) => t.name == f.name,
                                        );
                                        if (!alreadyExists) {
                                          tempFields.add(
                                            _FieldItem(
                                              name: f.name,
                                              type: f.type,
                                              icon: f.icon,
                                              isRequired: false,
                                              isSelected: true,
                                            ),
                                          );
                                        }
                                      }
                                    });
                                    Navigator.pop(context);
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
      },
    );
  }

  void _openConfigure() {
    final List<_FieldItem> tempFields = _allFields
        .map(
          (f) => _FieldItem(
            name: f.name,
            type: f.type,
            icon: f.icon,
            isRequired: false,
            isSelected: f.isSelected,
          ),
        )
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Configure Student Form Fields",
                                style: MyStyles.boldText(
                                  size: 16,
                                  color: AppTheme.black_Color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Testing School001 • ${tempFields.length} fields (${tempFields.where((f) => f.isRequired).length} required)",
                                style: MyStyles.regularText(
                                  size: 12,
                                  color: AppTheme.graySubTitleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.black),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Drag and drop to reorder fields",
                            style: MyStyles.regularText(
                              size: 12,
                              color: AppTheme.graySubTitleColor,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 110,
                          child: AppButton(
                            title: "Add Field",
                            isLoading: false,
                            color: AppTheme.btnColor,
                            height: 36,
                            onTap: () =>
                                _openAddFields(setSheetState, tempFields),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: tempFields.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final field = tempFields[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.backBtnBgColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.drag_indicator,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    field.icon,
                                    size: 18,
                                    color: AppTheme.graySubTitleColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      field.name,
                                      style: MyStyles.boldText(
                                        size: 13,
                                        color: AppTheme.black_Color,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.appBackgroundColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppTheme.backBtnBgColor,
                                      ),
                                    ),
                                    child: Text(
                                      field.type,
                                      style: MyStyles.regularText(
                                        size: 10,
                                        color: AppTheme.graySubTitleColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value: field.isRequired,
                                          activeColor: AppTheme.redBtnBgColor,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          onChanged: (val) {
                                            setSheetState(() {
                                              field.isRequired = val ?? false;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Required",
                                        style: MyStyles.regularText(
                                          size: 12,
                                          color: field.isRequired
                                              ? AppTheme.redBtnBgColor
                                              : AppTheme.graySubTitleColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setSheetState(
                                        () => tempFields.removeAt(index),
                                      );
                                    },
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
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
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppButton(
                            title: "Save Configure",
                            isLoading: false,
                            color: AppTheme.btnColor,
                            onTap: () {
                              setState(() {
                                for (int i = 0; i < _allFields.length; i++) {
                                  final match = tempFields.firstWhere(
                                    (f) => f.name == _allFields[i].name,
                                    orElse: () => _FieldItem(
                                      name: '',
                                      type: '',
                                      icon: Icons.circle,
                                      isSelected: false,
                                    ),
                                  );
                                  if (match.name.isNotEmpty) {
                                    _allFields[i].isRequired = match.isRequired;
                                    _allFields[i].isSelected = true;
                                  } else {
                                    _allFields[i].isSelected = false;
                                  }
                                }

                                for (final f in tempFields) {
                                  final exists = _allFields.any(
                                    (a) => a.name == f.name,
                                  );
                                  if (!exists) {
                                    _allFields.add(f);
                                  }
                                }
                              });
                              Navigator.pop(context);
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: "Student Form Fields",
        backgroundColor: Colors.transparent,
        showText: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Student Form Fields",
                        style: MyStyles.boldText(
                          size: 16,
                          color: AppTheme.black_Color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Configure Add Student form",
                        style: MyStyles.regularText(
                          size: 12,
                          color: AppTheme.graySubTitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 110,
                  child: AppButton(
                    title: "Configure",
                    isLoading: false,
                    color: AppTheme.btnColor,
                    height: 40,
                    onTap: _openConfigure,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Current Fields (${_currentFields.length})",
                    style: MyStyles.boldText(
                      size: 14,
                      color: AppTheme.black_Color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _currentFields.map((field) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.appBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.backBtnBgColor),
                        ),
                        child: Text(
                          field.isRequired ? "${field.name} *" : field.name,
                          style: MyStyles.regularText(
                            size: 12,
                            color: AppTheme.black_Color,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
