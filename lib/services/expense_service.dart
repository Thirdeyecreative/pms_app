import 'package:flutter/foundation.dart';
import '../core/api_client.dart';
import '../models/expense_model.dart';

class ExpenseService {
  Future<List<ExpenseCategory>> getCategories() async {
    try {
      final data = await ApiClient.get('/expenses/categories?active_only=true');
      final list = data is List ? data : (data['data'] ?? data['items'] ?? []);
      return (list as List).map((e) => ExpenseCategory.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
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
    String? receiptPath,
    String? receiptFileName,
  }) async {
    final fields = {
      'category_id': categoryId,
      'amount': amount.toString(),
      'expense_date': expenseDate,
      'description': description,
    };

    final data = await ApiClient.multipartPost(
      '/expense-claims',
      fields: fields,
      fileKey: 'receipt_file',
      filePath: receiptPath,
      fileName: receiptFileName,
    );
    return ExpenseClaim.fromJson(data);
  }

  Future<List<ExpenseClaim>> getAllClaims() async {
    try {
      final data = await ApiClient.get('/expense-claims/all');
      final list = data is List ? data : (data['data'] ?? data['items'] ?? []);
      return (list as List).map((e) => ExpenseClaim.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<ExpenseClaim> updateClaimStatus(String id, String status, {String? summary}) async {
    final data = await ApiClient.put('/expense-claims/$id/status', body: {
      'status': status,
      'summary': summary,
    });
    return ExpenseClaim.fromJson(data);
  }
}

