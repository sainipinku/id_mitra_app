import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';
import 'package:idmitra/api_mamanger/api_manager.dart';
import 'package:idmitra/api_mamanger/config.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/components/text_filed.dart';
import 'package:idmitra/models/orders/OrderModel.dart';

class StaffOrderItem {
  final int id;
  final String status;
  final String type;
  final String orderedAt;
  final String? staffName;
  final String? staffPhoto;
  final String? schoolName;

  const StaffOrderItem({
    required this.id,
    required this.status,
    required this.type,
    required this.orderedAt,
    this.staffName,
    this.staffPhoto,
    this.schoolName,
  });

  factory StaffOrderItem.fromJson(Map<String, dynamic> json) {
    final staff = json['staff'] as Map<String, dynamic>?;
    final school = json['school'] as Map<String, dynamic>?;
    return StaffOrderItem(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      type: json['type'] ?? '',
      orderedAt: json['orderd_at'] ?? json['created_at'] ?? '',
      staffName: staff?['name'],
      staffPhoto: staff?['profile_photo_url'],
      schoolName: school?['name'],
    );
  }

  String get statusLabel => kOrderStatuses
      .firstWhere((s) => s.value == status,
          orElse: () => OrderStatusOption(status, status.replaceAll('_', ' ')))
      .label;

  String get typeLabel {
    switch (type) {
      case 'pvc_card': return 'PVC Card';
      case 'rfid_card': return 'RFID Card';
      case 'pasting_card': return 'Pasting Card';
      default: return type.replaceAll('_', ' ');
    }
  }
}

class StaffOrdersPage extends StatefulWidget {
  final String schoolId;
  const StaffOrdersPage({super.key, required this.schoolId});

  @override
  State<StaffOrdersPage> createState() => _StaffOrdersPageState();
}

