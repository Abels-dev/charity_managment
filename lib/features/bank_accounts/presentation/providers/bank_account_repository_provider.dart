import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/core/network/api_client.dart';
import 'package:charity_managment/features/bank_accounts/data/api_bank_account_repository.dart';

final bankAccountRepositoryProvider = Provider<ApiBankAccountRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiBankAccountRepository(dio);
});

final bankAccountsProvider = FutureProvider<List<BankAccount>>((ref) async {
  final repository = ref.watch(bankAccountRepositoryProvider);
  return repository.listMyBankAccounts();
});

class BankAccountMutationController extends StateNotifier<AsyncValue<void>> {
  BankAccountMutationController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  ApiBankAccountRepository get _repository => _ref.read(bankAccountRepositoryProvider);

  Future<void> create({
    required String bankName,
    required String accountHolder,
    required String accountNumber,
    required String type,
    required bool isPrimary,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createBankAccount(
        bankName: bankName,
        accountHolder: accountHolder,
        accountNumber: accountNumber,
        type: type,
        isPrimary: isPrimary,
      );
      _ref.invalidate(bankAccountsProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> update({
    required String accountId,
    required String bankName,
    required String accountHolder,
    required String accountNumber,
    required String type,
    required bool isPrimary,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateBankAccount(
        accountId: accountId,
        bankName: bankName,
        accountHolder: accountHolder,
        accountNumber: accountNumber,
        type: type,
        isPrimary: isPrimary,
      );
      _ref.invalidate(bankAccountsProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> remove(String accountId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteBankAccount(accountId);
      _ref.invalidate(bankAccountsProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> setPrimary(String accountId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.setPrimaryBankAccount(accountId);
      _ref.invalidate(bankAccountsProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final bankAccountMutationProvider =
    StateNotifierProvider<BankAccountMutationController, AsyncValue<void>>(
  (ref) => BankAccountMutationController(ref),
);
