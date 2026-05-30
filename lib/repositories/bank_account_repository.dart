import 'package:dio/dio.dart';

class BankAccount {
  final String id;
  final String accountNumber;
  final String accountHolderName;
  final String bankName;
  final String bankCode;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;

  BankAccount({
    required this.id,
    required this.accountNumber,
    required this.accountHolderName,
    required this.bankName,
    required this.bankCode,
    required this.isPrimary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id']?.toString() ?? '',
      accountNumber: json['accountNumber'] ?? '',
      accountHolderName: json['accountHolderName'] ?? '',
      bankName: json['bankName'] ?? '',
      bankCode: json['bankCode'] ?? '',
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
      'accountHolderName': accountHolderName,
      'bankName': bankName,
      'bankCode': bankCode,
      'isPrimary': isPrimary,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  BankAccount copyWith({
    String? id,
    String? accountNumber,
    String? accountHolderName,
    String? bankName,
    String? bankCode,
    bool? isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BankAccount(
      id: id ?? this.id,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankName: bankName ?? this.bankName,
      bankCode: bankCode ?? this.bankCode,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ApiBankAccountRepository {
  final Dio _dio;

  ApiBankAccountRepository(this._dio);

  BankAccount _mapBankAccount(Map<String, dynamic> json) {
    return BankAccount.fromJson(json);
  }

  Future<List<BankAccount>> listMyBankAccounts() async {
    try {
      final response = await _dio.get('/api/bank-accounts/me');
      final List items = response.data['data']?['items'] ?? response.data['data'] ?? [];

      return items
          .whereType<Map>()
          .map((e) => _mapBankAccount(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } catch (e) {
      throw Exception('Failed to fetch bank accounts');
    }
  }

  Future<BankAccount> createBankAccount({
    required String accountNumber,
    required String accountHolderName,
    required String bankName,
    required String bankCode,
    bool isPrimary = false,
  }) async {
    try {
      final response = await _dio.post(
        '/api/bank-accounts',
        data: {
          'accountNumber': accountNumber,
          'accountHolderName': accountHolderName,
          'bankName': bankName,
          'bankCode': bankCode,
          'isPrimary': isPrimary,
        },
      );
      return _mapBankAccount(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create bank account');
    }
  }

  Future<BankAccount> updateBankAccount({
    required String accountId,
    String? accountNumber,
    String? accountHolderName,
    String? bankName,
    String? bankCode,
    bool? isPrimary,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (accountNumber != null) data['accountNumber'] = accountNumber;
      if (accountHolderName != null) data['accountHolderName'] = accountHolderName;
      if (bankName != null) data['bankName'] = bankName;
      if (bankCode != null) data['bankCode'] = bankCode;
      if (isPrimary != null) data['isPrimary'] = isPrimary;

      final response = await _dio.put('/api/bank-accounts/$accountId', data: data);
      return _mapBankAccount(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update bank account');
    }
  }

  Future<void> deleteBankAccount(String accountId) async {
    try {
      await _dio.delete('/api/bank-accounts/$accountId');
    } catch (e) {
      throw Exception('Failed to delete bank account');
    }
  }

  Future<BankAccount> setPrimaryBankAccount(String accountId) async {
    try {
      final response = await _dio.put(
        '/api/bank-accounts/$accountId',
        data: {'isPrimary': true},
      );
      return _mapBankAccount(response.data['data']);
    } catch (e) {
      throw Exception('Failed to set primary bank account');
    }
  }
}
