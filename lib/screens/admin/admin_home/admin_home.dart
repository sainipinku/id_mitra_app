import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/api_mamanger/UserLocal.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/models/home/SchoolDashboardModel.dart';
import 'package:idmitra/providers/add_student/add_student_cubit.dart';
import 'package:idmitra/providers/admin_dashboard/admin_dashboard_cubit.dart';
import 'package:idmitra/providers/student_form/student_form_cubit.dart';
import 'package:idmitra/providers/student_form/student_form_data_cubit.dart';
import 'package:idmitra/screens/add_student/add_student_form.dart';
import 'package:idmitra/utils/MyStyles.dart';


class AdminHome extends StatelessWidget {
  final VoidCallback? onStudentAdded;
  const AdminHome({super.key, this.onStudentAdded});

  @override
  Widget build(BuildContext context) {
    return _AdminHomeView(onStudentAdded: onStudentAdded);
  }
}

class _AdminHomeView extends StatelessWidget {
  final VoidCallback? onStudentAdded;
  const _AdminHomeView({this.onStudentAdded});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null && state.dashboard == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  state.error!,
                  style: MyStyles.regularTxt(Colors.red, 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<AdminDashboardCubit>().loadDashboard(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final data = state.dashboard?.data;
        return RefreshIndicator(
          onRefresh: () => context.read<AdminDashboardCubit>().loadDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryCards(data: data),
                const SizedBox(height: 16),

                if (data != null) _OrdersGrid(orders: data.summary.orders),
                const SizedBox(height: 16),

                if (data != null) _AttendanceCard(attendance: data.attendance),
                const SizedBox(height: 16),

                Text(
                  "Quick Actions",
                  style: MyStyles.boldTxt(AppTheme.black_Color, 16),
                ),
                const SizedBox(height: 12),
                _QuickActions(onStudentAdded: onStudentAdded),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OrdersGrid extends StatelessWidget {
  final DashOrders orders;
  const _OrdersGrid({required this.orders});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _MiniStatCard(
          item: _StatItem(
            'Total Orders',
            '${orders.total}',
            Icons.receipt_long_outlined,
            Colors.indigo,
          ),
        ),
        _MiniStatCard(
          item: _StatItem(
            'Completed',
            '${orders.completed}',
            Icons.check_circle_outline,
            Colors.green,
          ),
        ),
      ],
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final SchoolDashboardData? data;
  const _SummaryCards({this.data});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
        'Students',
        '${data?.summary.students ?? 0}',
        Icons.school_outlined,
        Colors.orange,
      ),
      _StatItem(
        'Staff',
        '${data?.summary.staff ?? 0}',
        Icons.group_outlined,
        Colors.blue,
      ),
      _StatItem(
        'Classes',
        '${data?.summary.classes ?? 0}',
        Icons.class_outlined,
        Colors.purple,
      ),
      _StatItem(
        'Checklists',
        '${data?.summary.checklists ?? 0}',
        Icons.checklist_outlined,
        Colors.teal,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: items.map((item) => _MiniStatCard(item: item)).toList(),
    );
  }
}

class _StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  _StatItem(this.title, this.value, this.icon, this.color);
}

class _MiniStatCard extends StatelessWidget {
  final _StatItem item;
  const _MiniStatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: item.color.withOpacity(0.12),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.value,
                  style: MyStyles.boldTxt(AppTheme.black_Color, 20),
                ),
                Text(
                  item.title,
                  style: MyStyles.regularTxt(AppTheme.graySubTitleColor, 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final DashAttendance attendance;
  const _AttendanceCard({required this.attendance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.how_to_reg_outlined,
                color: AppTheme.btnColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "Today's Attendance",
                style: MyStyles.boldTxt(AppTheme.black_Color, 15),
              ),
              const Spacer(),
              if (attendance.attendanceDate.isNotEmpty)
                Text(
                  attendance.attendanceDate,
                  style: MyStyles.regularTxt(AppTheme.graySubTitleColor, 11),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (!attendance.hasAttendance)
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    attendance.message,
                    style: MyStyles.regularTxt(Colors.orange, 13),
                  ),
                ),
              ],
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: attendance.attendancePercentage / 100,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  attendance.attendancePercentage >= 75
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${attendance.attendancePercentage.toStringAsFixed(1)}% attendance',
              style: MyStyles.regularTxt(AppTheme.graySubTitleColor, 12),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _AttStat('Present', attendance.present, Colors.green),
                _AttStat('Absent', attendance.absent, Colors.red),
                _AttStat('Late', attendance.late, Colors.orange),
                _AttStat('Leave', attendance.leave, Colors.blue),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AttStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _AttStat(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('$count', style: MyStyles.boldTxt(color, 18)),
          Text(
            label,
            style: MyStyles.regularTxt(AppTheme.graySubTitleColor, 11),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback? onStudentAdded;
  const _QuickActions({this.onStudentAdded});

  Future<void> _navigateToAddStudent(BuildContext context) async {
    final school = await UserLocal.getSchool();
    final schoolId = school['schoolId'] ?? '';
    if (!context.mounted || schoolId.isEmpty) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => StudentFormCubit()
                ..loadFromSchoolId(schoolId: schoolId, schoolName: ''),
            ),
            BlocProvider(
              create: (_) => StudentFormDataCubit()..load(schoolId),
            ),
            BlocProvider(create: (_) => AddStudentCubit()),
          ],
          child: AddStudentFormPage(schoolId: schoolId),
        ),
      ),
    );
    if (result != null) {
      onStudentAdded?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            label: "Add Student",
            icon: Icons.person_add_outlined,
            color: Colors.green,
            onTap: () => _navigateToAddStudent(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            label: "Add Staff",
            icon: Icons.group_add_outlined,
            color: AppTheme.btnColor,
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(label, style: MyStyles.regularTxt(AppTheme.black_Color, 13)),
          ],
        ),
      ),
    );
  }
}
