import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/components/text_filed.dart';
import 'package:idmitra/models/add_student/StudentFormDataModel.dart';
import 'package:idmitra/models/orders/OrderModel.dart';
import 'package:idmitra/providers/orders/orders_cubit.dart';
import 'package:idmitra/providers/orders/orders_state.dart';
import 'package:idmitra/providers/student_form/student_form_data_cubit.dart';
import 'package:idmitra/screens/orders/order_detail_page.dart';
import 'package:idmitra/screens/orders/staff_orders_page.dart';

class OrdersPage extends StatelessWidget {
  final String schoolId;
  const OrdersPage({super.key, required this.schoolId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => OrdersCubit()
          ..fetchOrders(schoolId: schoolId)
          ..fetchStatistics()),
        BlocProvider(create: (_) => StudentFormDataCubit()..load(schoolId)),
      ],
      child: _OrdersView(schoolId: schoolId),
    );
  }
}

class _OrdersView extends StatefulWidget {
  final String schoolId;
  const _OrdersView({required this.schoolId});

  @override
  State<_OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<_OrdersView> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _dateFromCtrl = TextEditingController();
  final TextEditingController _dateToCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  Timer? _debounce;

  String _selectedStatus = '';
  String _selectedClass = '';

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        context.read<OrdersCubit>().fetchOrders(
          isLoadMore: true,
          search: _searchCtrl.text.trim(),
          status: _selectedStatus,
          classId: _selectedClass,
          schoolId: widget.schoolId,
          dateFrom: _dateFromCtrl.text,
          dateTo: _dateToCtrl.text,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _dateFromCtrl.dispose();
    _dateToCtrl.dispose();
    _scrollCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _resetAndFetch() {
    context.read<OrdersCubit>().fetchOrders(
      search: _searchCtrl.text.trim(),
      status: _selectedStatus,
      classId: _selectedClass,
      schoolId: widget.schoolId,
      dateFrom: _dateFromCtrl.text,
      dateTo: _dateToCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.appBackgroundColor,
      appBar: CommonAppBar(
        title: 'Orders',
        backgroundColor: Colors.white,
        showText: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StaffOrdersPage(schoolId: widget.schoolId)),
              ),
              icon: const Icon(Icons.badge_outlined, size: 16),
              label: Text('Staff Cards', style: MyStyles.mediumText(size: 13, color: AppTheme.btnColor)),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.btnColor,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                _searchBar(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _classDropdown()),
                    const SizedBox(width: 8),
                    Expanded(child: _statusDropdown()),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _dateField(_dateFromCtrl, 'dd-mm-yyyy')),
                    const SizedBox(width: 8),
                    Expanded(child: _dateField(_dateToCtrl, 'dd-mm-yyyy')),
                  ],
                ),
              ],
            ),
          ),

          // Stats
          // BlocBuilder<OrdersCubit, OrdersState>(
          //   buildWhen: (p, c) => p.statistics != c.statistics || p.statsLoading != c.statsLoading,
          //   builder: (_, state) {
          //     final s = state.statistics;
          //     return Padding(
          //       padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          //       child: Row(
          //         children: [
          //           _statCard('Total', s != null ? '${s.totalOrders}' : '-', Icons.receipt_long_outlined),
          //           const SizedBox(width: 8),
          //           _statCard('Pending', s != null ? '${s.pendingOrders}' : '-', Icons.hourglass_empty),
          //           const SizedBox(width: 8),
          //           _statCard('Completed', s != null ? '${s.completedOrders}' : '-', Icons.check_circle_outline),
          //           const SizedBox(width: 8),
          //           _statCard('Rate', s != null ? '${s.completionRate.toStringAsFixed(0)}%' : '-', Icons.trending_up),
          //         ],
          //       ),
          //     );
          //   },
          // ),

          // List
          Expanded(
            child: BlocBuilder<OrdersCubit, OrdersState>(
              builder: (_, state) {
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null && state.ordersList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.error!, style: MyStyles.regularText(size: 14, color: Colors.red)),
                        const SizedBox(height: 12),
                        TextButton(onPressed: _resetAndFetch, child: const Text('Retry')),
                      ],
                    ),
                  );
                }
                if (state.ordersList.isEmpty) {
                  return Center(child: Image.asset('assets/images/no_data.png', height: 200));
                }
                return RefreshIndicator(
                  onRefresh: () async => _resetAndFetch(),
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: state.ordersList.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i < state.ordersList.length) {
                        return _OrderCard(order: state.ordersList[i]);
                      }
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() => TextField(
        controller: _searchCtrl,
        style: MyStyles.regularText(size: 14, color: AppTheme.black_Color),
        onChanged: (_) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), _resetAndFetch);
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: AppTheme.appBackgroundColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          hintText: 'Search order...',
          prefixIcon: const Icon(Icons.search, size: 20),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.backBtnBgColor),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.btnColor),
            borderRadius: BorderRadius.circular(10),
          ),
          hintStyle: MyStyles.regularText(size: 13, color: AppTheme.graySubTitleColor),
        ),
      );

  Widget _classDropdown() => BlocBuilder<StudentFormDataCubit, StudentFormDataState>(
        builder: (_, state) {
          final seen = <String>{};
          final unique = (state.data?.classes ?? []).where((c) => seen.add(c.nameWithPrefix)).toList();
          return _dropdown(
            value: _selectedClass.isEmpty ? '' : _selectedClass,
            hint: 'Filter By Classes',
            loading: state.loading,
            items: [
              const DropdownMenuItem(value: '', child: Text('Filter By Classes')),
              ...unique.map((c) => DropdownMenuItem(
                    value: c.id.toString(),
                    child: Text(c.nameWithPrefix, overflow: TextOverflow.ellipsis),
                  )),
            ],
            onChanged: (v) {
              setState(() => _selectedClass = v ?? '');
              _resetAndFetch();
            },
          );
        },
      );

  Widget _statusDropdown() => _dropdown(
        value: _selectedStatus,
        hint: 'Filter By Status',
        items: kOrderFilterStatuses.map((s) => DropdownMenuItem<String>(
              value: s.value,
              child: Text(s.label, overflow: TextOverflow.ellipsis),
            )).toList(),
        onChanged: (v) {
          setState(() => _selectedStatus = v ?? '');
          _resetAndFetch();
        },
      );

  Widget _dropdown({
    required String value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    bool loading = false,
  }) =>
      Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.appBackgroundColor,
          border: Border.all(color: AppTheme.backBtnBgColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            menuMaxHeight: 300,
            icon: loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.keyboard_arrow_down, size: 18),
            style: MyStyles.regularText(size: 13, color: AppTheme.black_Color),
            items: items,
            onChanged: onChanged,
          ),
        ),
      );

  Widget _dateField(TextEditingController ctrl, String hint) {
    return StatefulBuilder(
      builder: (context, setLocal) => AppTextField(
        controller: ctrl,
        hintText: hint,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d.\-/]')),
          LengthLimitingTextInputFormatter(10),
          _DotDateFormatter(),
        ],
        suffixIcon: ctrl.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  ctrl.clear();
                  setLocal(() {});
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 200), _resetAndFetch);
                },
                child: const Icon(Icons.close, size: 16),
              )
            : null,
        onChanged: (_) {
          setLocal(() {});
          if (ctrl.text.length == 10 || ctrl.text.isEmpty) {
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            _debounce = Timer(const Duration(milliseconds: 400), _resetAndFetch);
          }
        },
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppTheme.btnColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 14, color: AppTheme.btnColor),
              ),
              const SizedBox(height: 5),
              Text(value, style: MyStyles.boldText(size: 14, color: AppTheme.black_Color)),
              Text(label, style: MyStyles.regularText(size: 10, color: AppTheme.graySubTitleColor)),
            ],
          ),
        ),
      );
}

