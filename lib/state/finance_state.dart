import 'package:flutter/material.dart';
import '../models.dart';

class FinanceState extends ChangeNotifier {
  final List<FinancialRecord> _records = [];
  String _currency = 'IDR'; // 'IDR' or 'USD'

  List<FinancialRecord> get records => List.unmodifiable(_records);
  String get currency => _currency;

  void setCurrency(String newCurrency) {
    _currency = newCurrency;
    notifyListeners();
  }

  // Calculate Total Pemasukan (Income)
  double get totalIncome {
    return _records
        .where((r) => r.type == RecordType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Calculate Total Pengeluaran (Expense)
  double get totalExpense {
    return _records
        .where((r) => r.type == RecordType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Calculate Total Balance (Saldo Kas Nyata = Pemasukan - Pengeluaran + Utang Belum Lunas - Piutang Belum Lunas)
  double get totalBalance {
    return totalIncome - totalExpense + totalDebtPayable - totalDebtReceivable;
  }

  // Calculate Total Utang Saya (Belum Lunas)
  double get totalDebtPayable {
    return _records
        .where((r) => r.type == RecordType.debt && r.debtType == DebtType.payable && !r.isPaid)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Calculate Total Piutang / Uang Dipinjamkan (Belum Lunas)
  double get totalDebtReceivable {
    return _records
        .where((r) => r.type == RecordType.debt && r.debtType == DebtType.receivable && !r.isPaid)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Add Record
  void addRecord(FinancialRecord record) {
    _records.insert(0, record);
    notifyListeners();
  }

  // Update Record
  void updateRecord(FinancialRecord updatedRecord) {
    final index = _records.indexWhere((r) => r.id == updatedRecord.id);
    if (index != -1) {
      _records[index] = updatedRecord;
      notifyListeners();
    }
  }

  // Delete Record
  void deleteRecord(String id) {
    _records.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // Toggle Debt Paid Status
  void toggleDebtPaid(String id) {
    final index = _records.indexWhere((r) => r.id == id);
    if (index != -1) {
      _records[index].isPaid = !_records[index].isPaid;
      notifyListeners();
    }
  }

  // Formatting currency helper without external dependencies
  String formatCurrency(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    
    if (_currency == 'IDR') {
      final whole = absAmount.toInt().toString();
      final buffer = StringBuffer();
      for (int i = 0; i < whole.length; i++) {
        if (i > 0 && (whole.length - i) % 3 == 0) {
          buffer.write('.');
        }
        buffer.write(whole[i]);
      }
      final sign = isNegative ? '-' : '';
      return '${sign}Rp $buffer';
    } else {
      final whole = absAmount.toInt().toString();
      final decimal = (absAmount - absAmount.toInt()).toStringAsFixed(2).substring(1);
      final buffer = StringBuffer();
      for (int i = 0; i < whole.length; i++) {
        if (i > 0 && (whole.length - i) % 3 == 0) {
          buffer.write(',');
        }
        buffer.write(whole[i]);
      }
      final sign = isNegative ? '-' : '';
      return '$sign\$ $buffer$decimal';
    }
  }

  // Clear data
  void resetData() {
    _records.clear();
    notifyListeners();
  }
}

class FinanceProvider extends InheritedNotifier<FinanceState> {
  const FinanceProvider({
    super.key,
    required FinanceState financeState,
    required super.child,
  }) : super(notifier: financeState);

  static FinanceState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FinanceProvider>()!.notifier!;
  }
}
