class OrderModel {
  final int id;
  final String saleType;
  final String client;
  final String salesman;
  final double totalUsd;
  final double totalLbp;
  final DateTime issueDate;
  final DateTime? dueDate;
  final bool isPaid;

  OrderModel({
    required this.id,
    required this.saleType,
    required this.client,
    required this.salesman,
    required this.totalUsd,
    required this.totalLbp,
    required this.issueDate,
    this.dueDate,
    required this.isPaid,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      saleType: json['SaleType']['sale_type_name'],
      client: "${json['Client']['first_name']} ${json['Client']['last_name']}",
      salesman: "${json['User']['first_name']} ${json['User']['last_name']}",
      totalUsd: (json['total_price_usd'] as num).toDouble(),
      totalLbp: (json['total_price_lbp'] as num).toDouble(),
      issueDate: DateTime.parse(json['issue_date']),
      dueDate:
          json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      isPaid: !(json['is_pending_payment'] ?? true),
    );
  }
}