// ─── Order Card ───────────────────────────────────────────────────────────────
class _OrderCard extends StatefulWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  late String _currentStatus;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
  }

  String get _statusLabel {
    return kOrderStatuses
        .firstWhere((s) => s.value == _currentStatus,
            orElse: () => OrderStatusOption(_currentStatus, _currentStatus.replaceAll('_', ' ')))
        .label;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _updating = true);
    final success = await context.read<OrdersCubit>().updateOrderStatus(widget.order.uuid, newStatus);
    if (mounted) {
      setState(() {
        _updating = false;
        if (success) _currentStatus = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Status updated successfully' : 'Failed to update status'),
          backgroundColor: success ? AppTheme.btnColor : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OrderDetailPage(uuid: widget.order.uuid)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.btnColor.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Text('#${widget.order.id}', style: MyStyles.boldText(size: 13, color: AppTheme.btnColor)),
                  const Spacer(),
                  _statusChip(),
                  const SizedBox(width: 4),
                  // 3-dot status update menu
                  _updating
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, size: 18, color: AppTheme.graySubTitleColor),
                          offset: const Offset(0, 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 8,
                          onSelected: _updateStatus,
                          itemBuilder: (_) => [
                            PopupMenuItem<String>(
                              value: 'completed',
                              enabled: _currentStatus != 'completed',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 16,
                                    color: _currentStatus == 'completed'
                                        ? AppTheme.btnColor
                                        : AppTheme.graySubTitleColor,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Mark as Completed',
                                    style: MyStyles.regularText(
                                      size: 13,
                                      color: _currentStatus == 'completed'
                                          ? AppTheme.btnColor
                                          : AppTheme.black_Color,
                                    ),
                                  ),
                                  if (_currentStatus == 'completed') ...[
                                    const Spacer(),
                                    Icon(Icons.check, size: 14, color: AppTheme.btnColor),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
            Divider(height: 1, color: AppTheme.LineColor),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: widget.order.student?.profilePhotoUrl != null
                        ? Image.network(
                            widget.order.student!.profilePhotoUrl!,
                            height: 56, width: 56, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.order.student?.name ?? '-',
                          style: MyStyles.boldText(size: 14, color: AppTheme.black_Color),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.order.student?.className != null) ...[
                          const SizedBox(height: 2),
                          Text(widget.order.student!.className!, style: MyStyles.mediumText(size: 12, color: AppTheme.btnColor)),
                        ],
                        const SizedBox(height: 4),
                        Text(widget.order.school?.name ?? '', style: MyStyles.regularText(size: 11, color: AppTheme.graySubTitleColor), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppTheme.LineColor),
            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  _infoChip(Icons.credit_card_outlined, widget.order.typeLabel),
                  const SizedBox(width: 8),
                  _infoChip(Icons.style_outlined, widget.order.orderCardsLabel),
                  const Spacer(),
                  _infoChip(Icons.calendar_today_outlined, widget.order.orderedAt),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        height: 56, width: 56,
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.person, color: Colors.grey),
      );

  Widget _statusChip() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: AppTheme.btnColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
        child: Text(_statusLabel, style: MyStyles.mediumText(size: 11, color: AppTheme.btnColor)),
      );

  Widget _infoChip(IconData icon, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.graySubTitleColor),
          const SizedBox(width: 4),
          Text(label, style: MyStyles.regularText(size: 11, color: AppTheme.graySubTitleColor)),
        ],
      );
}

class _DotDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('/', '-').replaceAll('.', '-');
    return newValue.copyWith(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
