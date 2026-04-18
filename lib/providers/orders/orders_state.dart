import 'package:idmitra/models/orders/OrderModel.dart';

class OrdersState {
  final bool loading;
  final bool isPaginationLoading;
  final List<OrderModel> ordersList;
  final int page;
  final bool hasMore;
  final int total;
  final String? error;
  final bool statsLoading;
  final int staffTotal;
  final bool staffTotalLoading;
  final List<OrderClass> availableClasses;
  final bool classesLoading;

  const OrdersState({
    this.loading = false,
    this.isPaginationLoading = false,
    this.ordersList = const [],
    this.page = 1,
    this.hasMore = true,
    this.total = 0,
    this.error,
    this.statsLoading = false,
    this.staffTotal = 0,
    this.staffTotalLoading = false,
    this.availableClasses = const [],
    this.classesLoading = true,
  });

  OrdersState copyWith({
    bool? loading,
    bool? isPaginationLoading,
    List<OrderModel>? ordersList,
    int? page,
    bool? hasMore,
    int? total,
    String? error,
    bool? statsLoading,
    int? staffTotal,
    bool? staffTotalLoading,
    List<OrderClass>? availableClasses,
    bool? classesLoading,
  }) {
    return OrdersState(
      loading: loading ?? this.loading,
      isPaginationLoading: isPaginationLoading ?? this.isPaginationLoading,
      ordersList: ordersList ?? this.ordersList,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
      error: error ?? this.error,
      statsLoading: statsLoading ?? this.statsLoading,
      staffTotal: staffTotal ?? this.staffTotal,
      staffTotalLoading: staffTotalLoading ?? this.staffTotalLoading,
      availableClasses: availableClasses ?? this.availableClasses,
      classesLoading: classesLoading ?? this.classesLoading,
    );
  }
}

class OrderClass {
  final int id;
  final String name;
  final String nameWithprefix;
  const OrderClass(this.id, this.name,this.nameWithprefix);
}
