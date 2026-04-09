import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/text_filed.dart';
import 'package:idmitra/utils/common_widgets/app_button.dart';
import 'package:idmitra/utils/common_widgets/drop_down/drop_down.dart';
import 'package:idmitra/utils/json_file.dart';
import '../../components/my_font_weight.dart';

class ImageSettingsScreen extends StatefulWidget {
  const ImageSettingsScreen({super.key});

  @override
  State<ImageSettingsScreen> createState() => _ImageSettingsScreenState();
}

class _ImageSettingsScreenState extends State<ImageSettingsScreen> {
  final TextEditingController shapeController = TextEditingController();
  Color selectedColor = const Color(0xfff24040);
  TextEditingController colorController = TextEditingController(
    text: "#f24040",
  );
  String? selectedShape;
  String? selectedShape1;
  String? selectedShape2;

  /// Open Color Picker
  void openColorPicker() {
    showDialog(
      context: context,
      builder: (_) {
        Color tempColor = selectedColor;

        return AlertDialog(
          title: Text(
            "Pick a color",
            style: MyStyles.boldText(size: 16, color: Colors.black),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                tempColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: MyStyles.regularText(size: 14, color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedColor = tempColor;
                  colorController.text =
                      "#${selectedColor.value.toRadixString(16).substring(2)}";
                });
                Navigator.pop(context);
              },
              child: Text(
                "Select",
                style: MyStyles.mediumText(size: 14, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Image Settings"),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Photo Size Row
            Row(
              children: [
                Expanded(
                  child: buildTextField(
                    "Photo Width (mm)",
                    "70",
                    shapeController,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: buildTextField(
                    "Photo Height (mm)",
                    "90",
                    shapeController,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Text(
              "Output size (approx @300 DPI): 827 x 1063 px",
              style: MyStyles.mediumText(size: 14, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            buildDropdown("Shape", shapeList, selectedShape, (val) {
              setState(() {
                selectedShape = val;
              });
            }),

            const SizedBox(height: 20),
            Text(
              "Background Color",
              style: MyStyles.boldText(size: 14, color: Colors.black),
            ),
            const SizedBox(height: 5),
            /// ✅ Background Color (UPDATED)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: nameTextField(
                    controller: colorController,
                    hintName: "Background Color",
                  ),
                ),
                const SizedBox(width: 10),

                /// Clickable Color Box
                GestureDetector(
                  onTap: openColorPicker,
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Remove Background Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Remove Background (AI)",
                  style: MyStyles.boldText(size: 14, color: Colors.black),
                ),
                Switch(value: true, onChanged: (val) {}),
              ],
            ),

            const Divider(height: 30),

            /// Watermark
            Text(
              "Watermark (optional)",
              style: MyStyles.boldText(size: 14, color: Colors.black),
            ),

            const SizedBox(height: 10),

            buildTextField("Watermark Text", "SCHOOL NAME", shapeController),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: buildTextField(
                    "Text Color",
                    "#000000",
                    shapeController,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: buildDropdown("Position", shapeList, selectedShape1, (
                    val,
                  ) {
                    setState(() {
                      selectedShape1 = val;
                    });
                  }),
                ),
              ],
            ),

            const Divider(height: 30),

            /// Gradient
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Gradient (optional)",
                  style: MyStyles.boldText(size: 14, color: Colors.black),
                ),
                Switch(value: false, onChanged: (val) {}),
              ],
            ),

            const SizedBox(height: 10),

            buildTextField("Start Color", "#4f46e5", shapeController),
            const SizedBox(height: 10),
            buildTextField("End Color", "#ec4899", shapeController),

            const SizedBox(height: 10),

            buildDropdown("Direction", shapeList, selectedShape2, (val) {
              setState(() {
                selectedShape2 = val;
              });
            }),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child:   AppButton(
                title: "Save Image Settings",
                isLoading: false,
                color: AppTheme.btnColor,
                onTap: () {

                },
              ),

            ),
          ],
        ),
      ),
    );
  }

  /// Common TextField
  Widget buildTextField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: MyStyles.boldText(size: 14, color: Colors.black)),
        const SizedBox(height: 5),
        nameTextField(controller: controller, hintName: hint),
      ],
    );
  }

  /// Dropdown
  Widget buildDropdown(
    String label,
    List<Map<String, String>> items,
    String? selectedValue,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: MyStyles.boldText(size: 14, color: Colors.black)),
        const SizedBox(height: 5),

        Dropdown<Map<String, String>>(
          value: selectedValue == null
              ? null
              : items.firstWhere(
                  (e) => e["slug"] == selectedValue,
                  orElse: () => items.first,
                ),

          items: items,

          onChange: (value) {
            if (value == null) return;

            onChanged(value["slug"]!); // ✅ correct update
          },

          hintText: "Select Status",

          displayText: (int index, Map<String, String> value) {
            return value["title"] ?? "";
          },
        ),
      ],
    );
  }
}
