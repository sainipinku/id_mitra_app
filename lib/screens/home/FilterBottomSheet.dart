import 'package:flutter/material.dart';
import 'package:idmitra/components/app_theme.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? selectedClass;
  String? selectedGender;

  final List<String> classList = [
    "Class 1",
    "Class 2",
    "Class 3",
    "Class 4",
    "Class 5",
  ];

  final List<String> genderList = [
    "Male",
    "Female",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Filters",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const Divider(),
            const SizedBox(height: 10),

            /// CLASS DROPDOWN
            DropdownButtonFormField<String>(
              value: selectedClass,
              decoration: InputDecoration(
                labelText: "Select Class",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: appBorder(AppTheme.backBtnBgColor, 15),
                focusedBorder: appBorder(AppTheme.backBtnBgColor, 15),
                errorBorder: appBorder(AppTheme.errorMessageBackgroundColor, 15),
                focusedErrorBorder: appBorder(AppTheme.errorMessageBackgroundColor, 15),
              ),
              items: classList.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedClass = value;
                });
              },
            ),

            const SizedBox(height: 15),

            /// GENDER DROPDOWN
            DropdownButtonFormField<String>(
              value: selectedGender,
              decoration: InputDecoration(
                labelText: "Select Gender",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: appBorder(AppTheme.backBtnBgColor, 15),
                focusedBorder: appBorder(AppTheme.backBtnBgColor, 15),
                errorBorder: appBorder(AppTheme.errorMessageBackgroundColor, 15),
                focusedErrorBorder: appBorder(AppTheme.errorMessageBackgroundColor, 15),
              ),
              items: genderList.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                });
              },
            ),

            const SizedBox(height: 20),

            /// BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50), // height = 50
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedClass = null;
                        selectedGender = null;
                      });
                    },
                    child: const Text("Reset"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50), // height = 50
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, {
                        "class": selectedClass,
                        "gender": selectedGender,
                      });
                    },
                    child: const Text("Apply Filter"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  OutlineInputBorder appBorder(Color color, double radius) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color),
      borderRadius: BorderRadius.circular(radius),
    );
  }
}