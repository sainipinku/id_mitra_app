part of 'admin_dashboard_cubit.dart';

class AdminDashboardState {
  final bool loading;
  final SchoolDashboardModel? dashboard;
  final String? error;

  AdminDashboardState({this.loading = false, this.dashboard, this.error});

  AdminDashboardState copyWith({
    bool? loading,
    SchoolDashboardModel? dashboard,
    String? error,
  }) =>
      AdminDashboardState(
        loading: loading ?? this.loading,
        dashboard: dashboard ?? this.dashboard,
        error: error,
      );
}
