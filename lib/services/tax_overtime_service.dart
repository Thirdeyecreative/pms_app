import '../core/api_client.dart';
import '../models/extended_models.dart';

class TaxService {
  Future<List<TaxDeclaration>> getTaxDeclarations() async {
    try {
      final data = await ApiClient.get('/my-payroll/tax-declarations');
      final list = data is List ? data : (data['data'] ?? data['items'] ?? []);
      return (list as List).map((e) => TaxDeclaration.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> deleteTaxDeclaration(String id) async {
    await ApiClient.delete('/my-payroll/tax-declarations/$id');
  }

  Future<List<Form16>> getMyForm16s() async {
    try {
      final data = await ApiClient.get('/form16/my-snapshots');
      final list = data is List ? data : (data['data'] ?? data['items'] ?? []);
      return (list as List).map((e) => Form16.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }
}

class OvertimeService {
  Future<List<OvertimeRequest>> getMyRequests() async {
    try {
      final data = await ApiClient.get('/overtime/my-requests');
      final list = data is List ? data : (data['data'] ?? data['items'] ?? []);
      return (list as List).map((e) => OvertimeRequest.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> actionRequest(String id, String action, {String? reason}) async {
    await ApiClient.post('/overtime/requests/$id/action', body: {
      'action': action,
      if (reason != null) 'reason': reason,
    });
  }
}
