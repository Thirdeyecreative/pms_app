import '../core/api_client.dart';
import '../models/expense_model.dart';

class ExpenseService {
  Future<List<ExpenseCategory>> getCategories() async {
    try {
      final data = await ApiClient.get('/expenses/categories/?active_only=true');
      final list = data is List ? data : (data['data'] ?? data['items'] ?? []);
      return (list as List).map((e) => ExpenseCategory.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<ExpenseClaim>> getMyClaims() async {
    try {
      final data = await ApiClient.get('/expense-claims/my-claims');
      final list = data is List ? data : (data['data'] ?? data['items'] ?? []);
      return (list as List).map((e) => ExpenseClaim.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<ExpenseClaim> createClaim({
    required String categoryId,
    required double amount,
    required String expenseDate,
    required String description,
  }) async {
    final data = await ApiClient.post('/expense-claims', body: {
      'category_id': categoryId,
      'amount': amount,
      'expense_date': expenseDate,
      'description': description,
    });
    return ExpenseClaim.fromJson(data);
  }
}
