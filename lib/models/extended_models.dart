class TaxDeclaration {
  final String id;
  final String sectionName;
  final String sectionDescription;
  final double declaredAmount;
  final double maxLimit;
  final String? financialYear;

  TaxDeclaration({
    required this.id,
    required this.sectionName,
    required this.sectionDescription,
    required this.declaredAmount,
    required this.maxLimit,
    this.financialYear,
  });

  factory TaxDeclaration.fromJson(Map<String, dynamic> json) {
    return TaxDeclaration(
      id: json['id']?.toString() ?? '',
      sectionName: json['section_name'] ?? '',
      sectionDescription: json['section_description'] ?? '',
      declaredAmount: (json['declared_amount'] ?? 0).toDouble(),
      maxLimit: (json['max_limit'] ?? 0).toDouble(),
      financialYear: json['financial_year'],
    );
  }
}

class OvertimeRequest {
  final String id;
  final String date;
  final String startTime;
  final String endTime;
  final int totalMinutes;
  final String status;
  final String? reason;

  OvertimeRequest({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.totalMinutes,
    required this.status,
    this.reason,
  });

  factory OvertimeRequest.fromJson(Map<String, dynamic> json) {
    return OvertimeRequest(
      id: json['id']?.toString() ?? '',
      date: json['date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      totalMinutes: json['total_minutes'] ?? 0,
      status: json['status'] ?? 'draft',
      reason: json['reason'],
    );
  }

  String get formattedDuration {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return '${h}h ${m}m';
  }
}

class SalaryStructureItem {
  final String componentName;
  final double amount;

  SalaryStructureItem({
    required this.componentName,
    required this.amount,
  });

  factory SalaryStructureItem.fromJson(Map<String, dynamic> json) {
    return SalaryStructureItem(
      componentName: json['component_name'] ?? json['name'] ?? 'Component',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}

class SalaryStructure {
  final String id;
  final String effectiveFrom;
  final int status;
  final List<SalaryStructureItem> items;

  SalaryStructure({
    required this.id,
    required this.effectiveFrom,
    required this.status,
    required this.items,
  });

  factory SalaryStructure.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] ?? json['components'] ?? [];
    return SalaryStructure(
      id: json['id']?.toString() ?? '',
      effectiveFrom: json['effective_from'] ?? '',
      status: json['status'] ?? 0,
      items: (rawItems as List).map((i) => SalaryStructureItem.fromJson(i)).toList(),
    );
  }

  double get grossSalary => items.fold(0, (sum, i) => sum + i.amount);
}

class Form16 {
  final String id;
  final String financialYear;
  final String? generatedAt;

  Form16({
    required this.id,
    required this.financialYear,
    this.generatedAt,
  });

  factory Form16.fromJson(Map<String, dynamic> json) {
    return Form16(
      id: json['id']?.toString() ?? '',
      financialYear: json['financial_year'] ?? '',
      generatedAt: json['generated_at'] ?? json['created_at'],
    );
  }
}

class EmployeeDocument {
  final String name;
  final String? url;
  final String uploadedBy; // 'self' or 'admin'
  final String? createdAt;

  EmployeeDocument({
    required this.name,
    this.url,
    required this.uploadedBy,
    this.createdAt,
  });

  factory EmployeeDocument.fromJson(Map<String, dynamic> json) {
    return EmployeeDocument(
      name: json['name'] ?? json['document_name'] ?? 'Document',
      url: json['url'] ?? json['file_url'],
      uploadedBy: json['uploaded_by'] ?? 'admin',
      createdAt: json['created_at'],
    );
  }
}

class LeaveType {
  final String id;
  final String name;

  LeaveType({required this.id, required this.name});

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    return LeaveType(
      id: json['id']?.toString() ?? '',
      name: json['leave_type_name'] ?? json['name'] ?? '',
    );
  }
}
