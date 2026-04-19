import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/providers/orders/orders_cubit.dart';
import 'package:idmitra/providers/orders/orders_state.dart';

class FilterBottomSheet extends StatefulWidget {
  final String schoolId;
  const FilterBottomSheet({super.key, required this.schoolId});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? selectedClassId;
  String? selectedClassName;
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    // Classes are fetched by the BlocProvider in student_list.dart
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Filters",
                  style: MyStyles.boldText(size: 16, color: AppTheme.black_Color),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Selected class chip (if any)
            if (selectedClassName != null) ...[
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(
                      selectedClassName!,
                      style: MyStyles.regularText(size: 13, color: AppTheme.btnColor),
                    ),
                    backgroundColor: AppTheme.btnColor.withOpacity(0.1),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => setState(() {
                      selectedClassId = null;
                      selectedClassName = null;
                    }),
                    side: BorderSide.none,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Class label
            Text(
              "Select Class",
              style: MyStyles.mediumText(size: 13, color: AppTheme.graySubTitleColor),
            ),
            const SizedBox(height: 8),

            // Class list — fixed height, no full-screen overlay
            BlocBuilder<OrdersCubit, OrdersState>(
              buildWhen: (p, c) =>
                  p.availableClasses != c.availableClasses ||
                  p.classesLoading != c.classesLoading,
              builder: (context, state) {
                if (state.classesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.availableClasses.isEmpty) {
                  return Text(
                    "No classes available",
                    style: MyStyles.regularText(
                        size: 13, color: AppTheme.graySubTitleColor),
                  );
                }
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.35,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: state.availableClasses.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: AppTheme.LineColor),
                    itemBuilder: (context, index) {
                      final cls = state.availableClasses[index];
                      final isSelected =
                          selectedClassId == cls.id.toString();
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedClassId = cls.id.toString();
                            selectedClassName =
                                cls.nameWithprefix ?? cls.name;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  cls.nameWithprefix ?? cls.name,
                                  style: MyStyles.regularText(
                                    size: 14,
                                    color: isSelected
                                        ? AppTheme.btnColor
                                        : AppTheme.black_Color,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle,
                                    size: 18, color: AppTheme.btnColor),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedClassId = null;
                        selectedClassName = null;
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
                      backgroundColor: AppTheme.btnColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, {
                        "class": selectedClassId,
                        "gender": selectedGender,
                      });
                    },
                    child: const Text(
                      "Apply Filter",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
