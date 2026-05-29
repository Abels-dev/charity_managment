import 'package:dio/dio.dart';

/// Represents a bank account for charity fund withdrawals
class BankAccount {
  final String id;
  final String accountNumber;
  final String accountHolder;
  final String bankName;
  final String type;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;

  BankAccount({
    required this.id,
    required this.accountNumber,
    required this.accountHolder,
    required this.bankName,
    required this.type,
    required this.isPrimary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id']?.toString() ?? '',
      accountNumber: json['accountNumber'] ?? '',
      accountHolder: json['accountHolder'] ?? '',
      bankName: json['bankName'] ?? '',
      type: json['type']?.toString() ?? 'PERSONAL',
      isPrimary: json['isPrimary'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountNumber': accountNumber,
      'accountHolder': accountHolder,
      'bankName': bankName,
      'type': type,
      'isPrimary': isPrimary,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  BankAccount copyWith({
    String? id,
    String? accountNumber,
    String? accountHolder,
    String? bankName,
    String? type,
    bool? isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BankAccount(
      id: id ?? this.id,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolder: accountHolder ?? this.accountHolder,
      bankName: bankName ?? this.bankName,
      type: type ?? this.type,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Repository for managing charity bank accounts
class ApiBankAccountRepository {
  ApiBankAccountRepository(this._dio);

  final Dio _dio;

  BankAccount _mapBankAccount(Map<String, dynamic> json) {
    return BankAccount.fromJson(json);
  }

  /// Fetch all bank accounts for the current charity
  Future<List<BankAccount>> listMyBankAccounts() async {
    try {
      final response = await _dio.get('/api/bank-accounts/me');
      final List items = response.data['accounts'] ?? const [];

      return items
          .whereType<Map>()
          .map((e) => _mapBankAccount(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } catch (e) {
      throw Exception('Failed to fetch bank accounts');
    }
  }

  /// Create a new bank account
  Future<BankAccount> createBankAccount({
    required String accountNumber,
    required String accountHolder,
    required String bankName,
    String type = 'PERSONAL',
    bool isPrimary = false,
  }) async {
    try {
      final response = await _dio.post(
        '/api/bank-accounts',
        data: {
          'accountNumber': accountNumber,
          'accountHolder': accountHolder,
          'bankName': bankName,
          'type': type,
          'isPrimary': isPrimary,
        },
      );
      return _mapBankAccount(Map<String, dynamic>.from(response.data['account']));
    } catch (e) {
      throw Exception('Failed to create bank account');
    }
  }

  /// Update an existing bank account
  Future<BankAccount> updateBankAccount({
    required String accountId,
    String? accountNumber,
    String? accountHolder,
    String? bankName,
    String? type,
    bool? isPrimary,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (accountNumber != null) data['accountNumber'] = accountNumber;
      if (accountHolder != null) data['accountHolder'] = accountHolder;
      if (bankName != null) data['bankName'] = bankName;
      if (type != null) data['type'] = type;
      if (isPrimary != null) data['isPrimary'] = isPrimary;

      final response = await _dio.put('/api/bank-accounts/$accountId', data: data);
      return _mapBankAccount(Map<String, dynamic>.from(response.data['account']));
    } catch (e) {
      throw Exception('Failed to update bank account');
    }
  }

  /// Delete a bank account
  Future<void> deleteBankAccount(String accountId) async {
    try {
      await _dio.delete('/api/bank-accounts/$accountId');
    } catch (e) {
      throw Exception('Failed to delete bank account');
    }
  }

  /// Set a bank account as primary for withdrawals
  Future<BankAccount> setPrimaryBankAccount(String accountId) async {
    try {
      final response = await _dio.put(
        '/api/bank-accounts/$accountId',
        data: {'isPrimary': true},
      );
      return _mapBankAccount(Map<String, dynamic>.from(response.data['account']));
    } catch (e) {
      throw Exception('Failed to set primary bank account');
    }
  }
}
