import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/Widgets/import_staff_dialog.dart';
import 'package:idmitra/Widgets/process_checklist_dialog.dart';
import 'package:idmitra/screens/orders/staff_orders_page.dart';

import 'add_staff_form.dart';

class _StaffData {
  final String name;
  final String role;
  final String department;
  final String phone;
  final String email;
  final String address;
  final List<String> assignedClasses;

  const _StaffData({
    required this.name,
    required this.role,
    required this.department,
    required this.phone,
    required this.email,
    required this.address,
    required this.assignedClasses,
  });
}

final List<_StaffData> _masterStaff = [
  _StaffData(name: 'Rajesh Sharma', role: 'Math Teacher', department: 'Science', phone: '9876543210', email: 'rajesh@school.com', address: 'Jaipur, Rajasthan', assignedClasses: ['6th', '7th', '8th']),
  _StaffData(name: 'Priya Verma', role: 'English Teacher', department: 'Arts', phone: '9876543211', email: 'priya@school.com', address: 'Jaipur, Rajasthan', assignedClasses: ['9th', '10th']),
  _StaffData(name: 'Amit Kumar', role: 'Physics Teacher', department: 'Science', phone: '9876543212', email: 'amit@school.com', address: 'Jaipur, Rajasthan', assignedClasses: ['11th', '12th']),
  _StaffData(name: 'Sunita Patel', role: 'Chemistry Teacher', department: 'Science', phone: '9876543213', email: 'sunita@school.com', address: 'Jaipur, Rajasthan', assignedClasses: ['11th', '12th']),
  _StaffData(name: 'Vikram Singh', role: 'History Teacher', department: 'Arts', phone: '9876543214', email: 'vikram@school.com', address: 'Jaipur, Rajasthan', assignedClasses: ['8th', '9th']),
  _StaffData(name: 'Meena Joshi', role: 'Biology Teacher', department: 'Science', phone: '9876543215', email: 'meena@school.com', address: 'Jaipur, Rajasthan', assignedClasses: ['10th', '11th']),
  _StaffData(name: 'Ravi Gupta', role: 'Computer Teacher', department: 'Technology', phone: '9876543216', email: 'ravi@school.com', address: 'Jaipur, Rajasthan', assignedClasses: ['6th', '7th', '8th', '9th']),
  _StaffData(name: 'Kavita Rao', role: 'Hindi Teacher', department: 'Arts', phone: '9876543217', email: 'kavita@school.com', address: 'Jaipur, Rajasthan', assignedClasses: ['6th', '7th']),
  _StaffData(name: 'Suresh Nair', role: 'PE Teacher', department: 'Sports', phone: '9876543218', email: 'suresh@school.com', address: 'Jaipur, Rajasthan', assignedClasses: ['All Classes']),
  _StaffData(name: 'Anita Desai', role: 'Principal', department: 'Administration', phone: '9876543219', email: 'anita@school.com', address: 'Jaipur, Rajasthan', assignedClasses: ['All Classes']),
];

class StaffListingPage extends StatefulWidget {
  final String schoolId;
  const StaffListingPage({super.key, required this.schoolId});

  @override
  State<StaffListingPage> createState() => _StaffListingPageState();
}

