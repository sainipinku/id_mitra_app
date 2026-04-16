import 'package:flutter/material.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/utils/common_widgets/app_button.dart';
import 'package:idmitra/utils/common_widgets/drop_down/drop_down.dart';

const _listTypes = [
  '- Select List Type -',
  'All Staff',
  'Active Staff',
  'Inactive Staff',
];

const _processTypes = [
  '- Select Process Type -',
  'Generate ID Cards',
  'Send Notification',
  'Export Data',
  'Print Cards',
];

class ProcessChecklistDialog extends StatefulWidget {
  const ProcessChecklistDialog({super.key});

  @override
  State<ProcessChecklistDialog> createState() => _ProcessChecklistDialogState();
}

class _ProcessChecklistDialogState extends State<ProcessChecklistDialog> {
  String? _listType;
  String? _processType;

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
                Expanded(
                  child: Text(
                    'Process Checklist Or Orders',
                    style: MyStyles.boldText(size: 18, color: AppTheme.black_Color),
                  ),
                ),
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
                Text('List Type',
                    style: MyStyles.mediumText(size: 14, color: AppTheme.black_Color)),
                const SizedBox(height: 8),
                Dropdown<String>(
                  value: _listType,
                  items: _listTypes,
                  hintText: '- Select List Type -',
                  onChange: (v) => setState(() => _listType = v),
                  displayText: (_, o) => o,
                  showClearButton: false,
                ),
                const SizedBox(height: 16),
                Text('Select Process Type',
                    style: MyStyles.mediumText(size: 14, color: AppTheme.black_Color)),
                const SizedBox(height: 8),
                Dropdown<String>(
                  value: _processType,
                  items: _processTypes,
                  hintText: '- Select Process Type -',
                  onChange: (v) => setState(() => _processType = v),
                  displayText: (_, o) => o,
                  showClearButton: false,
                ),
              ],
            ),
          ),

          // ── Buttons ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 110,
                  child: AppButton(
                    title: 'Cancel',
                    color: AppTheme.redBtnBgColor,
                    height: 44,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 110,
                  child: AppButton(
                    title: 'Confirm',
                    color: AppTheme.btnColor,
                    height: 44,
                    onTap: () {
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
  }
}
