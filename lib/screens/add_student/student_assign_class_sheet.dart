import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idmitra/Widgets/shimmer_loader.dart';
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/api_mamanger/secure_storage.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/models/add_student/StudentFormDataModel.dart';
import 'package:idmitra/utils/common_widgets/app_button.dart';
import 'package:idmitra/utils/common_widgets/drop_down/drop_down.dart';

class StudentAssignClassSheet extends StatefulWidget {
  final String schoolId;
  final String studentUuid;
  final String studentName;
  final VoidCallback? onAssigned;

  const StudentAssignClassSheet({
    super.key,
    required this.schoolId,
    required this.studentUuid,
    required this.studentName,
    this.onAssigned,
  });

  @override
  State<StudentAssignClassSheet> createState() => _StudentAssignClassSheetState();
}

class _StudentAssignClassSheetState extends State<StudentAssignClassSheet> {
  List<ClassOption> _availableClasses = [];
  bool _classesLoading = true;
  bool _adding = false;

  ClassOption? _selectedClass;
  int? _selectedSectionId;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
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
        setState(() => _availableClasses = unsorted);
      }
    } catch (e) {
      debugPrint('fetchClasses error: $e');
    }
    setState(() => _classesLoading = false);
  }

  Future<void> _assign() async {
    if (_selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _adding = true);
    try {
      final token = await UserSecureStorage.fetchToken();
      final url = '${Config.baseUrl}auth/school/${widget.schoolId}/students/${widget.studentUuid}/assign';
      final body = <String, dynamic>{
        'school_class_id': _selectedClass!.id,
        if (_selectedSectionId != null) 'school_class_section_id': _selectedSectionId,
      };
      debugPrint('Assign URL: $url');
      debugPrint('Assign Body: ${jsonEncode(body)}');
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      print('Assign Response: ${response.statusCode} - ${response.body}');
      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final rootContext = Navigator.of(context, rootNavigator: true).context;
        Navigator.pop(context, true);
        widget.onAssigned?.call();

        ScaffoldMessenger.of(rootContext).showSnackBar(
          const SnackBar(
            content: Text('Student assigned successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        final msg = jsonDecode(response.body)['message'] ?? 'Failed to assign class';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint('assign error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong'), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _adding = false);
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
                    Text('Assign Class',
                        style: MyStyles.boldText(size: 16, color: AppTheme.black_Color)),
                    Text(widget.studentName,
                        style: MyStyles.regularText(size: 13, color: AppTheme.graySubTitleColor)),
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
            Text('Select Class',
                style: MyStyles.mediumText(size: 13, color: AppTheme.black_Color)),
            const SizedBox(height: 6),
            _classesLoading
                ? shimmerBox(height: 48, radius: 8)
                : Dropdown<ClassOption>(
                    value: _selectedClass,
                    items: _availableClasses,
                    hintText: '-Select Class-',
                    showClearButton: false,
                    displayText: (_, c) => c.nameWithPrefix,
                    onChange: (v) => setState(() {
                      _selectedClass = v;
                      _selectedSectionId = null;
                    }),
                  ),
            if (_selectedClass != null && _selectedClass!.sections.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('Select Section',
                  style: MyStyles.mediumText(size: 13, color: AppTheme.black_Color)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedClass!.sections.map((sec) {
                  final selected = _selectedSectionId == sec.id;
                  return GestureDetector(
                    onTap: () => setState(() =>
                        _selectedSectionId = selected ? null : sec.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.btnColor : Colors.white,
                        border: Border.all(
                          color: selected ? AppTheme.btnColor : AppTheme.backBtnBgColor,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sec.name,
                        style: MyStyles.regularText(
                          size: 13,
                          color: selected ? Colors.white : AppTheme.black_Color,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                title: 'Assign',
                isLoading: _adding,
                color: AppTheme.btnColor,
                onTap: _assign,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
