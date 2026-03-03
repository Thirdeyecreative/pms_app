class EmployeeModel {
  final String id;
  final String employeeCode;
  final String fullName;
  final String email;
  final String phone;
  final String designation;
  final String departmentName;
  final String managerName;
  final String? joiningDate;
  final String? dateOfBirth;
  final String? currentAddress;
  final String? permanentAddress;
  final String? panNo;
  final String? aadhaarNo;
  final String employmentType;
  final String roleName;
  final int status;
  final bool isCheckedIn;
  final String? taxRegime;
  final List<dynamic> documents;

  EmployeeModel({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.designation,
    required this.departmentName,
    required this.managerName,
    this.joiningDate,
    this.dateOfBirth,
    this.currentAddress,
    this.permanentAddress,
    this.panNo,
    this.aadhaarNo,
    required this.employmentType,
    required this.roleName,
    required this.status,
    required this.isCheckedIn,
    this.taxRegime,
    this.documents = const [],
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id']?.toString() ?? '',
      employeeCode: json['employee_code'] ?? 'N/A',
      fullName: json['full_name'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      phone: json['phone'] ?? 'N/A',
      designation: json['designation'] ?? 'N/A',
      departmentName: json['department_name'] ?? 'N/A',
      managerName: json['manager_name'] ?? 'N/A',
      joiningDate: json['joining_date'],
      dateOfBirth: json['date_of_birth'],
      currentAddress: json['current_address'],
      permanentAddress: json['permanent_address'],
      panNo: json['pan_no'],
      aadhaarNo: json['aadhaar_no'],
      employmentType: json['employment_type'] ?? 'N/A',
      roleName: json['role_name'] ?? 'N/A',
      status: json['status'] ?? 0,
      isCheckedIn: json['is_checked_in'] ?? false,
      taxRegime: json['tax_regime'],
      documents: json['documents'] is List ? json['documents'] : [],
    );
  }

  String get displayLocation =>
      currentAddress ?? permanentAddress ?? 'N/A';

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}
