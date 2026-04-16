import 'package:idmitra/models/orders/OrderModel.dart';

class OrdersState {
  final bool loading;
  final bool isPaginationLoading;
  final List<OrderModel> ordersList;
  final int page;
  final bool hasMore;
  final int total;
  final String? error;
  final OrderStatistics? statistics;
  final bool statsLoading;
  final int staffTotal;
  final bool staffTotalLoading;

  const OrdersState({
    this.loading = false,
    this.isPaginationLoading = false,
    this.ordersList = const [],
    this.page = 1,
    this.hasMore = true,
    this.total = 0,
    this.error,
    this.statistics,
    this.statsLoading = false,
    this.staffTotal = 0,
    this.staffTotalLoading = false,
  });

  OrdersState copyWith({
    bool? loading,
    bool? isPaginationLoading,
    List<OrderModel>? ordersList,
    int? page,
    bool? hasMore,
    int? total,
    String? error,
    OrderStatistics? statistics,
    bool? statsLoading,
    int? staffTotal,
    bool? staffTotalLoading,
  }) {
    return OrdersState(
      loading: loading ?? this.loading,
      isPaginationLoading: isPaginationLoading ?? this.isPaginationLoading,
      ordersList: ordersList ?? this.ordersList,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
      error: error ?? this.error,
      statistics: statistics ?? this.statistics,
      statsLoading: statsLoading ?? this.statsLoading,
      staffTotal: staffTotal ?? this.staffTotal,
      staffTotalLoading: staffTotalLoading ?? this.staffTotalLoading,
    );
  }
}
