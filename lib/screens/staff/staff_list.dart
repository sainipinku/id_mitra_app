import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';

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
  _StaffData(
    name: 'Rajesh Sharma',
    role: 'Math Teacher',
    department: 'Science',
    phone: '9876543210',
    email: 'rajesh@school.com',
    address: 'Jaipur, Rajasthan',
    assignedClasses: ['6th', '7th', '8th'],
  ),
  _StaffData(
    name: 'Priya Verma',
    role: 'English Teacher',
    department: 'Arts',
    phone: '9876543211',
    email: 'priya@school.com',
    address: 'Jaipur, Rajasthan',
    assignedClasses: ['9th', '10th'],
  ),
  _StaffData(
    name: 'Amit Kumar',
    role: 'Physics Teacher',
    department: 'Science',
    phone: '9876543212',
    email: 'amit@school.com',
    address: 'Jaipur, Rajasthan',
    assignedClasses: ['11th', '12th'],
  ),
  _StaffData(
    name: 'Sunita Patel',
    role: 'Chemistry Teacher',
    department: 'Science',
    phone: '9876543213',
    email: 'sunita@school.com',
    address: 'Jaipur, Rajasthan',
    assignedClasses: ['11th', '12th'],
  ),
  _StaffData(
    name: 'Vikram Singh',
    role: 'History Teacher',
    department: 'Arts',
    phone: '9876543214',
    email: 'vikram@school.com',
    address: 'Jaipur, Rajasthan',
    assignedClasses: ['8th', '9th'],
  ),
  _StaffData(
    name: 'Meena Joshi',
    role: 'Biology Teacher',
    department: 'Science',
    phone: '9876543215',
    email: 'meena@school.com',
    address: 'Jaipur, Rajasthan',
    assignedClasses: ['10th', '11th'],
  ),
  _StaffData(
    name: 'Ravi Gupta',
    role: 'Computer Teacher',
    department: 'Technology',
    phone: '9876543216',
    email: 'ravi@school.com',
    address: 'Jaipur, Rajasthan',
    assignedClasses: ['6th', '7th', '8th', '9th'],
  ),
  _StaffData(
    name: 'Kavita Rao',
    role: 'Hindi Teacher',
    department: 'Arts',
    phone: '9876543217',
    email: 'kavita@school.com',
    address: 'Jaipur, Rajasthan',
    assignedClasses: ['6th', '7th'],
  ),
  _StaffData(
    name: 'Suresh Nair',
    role: 'PE Teacher',
    department: 'Sports',
    phone: '9876543218',
    email: 'suresh@school.com',
    address: 'Jaipur, Rajasthan',
    assignedClasses: ['All Classes'],
  ),
  _StaffData(
    name: 'Anita Desai',
    role: 'Principal',
    department: 'Administration',
    phone: '9876543219',
    email: 'anita@school.com',
    address: 'Jaipur, Rajasthan',
    assignedClasses: ['All Classes'],
  ),
];

class StaffListingPage extends StatefulWidget {
  final String schoolId;
  const StaffListingPage({super.key, required this.schoolId});

  @override
  State<StaffListingPage> createState() => _StaffListingPageState();
}

class _StaffListingPageState extends State<StaffListingPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _sortOrder = 'ascending';

  List<_StaffData> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    var list = _masterStaff
        .where(
          (s) =>
              q.isEmpty ||
              s.name.toLowerCase().contains(q) ||
              s.role.toLowerCase().contains(q) ||
              s.department.toLowerCase().contains(q) ||
              s.email.toLowerCase().contains(q),
        )
        .toList();

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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.btnColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddStaffFormPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              style: MyStyles.regularText(
                size: 14,
                color: AppTheme.black_Color,
              ),
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
                hintStyle: MyStyles.regularText(
                  size: 14,
                  color: AppTheme.graySubTitleColor,
                ),
              ),
            ),
          ),

          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Image.asset(
                      'assets/images/no_data.png',
                      height: 200,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _StaffCard(staff: list[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

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
                // Name + dept chip
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        staff.name,
                        style: MyStyles.boldText(
                          size: 15,
                          color: AppTheme.black_Color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.btnColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        staff.department,
                        style: MyStyles.mediumText(
                          size: 10,
                          color: AppTheme.btnColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // Role
                Text(
                  staff.role,
                  style: MyStyles.mediumText(
                    size: 12,
                    color: AppTheme.graySubTitleColor,
                  ),
                ),
                const SizedBox(height: 5),
                // Email
                _infoRow(Icons.email_outlined, staff.email),
                const SizedBox(height: 2),
                // Assigned classes
                _infoRow(
                  Icons.class_outlined,
                  staff.assignedClasses.join(', '),
                ),
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
              PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8),
                    Text('View'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
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
        child: Text(
          text,
          style: MyStyles.regularText(
            size: 11,
            color: AppTheme.graySubTitleColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