class _StaffOrdersPageState extends State<StaffOrdersPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _dateFromCtrl = TextEditingController();
  final TextEditingController _dateToCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  Timer? _debounce;

  List<StaffOrderItem> _orders = [];
  bool _loading = false;
  bool _hasMore = true;
  int _page = 1;
  int _total = 0;
  String? _error;
  String _selectedStatus = '';

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
    _fetch(reset: true);
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
    setState(() {
      _orders = [];
      _page = 1;
      _hasMore = true;
      _error = null;
    });
    _fetch(reset: true);
  }

  Future<void> _fetch({bool reset = false}) async {
    if (_loading || (!_hasMore && !reset)) return;
    setState(() => _loading = true);
    try {
      final currentPage = reset ? 1 : _page;
      var url = '${Config.baseUrl}auth/partner/orders?page=$currentPage';
      if (_selectedStatus.isNotEmpty) url += '&status=$_selectedStatus';
      if (_searchCtrl.text.trim().isNotEmpty) {
        url += '&search=${_searchCtrl.text.trim()}';
      }
      if (_dateFromCtrl.text.isNotEmpty) {
        url += '&date_from=${_dateFromCtrl.text}';
      }
      if (_dateToCtrl.text.isNotEmpty) url += '&date_to=${_dateToCtrl.text}';
      print('fetchStaffOrders URL: $url');

      final response = await ApiManager().getRequest(url);
      if (response == null) {
        setState(() {
          _loading = false;
          _error = 'Failed to load orders';
        });
        return;
      }
      final json = jsonDecode(response.body);
      final data = json['data'] as Map<String, dynamic>;

      List rawList = [];
      int total = 0;
      int lastPage = 1;
      int respCurrentPage = 1;

      if (data.containsKey('orders') && data['orders'] is List) {
        rawList = data['orders'] as List;
        final pagination = data['pagination'] as Map<String, dynamic>?;
        total = pagination?['total'] ?? rawList.length;
        lastPage = pagination?['last_page'] ?? 1;
        respCurrentPage = pagination?['current_page'] ?? 1;
      } else if (data.containsKey('orders') && data['orders'] is Map) {
        final ordersData = data['orders'] as Map<String, dynamic>;
        rawList = ordersData['data'] ?? [];
        total = data['total'] ?? ordersData['total'] ?? 0;
        lastPage = ordersData['last_page'] ?? 1;
        respCurrentPage = ordersData['current_page'] ?? 1;
      }

      final newOrders = rawList
          .map((e) => StaffOrderItem.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _loading = false;
        _total = total;
        _page = respCurrentPage + 1;
        _hasMore = respCurrentPage < lastPage;
        _orders = reset ? newOrders : [..._orders, ...newOrders];
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _loadMore() {
    if (!_loading && _hasMore) _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.appBackgroundColor,
      appBar: CommonAppBar(
        title: 'Staff Card Orders',
        backgroundColor: Colors.white,
        showText: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                // Search + status row
                Row(
                  children: [
                    Expanded(child: _searchBar()),
                    const SizedBox(width: 8),
                    SizedBox(width: 160, child: _statusDropdown()),
                  ],
                ),
                const SizedBox(height: 8),
                // Date row
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

          // List
          Expanded(
            child: _loading && _orders.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: MyStyles.regularText(size: 14, color: Colors.red),
                    ),
                  )
                : _orders.isEmpty
                ? Center(
                    child: Image.asset(
                      'assets/images/no_data.png',
                      height: 200,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => _resetAndFetch(),
                    child: ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: _orders.length + (_hasMore ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i < _orders.length)
                          return _StaffOrderCard(order: _orders[i]);
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() => TextField(
    controller: _searchCtrl,
    style: MyStyles.regularText(size: 13, color: AppTheme.black_Color),
    onChanged: (_) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), _resetAndFetch);
    },
    decoration: InputDecoration(
      filled: true,
      fillColor: AppTheme.appBackgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      hintText: 'Search order...',
      prefixIcon: const Icon(Icons.search, size: 18),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.backBtnBgColor),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.btnColor),
        borderRadius: BorderRadius.circular(10),
      ),
      hintStyle: MyStyles.regularText(
        size: 13,
        color: AppTheme.graySubTitleColor,
      ),
    ),
  );

  Widget _statusDropdown() => Container(
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: AppTheme.appBackgroundColor,
      border: Border.all(color: AppTheme.backBtnBgColor),
      borderRadius: BorderRadius.circular(10),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedStatus,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, size: 16),
        style: MyStyles.regularText(size: 12, color: AppTheme.black_Color),
        items: kOrderFilterStatuses
            .map((s) => DropdownMenuItem<String>(
                  value: s.value,
                  child: Text(s.label, overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: (v) {
          setState(() => _selectedStatus = v ?? '');
          _resetAndFetch();
        },
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
                  _debounce = Timer(
                    const Duration(milliseconds: 200),
                    _resetAndFetch,
                  );
                },
                child: const Icon(Icons.close, size: 16),
              )
            : null,
        onChanged: (_) {
          setLocal(() {});
          if (ctrl.text.length == 10 || ctrl.text.isEmpty) {
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            _debounce = Timer(
              const Duration(milliseconds: 400),
              _resetAndFetch,
            );
          }
        },
      ),
    );
  }

  Widget _headerCell(String text, {int flex = 1}) => Expanded(
    flex: flex,
    child: Text(
      text,
      style: MyStyles.mediumText(size: 11, color: AppTheme.graySubTitleColor),
      overflow: TextOverflow.ellipsis,
    ),
  );
}

// ─── Staff Order Card (same style as OrderCard) ───────────────────────────────
class _StaffOrderCard extends StatelessWidget {
  final StaffOrderItem order;
  const _StaffOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Header - ID + Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.btnColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Text('#${order.id}', style: MyStyles.boldText(size: 13, color: AppTheme.btnColor)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.btnColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(order.statusLabel, style: MyStyles.mediumText(size: 11, color: AppTheme.btnColor)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.LineColor),
          // Body - Staff name + School
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.badge_outlined, size: 14, color: AppTheme.graySubTitleColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.staffName ?? '-',
                        style: MyStyles.boldText(size: 14, color: AppTheme.black_Color),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (order.schoolName != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.school_outlined, size: 14, color: AppTheme.graySubTitleColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.schoolName!,
                          style: MyStyles.regularText(size: 12, color: AppTheme.graySubTitleColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.LineColor),
          // Footer - Type + Date
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                _infoChip(Icons.credit_card_outlined, order.typeLabel),
                const Spacer(),
                _infoChip(Icons.calendar_today_outlined, order.orderedAt),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '-').replaceAll('.', '-');
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
