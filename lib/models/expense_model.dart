class ExpenseClaim {
  final String id;
  final String categoryId;
  final String categoryName;
  final double amount;
  final String expenseDate;
  final String description;
  final String status;
  final String createdAt;
  final String? receiptUrl;

  ExpenseClaim({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.expenseDate,
    required this.description,
    required this.status,
    required this.createdAt,
    this.receiptUrl,
  });

  factory ExpenseClaim.fromJson(Map<String, dynamic> json) {
    return ExpenseClaim(
      id: json['id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: json['category_name'] ?? json['category_id'] ?? 'Uncategorized',
      amount: (json['amount'] ?? 0).toDouble(),
      expenseDate: json['expense_date'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
      receiptUrl: json['receipt_url'],
    );
  }
}

class ExpenseCategory {
  final String id;
  final String name;
  final double? maxLimit;

  ExpenseCategory({
    required this.id,
    required this.name,
    this.maxLimit,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      maxLimit: json['max_limit']?.toDouble(),
    );
  }
}