class _StaffListingPageState extends State<StaffListingPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _countCtrl = TextEditingController(text: '50');
  String _sortOrder = 'ascending';
  bool _toggleActive = false;
  int _processChecklist = 0;

  List<_StaffData> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    var list = _masterStaff.where((s) =>
        q.isEmpty ||
        s.name.toLowerCase().contains(q) ||
        s.role.toLowerCase().contains(q) ||
        s.department.toLowerCase().contains(q) ||
        s.email.toLowerCase().contains(q)).toList();

    final count = int.tryParse(_countCtrl.text.trim()) ?? list.length;
    if (count < list.length) list = list.take(count).toList();

    if (_sortOrder == 'ascending') {
      list.sort((a, b) => a.name.compareTo(b.name));
    } else {
      list.sort((a, b) => b.name.compareTo(a.name));
    }
    return list;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      backgroundColor: AppTheme.appBackgroundColor,
      appBar: CommonAppBar(
        title: 'Staff Listings',
        backgroundColor: Colors.white,
        showText: true,
      ),
      body: Column(
        children: [
          // ── Top action bar ──────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _actionBtn(Icons.add_circle_outline, 'Add', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddStaffFormPage()));
                  }),
                  const SizedBox(width: 8),
                  _actionBtn(Icons.upload_outlined, 'Import', () {
                    showDialog(context: context, builder: (_) => const ImportStaffDialog());
                  }),
                  const SizedBox(width: 8),
                  _actionBtn(Icons.download_outlined, 'Export', () {}),
                  const SizedBox(width: 8),
                  _actionBtn(Icons.receipt_long_outlined, 'Orders', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StaffOrdersPage(schoolId: widget.schoolId),
                      ),
                    );
                  }),
                  const SizedBox(width: 8),
                  // Count field
                  SizedBox(
                    width: 64,
                    height: 36,
                    child: TextField(
                      controller: _countCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      style: MyStyles.regularText(size: 13, color: AppTheme.black_Color),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: AppTheme.appBackgroundColor,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.backBtnBgColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.btnColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Order By dropdown
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.appBackgroundColor,
                      border: Border.all(color: AppTheme.backBtnBgColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sortOrder,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                        style: MyStyles.regularText(size: 12, color: AppTheme.black_Color),
                        items: const [
                          DropdownMenuItem(value: 'ascending', child: Text('Order By Ascending')),
                          DropdownMenuItem(value: 'descending', child: Text('Order By Descending')),
                        ],
                        onChanged: (v) => setState(() => _sortOrder = v ?? 'ascending'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Toggle
                  Transform.scale(
                    scale: 0.85,
                    child: Switch(
                      value: _toggleActive,
                      activeColor: AppTheme.btnColor,
                      onChanged: (v) => setState(() => _toggleActive = v),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Process Checklist
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const ProcessChecklistDialog(),
                      );
                    },
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.btnColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add_circle_outline, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text('Process Checklist - $_processChecklist',
                              style: MyStyles.mediumText(size: 12, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Search bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              style: MyStyles.regularText(size: 14, color: AppTheme.black_Color),
              onChanged: (_) => setState(() {}),
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

          // ── List ────────────────────────────────────────────────────────
          Expanded(
            child: list.isEmpty
                ? Center(child: Image.asset('assets/images/no_data.png', height: 200))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _StaffCard(staff: list[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.btnColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 5),
              Text(label, style: MyStyles.mediumText(size: 12, color: Colors.white)),
            ],
          ),
        ),
      );
}

// ─── Staff Card ───────────────────────────────────────────────────────────────
class _StaffCard extends StatelessWidget {
  final _StaffData staff;
  const _StaffCard({required this.staff});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                staff.name[0].toUpperCase(),
                style: MyStyles.boldText(size: 22, color: AppTheme.btnColor),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + dept chip
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        staff.name,
                        style: MyStyles.boldText(size: 15, color: AppTheme.black_Color),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.btnColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(staff.department,
                          style: MyStyles.mediumText(size: 10, color: AppTheme.btnColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // Role
                Text(staff.role,
                    style: MyStyles.mediumText(size: 12, color: AppTheme.graySubTitleColor)),
                const SizedBox(height: 5),
                // Email
                _infoRow(Icons.email_outlined, staff.email),
                const SizedBox(height: 2),
                // Assigned classes
                _infoRow(Icons.class_outlined, staff.assignedClasses.join(', ')),
                const SizedBox(height: 2),
                // Address
                _infoRow(Icons.location_on_outlined, staff.address),
              ],
            ),
          ),

          // 3-dot menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
            onSelected: (_) {},
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'view', child: Row(children: [
                Icon(Icons.visibility_outlined, size: 16, color: Colors.blue),
                SizedBox(width: 8), Text('View'),
              ])),
              PopupMenuItem(value: 'edit', child: Row(children: [
                Icon(Icons.edit_outlined, size: 16, color: Colors.blue),
                SizedBox(width: 8), Text('Edit'),
              ])),
              PopupMenuItem(value: 'delete', child: Row(children: [
                Icon(Icons.delete_outline, size: 16, color: Colors.red),
                SizedBox(width: 8), Text('Delete'),
              ])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 12, color: AppTheme.graySubTitleColor),
          const SizedBox(width: 4),
          Expanded(
            child: Text(text,
                style: MyStyles.regularText(size: 11, color: AppTheme.graySubTitleColor),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );
}
