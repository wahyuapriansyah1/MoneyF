import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneyf/models.dart';
import 'package:moneyf/state/finance_state.dart';

void main() {
  group('FinanceState - Perhitungan Total Uang Bersih (Total Balance)', () {
    test('Total Uang Bersih berkurang otomatis ketika ada Piutang yang belum lunas', () {
      final state = FinanceState();
      
      // Hitung manual:
      // Income - Expense - Piutang (belum lunas)
      final expected = state.totalIncome - state.totalExpense - state.totalDebtReceivable;
      expect(state.totalBalance, expected);

      // Tambahkan Piutang baru sebesar 200.000
      final initialBalance = state.totalBalance;
      state.addRecord(
        FinancialRecord(
          id: 'test_piutang_1',
          title: 'Pinjamkan ke Dina',
          amount: 200000,
          type: RecordType.debt,
          debtType: DebtType.receivable,
          category: 'Pinjaman Pribadi',
          categoryIcon: Icons.person_rounded,
          date: DateTime.now(),
          isPaid: false,
        ),
      );

      // Saldo bersih harus berkurang tepat 200.000
      expect(state.totalBalance, initialBalance - 200000);

      // Jika piutang tersebut dilunasi (isPaid = true), saldo bersih bertambah kembali
      state.toggleDebtPaid('test_piutang_1');
      expect(state.totalBalance, initialBalance);
    });

    test('Piutang yang sudah lunas tidak mengurangi Total Uang Bersih', () {
      final state = FinanceState();
      final balanceBefore = state.totalBalance;

      state.addRecord(
        FinancialRecord(
          id: 'test_piutang_lunas',
          title: 'Piutang Lama Lunas',
          amount: 500000,
          type: RecordType.debt,
          debtType: DebtType.receivable,
          category: 'Pinjaman Pribadi',
          categoryIcon: Icons.person_rounded,
          date: DateTime.now(),
          isPaid: true,
        ),
      );

      // Saldo tidak boleh berubah karena sudah lunas
      expect(state.totalBalance, balanceBefore);
    });
  });
}
