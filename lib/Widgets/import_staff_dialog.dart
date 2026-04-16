import 'package:flutter/material.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/utils/common_widgets/app_button.dart';

class ImportStaffDialog extends StatefulWidget {
  const ImportStaffDialog({super.key});

  @override
  State<ImportStaffDialog> createState() => _ImportStaffDialogState();
}

class _ImportStaffDialogState extends State<ImportStaffDialog> {
  String? _dataFileName;
  String? _photoFileName;
  bool _importing = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
            child: Row(
              children: [
                Text('Import Staff',
                    style: MyStyles.boldText(size: 18, color: AppTheme.black_Color)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Body ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Data file label row — wrap to avoid overflow
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: 'Select Data File (Excel/CSV) ',
                          style: MyStyles.mediumText(size: 13, color: AppTheme.black_Color),
                          children: [
                            TextSpan(
                              text: '*',
                              style: MyStyles.mediumText(size: 13, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.download_outlined, size: 14, color: AppTheme.btnColor),
                          const SizedBox(width: 4),
                          Text('Sample File',
                              style: MyStyles.mediumText(size: 12, color: AppTheme.btnColor)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _filePicker(
                  fileName: _dataFileName,
                  onChoose: () => setState(() => _dataFileName = 'staff_data.xlsx'),
                  onClear: () => setState(() => _dataFileName = null),
                ),
                const SizedBox(height: 16),

                // Photos file
                Text('Select Photos File (ZIP Only)',
                    style: MyStyles.mediumText(size: 13, color: AppTheme.black_Color)),
                const SizedBox(height: 8),
                _filePicker(
                  fileName: _photoFileName,
                  onChoose: () => setState(() => _photoFileName = 'staff_photos.zip'),
                  onClear: () => setState(() => _photoFileName = null),
                ),
              ],
            ),
          ),

          // ── Buttons — using project AppButton ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    title: 'Cancel',
                    color: AppTheme.redBtnBgColor,
                    height: 46,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    title: _importing ? 'Importing...' : 'Start Import',
                    color: _dataFileName == null
                        ? AppTheme.backBtnBgColor
                        : AppTheme.btnColor,
                    height: 46,
                    isLoading: _importing,
                    onTap: _dataFileName == null
                        ? () {}
                        : () {
                            setState(() => _importing = true);
                            Future.delayed(const Duration(seconds: 1), () {
                              if (mounted) Navigator.pop(context);
                            });
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

  Widget _filePicker({
    required String? fileName,
    required VoidCallback onChoose,
    required VoidCallback onClear,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.graySubTitleColor.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onChoose,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.btnColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Choose file',
                  style: MyStyles.mediumText(size: 13, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              fileName ?? 'No file chosen',
              style: MyStyles.regularText(
                size: 13,
                color: fileName != null
                    ? AppTheme.black_Color
                    : AppTheme.graySubTitleColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (fileName != null)
            GestureDetector(
              onTap: onClear,
              child: Icon(Icons.close, size: 16, color: AppTheme.graySubTitleColor),
            ),
        ],
      ),
    );
  }
}
