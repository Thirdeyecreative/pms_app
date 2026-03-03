import '../core/api_client.dart';
import '../models/employee_model.dart';
import '../models/extended_models.dart';

class EmployeeService {
  Future<EmployeeModel> getEmployee(String id) async {
    final data = await ApiClient.get('/employees/$id');
    return EmployeeModel.fromJson(data);
  }

  Future<void> updateProfile(String id, Map<String, dynamic> fields) async {
    await ApiClient.patch('/employees/$id', body: fields);
  }

  Future<List<SalaryStructure>> getSalaryStructures(String employeeId) async {
    try {
      final data = await ApiClient.get('/salary-structures/?employee_id=$employeeId');
      final list = data is List ? data : (data['data'] ?? data['items'] ?? []);
      return (list as List).map((e) => SalaryStructure.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
