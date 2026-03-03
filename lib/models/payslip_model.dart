class Payslip {
  final String id;
  final String month;
  final int year;
  final double grossSalary;
  final double netSalary;
  final double totalDeductions;
  final String status;

  Payslip({
    required this.id,
    required this.month,
    required this.year,
    required this.grossSalary,
    required this.netSalary,
    required this.totalDeductions,
    required this.status,
  });

  factory Payslip.fromJson(Map<String, dynamic> json) {
    return Payslip(
      id: json['id']?.toString() ?? '',
      month: json['month']?.toString() ?? '',
      year: json['year'] ?? 0,
      grossSalary: (json['gross_salary'] ?? 0).toDouble(),
      netSalary: (json['net_salary'] ?? 0).toDouble(),
      totalDeductions: (json['total_deductions'] ?? 0).toDouble(),
      status: json['status'] ?? 'Generated',
    );
  }

  String get displayMonth {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final m = int.tryParse(month) ?? 0;
    if (m >= 1 && m <= 12) return '${months[m]} $year';
    return '$month $year';
  }
}

class Announcement {
  final String id;
  final String title;
  final String message;
  final String priority;
  final String createdAt;
  final String? authorName;

  Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.priority,
    required this.createdAt,
    this.authorName,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      priority: json['priority'] ?? 'low',
      createdAt: json['created_at'] ?? '',
      authorName: json['author_name'],
    );
  }
}
