import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/text_filed.dart';
import 'package:idmitra/providers/image_settings/image_settings_cubit.dart';
import 'package:idmitra/utils/common_widgets/app_button.dart';
import 'package:idmitra/utils/common_widgets/drop_down/drop_down.dart';
import 'package:idmitra/utils/json_file.dart';
import 'package:idmitra/components/my_font_weight.dart';

class ImageSettingsScreen extends StatefulWidget {
  final String schoolId;
  const ImageSettingsScreen({super.key, required this.schoolId});

  @override
  State<ImageSettingsScreen> createState() => _ImageSettingsScreenState();
}

class _ImageSettingsScreenState extends State<ImageSettingsScreen> {
  final TextEditingController widthController = TextEditingController(text: "70");
  final TextEditingController heightController = TextEditingController(text: "90");
  final TextEditingController watermarkTextController = TextEditingController();
  final TextEditingController watermarkColorController = TextEditingController(text: "#e6e6e6");
  final TextEditingController gradientStartController = TextEditingController(text: "#4f46e5");
  final TextEditingController gradientEndController = TextEditingController(text: "#ec4899");

  Color selectedBgColor = const Color(0xffe6e6e6);
  TextEditingController bgColorController = TextEditingController(text: "#e6e6e6");

  String? selectedShape;
  String? selectedWatermarkPosition;
  String? selectedGradientDirection;

  bool removeBg = true;
  bool gradientEnabled = false;

  void _openColorPicker(Color current, Function(Color) onPicked) {
    Color tempColor = current;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Pick a color",
            style: MyStyles.boldText(size: 16, color: Colors.black)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: current,
            onColorChanged: (color) => tempColor = color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: MyStyles.regularText(size: 14, color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              onPicked(tempColor);
              Navigator.pop(context);
            },
            child: Text("Select",
                style: MyStyles.mediumText(size: 14, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _colorToHex(Color color) =>
      "#${color.value.toRadixString(16).substring(2)}";

  Future<void> _onSave(BuildContext context) async {
    final schoolId = widget.schoolId;

    if (schoolId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("School ID not found")),
      );
      return;
    }

    final body = {
      "width_mm": int.tryParse(widthController.text) ?? 70,
      "height_mm": int.tryParse(heightController.text) ?? 90,
      "image_shape": selectedShape ?? "rectangle",
      "background_color": bgColorController.text,
      "water_mark_text": watermarkTextController.text,
      "water_mark_text_color": watermarkColorController.text,
      "watermark_position": selectedWatermarkPosition ?? "bottom_right",
      "remove_bg": removeBg,
      "gradient_enabled": gradientEnabled,
      "gradient_start_color": gradientStartController.text,
      "gradient_end_color": gradientEndController.text,
      "gradient_direction": selectedGradientDirection ?? "to right",
    };

    context.read<ImageSettingsCubit>().saveImageSettings(
          schoolId: schoolId,
          body: body,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ImageSettingsCubit(),
      child: BlocConsumer<ImageSettingsCubit, ImageSettingsState>(
        listener: (context, state) {
          if (state is ImageSettingsSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ImageSettingsFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ImageSettingsLoading;
          return Scaffold(
            appBar: CommonAppBar(title: "Image Settings"),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildTextField("Photo Width (mm)", "70", widthController, keyboardType: TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField("Photo Height (mm)", "90", heightController, keyboardType: TextInputType.phone)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text("Output size (approx @300 DPI): 827 x 1063 px",
                      style: MyStyles.mediumText(size: 14, color: Colors.grey)),
                  const SizedBox(height: 20),
                  _buildDropdown("Shape", shapeList, selectedShape, (val) {
                    setState(() => selectedShape = val);
                  }),
                  const SizedBox(height: 20),
                  Text("Background Color",
                      style: MyStyles.boldText(size: 14, color: Colors.black)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                          child: nameTextField(
                              controller: bgColorController,
                              hintName: "Background Color")),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _openColorPicker(selectedBgColor, (color) {
                          setState(() {
                            selectedBgColor = color;
                            bgColorController.text = _colorToHex(color);
                          });
                        }),
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: selectedBgColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Remove Background (AI)",
                          style: MyStyles.boldText(size: 14, color: Colors.black)),
                      Switch(
                        value: removeBg,
                        onChanged: (val) => setState(() => removeBg = val),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  Text("Watermark (optional)",
                      style: MyStyles.boldText(size: 14, color: Colors.black)),
                  const SizedBox(height: 10),
                  _buildTextField("Watermark Text", "SCHOOL NAME", watermarkTextController),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField(
                              "Text Color", "#000000", watermarkColorController)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDropdown(
                            "Position", watermarkPositionList, selectedWatermarkPosition,
                            (val) => setState(() => selectedWatermarkPosition = val)),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Gradient (optional)",
                          style: MyStyles.boldText(size: 14, color: Colors.black)),
                      Switch(
                        value: gradientEnabled,
                        onChanged: (val) => setState(() => gradientEnabled = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTextField("Start Color", "#4f46e5", gradientStartController),
                  const SizedBox(height: 10),
                  _buildTextField("End Color", "#ec4899", gradientEndController),
                  const SizedBox(height: 10),
                  _buildDropdown("Direction", gradientDirectionList, selectedGradientDirection,
                      (val) => setState(() => selectedGradientDirection = val)),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      title: "Save Image Settings",
                      isLoading: isLoading,
                      color: AppTheme.btnColor,
                      onTap: isLoading ? () {} : () => _onSave(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: MyStyles.boldText(size: 14, color: Colors.black)),
        const SizedBox(height: 5),
        nameTextField(controller: controller, hintName: hint, keyboardType: keyboardType),
      ],
    );
  }

  Widget _buildDropdown(String label, List<Map<String, String>> items,
      String? selectedValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: MyStyles.boldText(size: 14, color: Colors.black)),
        const SizedBox(height: 5),
        Dropdown<Map<String, String>>(
          value: selectedValue == null
              ? null
              : items.firstWhere((e) => e["slug"] == selectedValue,
                  orElse: () => items.first),
          items: items,
          onChange: (value) {
            if (value == null) return;
            onChanged(value["slug"]!);
          },
          hintText: "Select",
          displayText: (int index, Map<String, String> value) =>
              value["title"] ?? "",
        ),
      ],
    );
  }
}
