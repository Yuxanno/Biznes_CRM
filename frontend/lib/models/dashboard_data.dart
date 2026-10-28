import 'transaction.dart';
import 'order.dart';

class ChartDataPoint {
  final String label;
  final double income;
  final double expense;

  const ChartDataPoint({
    required this.label,
    required this.income,
    required this.expense,
  });

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    // Backend returns aggregate format: { _id: { year, month, type }, total }
    // We need to group by month on the client side — this is handled in DashboardData
    return ChartDataPoint(
      label: json['label'] as String? ?? '',
      income: (json['income'] as num? ?? 0).toDouble(),
      expense: (json['expense'] as num? ?? 0).toDouble(),
    );
  }

  /// Build chart points from raw MongoDB aggregate results
  static List<ChartDataPoint> fromAggregateList(List<dynamic> raw) {
    // raw items: { _id: { year: int, month: int, type: 'income'|'expense' }, total: num }
    final Map<String, Map<String, double>> grouped = {};
    for (final item in raw) {
      final id = item['_id'] as Map<String, dynamic>;
      final year = id['year'] as int;
      final month = id['month'] as int;
      final type = id['type'] as String;
      final total = (item['total'] as num).toDouble();
      final key = '$year-${month.toString().padLeft(2, '0')}';
      grouped[key] ??= {'income': 0, 'expense': 0};
      grouped[key]![type] = total;
    }

    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return grouped.entries.map((e) {
      final parts = e.key.split('-');
      final monthIdx = int.parse(parts[1]) - 1;
      return ChartDataPoint(
        label: months[monthIdx],
        income: e.value['income'] ?? 0,
        expense: e.value['expense'] ?? 0,
      );
    }).toList();
  }
}

class DebtSummary {
  final double owedToMe;
  final double iOwe;

  const DebtSummary({required this.owedToMe, required this.iOwe});

  factory DebtSummary.fromJson(Map<String, dynamic> json) {
    return DebtSummary(
      owedToMe: (json['owedToMe'] as num? ?? 0).toDouble(),
      iOwe: (json['iOwe'] as num? ?? 0).toDouble(),
    );
  }
}

class DashboardData {
  final double totalIncome;
  final double totalExpense;
  final double netProfit;
  final int activeOrders;
  final DebtSummary debts;
  final List<Transaction> recentTransactions;
  final List<Order> recentOrders;
  final List<ChartDataPoint> chartData;
  final List<Order> upcomingDeadlines;

  const DashboardData({
    required this.totalIncome,
    required this.totalExpense,
    required this.netProfit,
    required this.activeOrders,
    required this.debts,
    required this.recentTransactions,
    required this.recentOrders,
    required this.chartData,
    required this.upcomingDeadlines,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    // support both direct fields and nested under 'data'
    final d = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return DashboardData(
      totalIncome: (d['totalIncome'] as num? ?? 0).toDouble(),
      totalExpense: (d['totalExpense'] as num? ?? 0).toDouble(),
      netProfit: (d['netProfit'] as num? ?? d['balance'] as num? ?? 0).toDouble(),
      // backend field is 'activeOrdersCount'
      activeOrders: (d['activeOrdersCount'] as num? ?? d['activeOrders'] as num? ?? 0).toInt(),
      debts: DebtSummary.fromJson({
        'owedToMe': d['owedToMe'] ?? (d['debts'] as Map?)?['owedToMe'] ?? 0,
        'iOwe': d['iOwe'] ?? (d['debts'] as Map?)?['iOwe'] ?? 0,
      }),
      recentTransactions: (d['recentTransactions'] as List? ?? [])
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentOrders: (d['recentOrders'] as List? ?? [])
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList(),
      chartData: ChartDataPoint.fromAggregateList(d['chartData'] as List? ?? []),
      // backend field is 'upcomingOrders'
      upcomingDeadlines: (d['upcomingOrders'] as List? ?? d['upcomingDeadlines'] as List? ?? [])
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
