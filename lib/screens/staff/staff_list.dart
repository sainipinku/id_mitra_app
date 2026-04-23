import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/Widgets/shimmer_loader.dart';
import 'package:idmitra/api_mamanger/UserLocal.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/models/staff/StaffListModel.dart';
import 'package:idmitra/providers/staff_list/staff_list_cubit.dart';
import 'add_staff_form.dart';
import 'staff_profile_page.dart';

class StaffListingPage extends StatefulWidget {
  final String schoolId;
  final bool showAppBar;
  const StaffListingPage({super.key, required this.schoolId, this.showAppBar = true});

  @override
  State<StaffListingPage> createState() => _StaffListingPageState();
}

class _StaffListingPageState extends State<StaffListingPage> {
  late final StaffListCubit _cubit;
  String? _schoolId;

  @override
  void initState() {
    super.initState();
    _cubit = StaffListCubit();
    _loadSchoolAndFetch();
  }

  Future<void> _loadSchoolAndFetch() async {
    String id = widget.schoolId;
    if (id.isEmpty) {
      final school = await UserLocal.getSchool();
      id = school['schoolId'] ?? '';
    }
    if (mounted) {
      setState(() => _schoolId = id);
      if (id.isNotEmpty) {
        _cubit.fetchStaff(schoolId: id);
      }
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_schoolId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return BlocProvider.value(
      value: _cubit,
      child: _StaffListBody(
        schoolId: _schoolId!,
        cubit: _cubit,
        showAppBar: widget.showAppBar,
      ),
    );
  }
}

class _StaffListBody extends StatefulWidget {
  final String schoolId;
  final StaffListCubit cubit;
  final bool showAppBar;
  const _StaffListBody({required this.schoolId, required this.cubit, this.showAppBar = true});

  @override
  State<_StaffListBody> createState() => _StaffListBodyState();
}

class _StaffListBodyState extends State<_StaffListBody> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  Timer? _debounce;

  String get _schoolId => widget.schoolId;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      widget.cubit.fetchStaff(
        schoolId: _schoolId,
        search: _searchCtrl.text.trim(),
        isLoadMore: true,
      );
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    await widget.cubit.fetchStaff(
      schoolId: _schoolId,
      search: _searchCtrl.text.trim(),
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.cubit.fetchStaff(schoolId: _schoolId, search: value.trim());
    });
  }

  void _navigateToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddStaffFormPage(
          editStudent: null,
          schoolId: _schoolId,
        ),
      ),
    );

    if (result == true && mounted) {
      widget.cubit.fetchStaff(
        schoolId: _schoolId,
        search: _searchCtrl.text.trim(),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.appBackgroundColor,
      appBar: widget.showAppBar
          ? CommonAppBar(
              title: 'Staff Listings',
              backgroundColor: Colors.white,
              showText: true,
            )
          : null,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.btnColor,
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: TextField(
                controller: _searchCtrl,
                style: MyStyles.regularText(size: 14, color: AppTheme.black_Color),
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.whiteColor,
                  contentPadding: const EdgeInsets.all(12),
                  hintText: 'Search staff...',
                  prefixIcon: const Icon(Icons.search),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.backBtnBgColor),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.backBtnBgColor),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  hintStyle: MyStyles.regularText(size: 14, color: AppTheme.graySubTitleColor),
                ),
              ),
            ),

            // List
            Expanded(
              child: BlocBuilder<StaffListCubit, StaffListState>(
                builder: (context, state) {
                  if (state.loading) {
                    return const ShimmerList(expanded: false, itemCount: 6);
                  }

                  if (state.error != null && state.list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                          const SizedBox(height: 12),
                          Text(state.error!, style: MyStyles.regularText(size: 13, color: Colors.red)),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _refresh,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.list.isEmpty) {
                    return Center(
                      child: Image.asset('assets/images/no_data.png', height: 200),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: state.list.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i < state.list.length) {
                        return _StaffCard(staff: state.list[i], schoolId: _schoolId);
                      }
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Staff Card ───────────────────────────────────────────────────────────────
class _StaffCard extends StatelessWidget {
  final StaffListModel staff;
  final String schoolId;
  const _StaffCard({required this.staff, required this.schoolId});

  @override
  Widget build(BuildContext context) {
    final initials = staff.name.trim().isNotEmpty
        ? staff.name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StaffProfilePage(staff: staff, schoolId: schoolId),
        ),
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: AppTheme.btnColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                initials,
                style: MyStyles.boldText(size: 14, color: AppTheme.btnColor),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + department chip
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        staff.name,
                        style: MyStyles.boldText(size: 15, color: AppTheme.black_Color),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (staff.department.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.btnColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          staff.department,
                          style: MyStyles.mediumText(size: 10, color: AppTheme.btnColor),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),

                // Designation + role
                Text(
                  [staff.designation, staff.roleName]
                      .where((s) => s.isNotEmpty)
                      .join(' • '),
                  style: MyStyles.mediumText(size: 12, color: AppTheme.graySubTitleColor),
                ),
                const SizedBox(height: 5),

                if (staff.email.isNotEmpty) ...[
                  _infoRow(Icons.email_outlined, staff.email),
                  const SizedBox(height: 2),
                ],
                if (staff.phone.isNotEmpty) ...[
                  _infoRow(Icons.phone_outlined, staff.phone),
                  const SizedBox(height: 2),
                ],
                if (staff.assignedClasses.isNotEmpty) ...[
                  _infoRow(Icons.class_outlined, staff.assignedClasses.join(', ')),
                  const SizedBox(height: 2),
                ],
                if (staff.address != null && staff.address!.isNotEmpty)
                  _infoRow(Icons.location_on_outlined, staff.address!),

                // Status badge
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: staff.status == 1
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    staff.status == 1 ? 'Active' : 'Inactive',
                    style: MyStyles.mediumText(
                      size: 10,
                      color: staff.status == 1 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3-dot menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
            onSelected: (_) {},
            itemBuilder: (_) => const [
              // PopupMenuItem(
              //   value: 'view',
              //   child: Row(children: [
              //     Icon(Icons.visibility_outlined, size: 16, color: Colors.blue),
              //     SizedBox(width: 8),
              //     Text('View'),
              //   ]),
              // ),
              // PopupMenuItem(
              //   value: 'edit',
              //   child: Row(children: [
              //     Icon(Icons.edit_outlined, size: 16, color: Colors.blue),
              //     SizedBox(width: 8),
              //     Text('Edit'),
              //   ]),
              // ),
              PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ]),
              ),
            ],
          ),
        ],
      ),
      ),
    ); // GestureDetector
  }

  Widget _infoRow(IconData icon, String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 12, color: AppTheme.graySubTitleColor),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: MyStyles.regularText(size: 11, color: AppTheme.graySubTitleColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
}
