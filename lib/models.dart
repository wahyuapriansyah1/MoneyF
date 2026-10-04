import 'package:flutter/material.dart';

enum RecordType { income, expense, debt }

enum DebtType { payable, receivable } // payable: Utang Saya, receivable: Piutang Orang

class FinancialRecord {
  final String id;
  String title;
  double amount;
  RecordType type;
  DebtType? debtType;
  String category;
  IconData categoryIcon;
  DateTime date;
  String? note;
  String? personName;
  bool isPaid;

  FinancialRecord({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    this.debtType,
    required this.category,
    required this.categoryIcon,
    required this.date,
    this.note,
    this.personName,
    this.isPaid = false,
  });

  FinancialRecord copyWith({
    String? title,
    double? amount,
    RecordType? type,
    DebtType? debtType,
    String? category,
    IconData? categoryIcon,
    DateTime? date,
    String? note,
    String? personName,
    bool? isPaid,
  }) {
    return FinancialRecord(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      debtType: debtType ?? this.debtType,
      category: category ?? this.category,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      date: date ?? this.date,
      note: note ?? this.note,
      personName: personName ?? this.personName,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}

class Contact {
  final String name;
  final String initials;
  final Color avatarBg;
  final String? phone;

  const Contact({
    required this.name,
    required this.initials,
    required this.avatarBg,
    this.phone,
  });
}

class CategoryOption {
  final String name;
  final IconData icon;
  final RecordType type;

  const CategoryOption({
    required this.name,
    required this.icon,
    required this.type,
  });
}

const List<CategoryOption> defaultCategories = [
  // Pemasukan
  CategoryOption(name: 'Gaji', icon: Icons.payments_rounded, type: RecordType.income),
  CategoryOption(name: 'Bonus', icon: Icons.card_giftcard_rounded, type: RecordType.income),
  CategoryOption(name: 'Usaha', icon: Icons.storefront_rounded, type: RecordType.income),
  CategoryOption(name: 'Investasi', icon: Icons.trending_up_rounded, type: RecordType.income),
  CategoryOption(name: 'Lainnya', icon: Icons.add_circle_outline_rounded, type: RecordType.income),

  // Pengeluaran
  CategoryOption(name: 'Makanan', icon: Icons.restaurant_rounded, type: RecordType.expense),
  CategoryOption(name: 'Belanja', icon: Icons.shopping_bag_rounded, type: RecordType.expense),
  CategoryOption(name: 'Tagihan', icon: Icons.receipt_long_rounded, type: RecordType.expense),
  CategoryOption(name: 'Transport', icon: Icons.directions_car_rounded, type: RecordType.expense),
  CategoryOption(name: 'Hiburan', icon: Icons.movie_rounded, type: RecordType.expense),
  CategoryOption(name: 'Kesehatan', icon: Icons.medical_services_rounded, type: RecordType.expense),

  // Utang
  CategoryOption(name: 'Pinjaman Pribadi', icon: Icons.person_rounded, type: RecordType.debt),
  CategoryOption(name: 'Pinjaman Bank', icon: Icons.account_balance_rounded, type: RecordType.debt),
  CategoryOption(name: 'Cicilan Barang', icon: Icons.devices_rounded, type: RecordType.debt),
];

const mockContacts = [
  Contact(
    name: 'Emon',
    initials: 'EM',
    avatarBg: Color(0xFFF7C9A8),
    phone: '+628123456789',
  ),
  Contact(
    name: 'Angeli',
    initials: 'AG',
    avatarBg: Color(0xFFC9DCF0),
    phone: '+628987654321',
  ),
  Contact(
    name: 'Rumen',
    initials: 'RM',
    avatarBg: Color(0xFFD9C6F0),
    phone: '+628555444333',
  ),
  Contact(
    name: 'Eloana',
    initials: 'EM',
    avatarBg: Color(0xFFF6D77A),
    phone: '+628163556031',
  ),
];

List<FinancialRecord> initialMockRecords = [
  FinancialRecord(
    id: '1',
    title: 'Gaji Bulanan',
    amount: 7500000,
    type: RecordType.income,
    category: 'Gaji',
    categoryIcon: Icons.payments_rounded,
    date: DateTime.now().subtract(const Duration(days: 1)),
    note: 'Gaji bulan Agustus',
  ),
  FinancialRecord(
    id: '2',
    title: 'Makan Siang & Kopi',
    amount: 85000,
    type: RecordType.expense,
    category: 'Makanan',
    categoryIcon: Icons.restaurant_rounded,
    date: DateTime.now().subtract(const Duration(hours: 3)),
    note: 'Resto Padang & Kopi',
  ),
  FinancialRecord(
    id: '3',
    title: 'Pinjam Uang ke Budi',
    amount: 500000,
    type: RecordType.debt,
    debtType: DebtType.payable,
    category: 'Pinjaman Pribadi',
    categoryIcon: Icons.person_rounded,
    date: DateTime.now().subtract(const Duration(days: 2)),
    personName: 'Budi Kurniawan',
    note: 'Jatuh tempo minggu depan',
    isPaid: false,
  ),
  FinancialRecord(
    id: '4',
    title: 'Piutang Andi (Pinjam Uang)',
    amount: 300000,
    type: RecordType.debt,
    debtType: DebtType.receivable,
    category: 'Pinjaman Pribadi',
    categoryIcon: Icons.person_rounded,
    date: DateTime.now().subtract(const Duration(days: 4)),
    personName: 'Andi Pratama',
    note: 'Janji bayar akhir bulan',
    isPaid: false,
  ),
  FinancialRecord(
    id: '5',
    title: 'Belanja Bulanan Supermarket',
    amount: 450000,
    type: RecordType.expense,
    category: 'Belanja',
    categoryIcon: Icons.shopping_bag_rounded,
    date: DateTime.now().subtract(const Duration(days: 3)),
  ),
  FinancialRecord(
    id: '6',
    title: 'Bonus Proyek',
    amount: 1200000,
    type: RecordType.income,
    category: 'Bonus',
    categoryIcon: Icons.card_giftcard_rounded,
    date: DateTime.now().subtract(const Duration(days: 5)),
  ),
];
