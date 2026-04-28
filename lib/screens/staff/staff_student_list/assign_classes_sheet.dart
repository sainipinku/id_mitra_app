import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idmitra/Widgets/shimmer_loader.dart';
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/api_mamanger/secure_storage.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/models/add_student/StudentFormDataModel.dart';
import 'package:idmitra/providers/staff_list/staff_list_cubit.dart';
import 'package:idmitra/utils/common_widgets/app_button.dart';
import 'package:idmitra/utils/common_widgets/drop_down/drop_down.dart';

class AssignClassesSheet extends StatefulWidget {
  final String schoolId;
  final String staffUuid;
  final String staffName;
  final StaffListCubit cubit;

  const AssignClassesSheet({
    super.key,
    required this.schoolId,
    required this.staffUuid,
    required this.staffName,
    required this.cubit,
  });

  @override
  State<AssignClassesSheet> createState() => _AssignClassesSheetState();
}

class _AssignClassesSheetState extends State<AssignClassesSheet> {
  List<ClassOption> _availableClasses = [];
  bool _classesLoading = true;
  List<Map<String, dynamic>> _assignedClasses = [];
  bool _loadingAssigned = true;
  bool _adding = false;

  ClassOption? _selectedClass;
  final Set<int> _selectedSectionIds = {};

  @override
  void initState() {
    super.initState();
    _fetchClasses();
    _fetchAssigned();
  }

  Future<void> _fetchClasses() async {
    try {
      final token = await UserSecureStorage.fetchToken();
      final url = '${Config.baseUrl}auth/school/${widget.schoolId}/students/form-data';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data'] ?? json;
        final List raw = data['classes'] ?? [];
        final unsorted = raw.map((e) => ClassOption.fromJson(e)).toList();
        const classOrder = [
          'nursery', 'nur', 'prep', 'pre',
          'lkg', 'l.kg', 'ukg', 'u.kg', 'kg',
          '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12',
        ];
        int orderIndex(String name) {
          final lower = name.toLowerCase().trim();
          for (int i = 0; i < classOrder.length; i++) {
            if (lower == classOrder[i] || lower.contains(classOrder[i])) return i;
          }
          return classOrder.length;
        }
        unsorted.sort((a, b) {
          final ai = orderIndex(a.name);
          final bi = orderIndex(b.name);
          if (ai != bi) return ai.compareTo(bi);
          return a.nameWithPrefix.toLowerCase().compareTo(b.nameWithPrefix.toLowerCase());
        });
        final classes = unsorted;
        setState(() => _availableClasses = classes);
      }
    } catch (e) {
      debugPrint('fetchClasses error: $e');
    }
    setState(() => _classesLoading = false);
  }

  Future<void> _fetchAssigned() async {
    setState(() => _loadingAssigned = true);
    final result = await widget.cubit.fetchAssignedClasses(
      schoolId: widget.schoolId,
      uuid: widget.staffUuid,
    );
    setState(() {
      _assignedClasses = result;
      _loadingAssigned = false;
    });
  }

  Future<void> _addClass() async {
    if (_selectedClass == null) return;
    setState(() => _adding = true);
    final success = await widget.cubit.assignClass(
      schoolId: widget.schoolId,
      uuid: widget.staffUuid,
      classId: _selectedClass!.id,
      sectionIds: _selectedSectionIds.toList(),
    );
    setState(() => _adding = false);
    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to assign class'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _removeClass(Map<String, dynamic> cls) async {
    final assignedUuid = cls['assigned_uuid']?.toString() ?? '';
    if (assignedUuid.isEmpty) return;
    final success = await widget.cubit.removeAssignedClass(
      schoolId: widget.schoolId,
      assignedClassUuid: assignedUuid,
    );
    if (success) {
      await _fetchAssigned();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove class'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Assign Classes',
                        style: MyStyles.boldText(size: 16, color: AppTheme.black_Color)),
                    Text(widget.staffName,
                        style: MyStyles.regularText(
                            size: 13, color: AppTheme.graySubTitleColor)),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Class',
                          style: MyStyles.mediumText(
                              size: 13, color: AppTheme.black_Color)),
                      const SizedBox(height: 6),
                      _classesLoading
                          ? shimmerBox(height: 48, radius: 8)
                          : Dropdown<ClassOption>(
                              value: _selectedClass,
                              items: _availableClasses,
                              hintText: '-Select-',
                              showClearButton: false,
                              displayText: (_, c) => c.nameWithPrefix,
                              onChange: (v) => setState(() {
                                _selectedClass = v;
                                _selectedSectionIds.clear();
                              }),
                            ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 80,
                  child: AppButton(
                    title: 'Add',
                    height: 48,
                    isLoading: _adding,
                    color: AppTheme.btnColor,
                    onTap: _addClass,
                  ),
                ),
              ],
            ),

            if (_selectedClass != null &&
                _selectedClass!.sections.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('Select Sections',
                  style: MyStyles.mediumText(
                      size: 13, color: AppTheme.black_Color)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedClass!.sections.map((sec) {
                  final selected = _selectedSectionIds.contains(sec.id);
                  return GestureDetector(
                    onTap: () => setState(() => selected
                        ? _selectedSectionIds.remove(sec.id)
                        : _selectedSectionIds.add(sec.id)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.btnColor : Colors.white,
                        border: Border.all(
                          color: selected
                              ? AppTheme.btnColor
                              : AppTheme.backBtnBgColor,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sec.name,
                        style: MyStyles.regularText(
                          size: 13,
                          color: selected
                              ? Colors.white
                              : AppTheme.black_Color,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.backBtnBgColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.appBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(10)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text('Class',
                                style: MyStyles.boldText(
                                    size: 13,
                                    color: AppTheme.black_Color))),
                        Expanded(
                            child: Text('Sections',
                                style: MyStyles.boldText(
                                    size: 13,
                                    color: AppTheme.black_Color))),
                        Text('Action',
                            style: MyStyles.boldText(
                                size: 13, color: AppTheme.black_Color)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Table body
                  if (_loadingAssigned)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: List.generate(
                          3,
                          (_) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Expanded(
                                    child: shimmerBox(height: 14, radius: 6)),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: shimmerBox(height: 14, radius: 6)),
                                const SizedBox(width: 12),
                                shimmerBox(
                                    width: 24, height: 24, radius: 12),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (_assignedClasses.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'No assigned classes found.',
                          style: MyStyles.regularText(
                              size: 13, color: Colors.red.shade300),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _assignedClasses.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: AppTheme.backBtnBgColor),
                      itemBuilder: (_, i) {
                        final cls = _assignedClasses[i];
                        final className = cls['name']?.toString() ?? '';
                        final sections = cls['sections'] as List? ?? [];
                        final sectionNames = sections
                            .map((s) => s is Map
                                ? (s['name'] ?? '').toString()
                                : s.toString())
                            .where((s) => s.isNotEmpty)
                            .join(', ');
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(className,
                                    style: MyStyles.regularText(
                                        size: 14,
                                        color: AppTheme.black_Color)),
                              ),
                              Expanded(
                                child: Text(
                                  sectionNames.isEmpty ? '-' : sectionNames,
                                  style: MyStyles.regularText(
                                      size: 13,
                                      color: AppTheme.graySubTitleColor),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _removeClass(cls),
                                child: const Icon(Icons.delete_outline,
                                    color: Colors.red, size: 20),
                              ),
                            ],
                          ),
                        );
                      },
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
