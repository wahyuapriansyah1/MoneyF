import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../state/finance_state.dart';
import '../widgets/responsive_layout.dart';
import 'add_record_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;
  const HomeScreen({super.key, this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _transactionFilter = 0; // 0: Semua, 1: Pemasukan, 2: Pengeluaran, 3: Utang

  @override
  Widget build(BuildContext context) {
    final state = FinanceProvider.of(context);

    final filteredRecords = state.records.where((r) {
      if (_transactionFilter == 1) return r.type == RecordType.income;
      if (_transactionFilter == 2) return r.type == RecordType.expense;
      if (_transactionFilter == 3) return r.type == RecordType.debt;
      return true;
    }).toList();

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: screenBackground(),
        child: SafeArea(
          bottom: false,
          child: ResponsiveLayout(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                const _Header(),
                const SizedBox(height: 20),

                // Main Balance Section
                _BalanceSection(state: state),
                const SizedBox(height: 16),

                // Quick Financial Metrics Breakdown (Pemasukan, Pengeluaran, Utang)
                _MetricsRow(state: state, onNavigateTab: widget.onNavigateTab),
                const SizedBox(height: 16),

                // Quick Action Buttons
                _QuickActionsRow(
                  onAddIncome: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddRecordScreen(initialType: RecordType.income),
                      ),
                    );
                  },
                  onAddExpense: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddRecordScreen(initialType: RecordType.expense),
                      ),
                    );
                  },
                  onAddDebt: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddRecordScreen(initialType: RecordType.debt),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Recent Transactions Header & Filter
                _TransactionsHeader(
                  selectedFilter: _transactionFilter,
                  onFilterChanged: (filterIndex) {
                    setState(() {
                      _transactionFilter = filterIndex;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Transaction Items List Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: filteredRecords.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 40,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Belum ada transaksi di kategori ini',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: filteredRecords.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            thickness: 0.8,
                            color: Colors.black.withValues(alpha: 0.05),
                          ),
                          itemBuilder: (context, index) {
                            return _TransactionTile(item: filteredRecords[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatefulWidget {
  const _Header();

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  String _formatIndonesianDate(DateTime dt) {
    const days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    final dayName = days[dt.weekday - 1];
    final monthName = months[dt.month - 1];

    return '$dayName, ${dt.day} $monthName ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selamat Datang',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _formatIndonesianDate(now),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _BalanceSection extends StatelessWidget {
  final FinanceState state;
  const _BalanceSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = '${now.day} ${_monthName(now.month)} ${now.year}';

    return Column(
      children: [
        const Text(
          'Total Saldo Bersih',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            state.formatCurrency(state.totalBalance),
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Hari ini $dateStr',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }
}

class _MetricsRow extends StatelessWidget {
  final FinanceState state;
  final ValueChanged<int>? onNavigateTab;

  const _MetricsRow({required this.state, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: 'Pemasukan',
            amount: state.formatCurrency(state.totalIncome),
            icon: Icons.south_west_rounded,
            accentColor: AppColors.positive,
            bgColor: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            title: 'Pengeluaran',
            amount: state.formatCurrency(state.totalExpense),
            icon: Icons.north_east_rounded,
            accentColor: Colors.redAccent,
            bgColor: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => onNavigateTab?.call(2), // Navigate to Debt Tab
            child: _MetricCard(
              title: 'Utang/Piutang',
              amount: state.formatCurrency(state.totalDebtPayable),
              icon: Icons.handshake_rounded,
              accentColor: Colors.orangeAccent,
              bgColor: AppColors.chipYellow.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;

  const _MetricCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.accentColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: accentColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;
  final VoidCallback onAddDebt;

  const _QuickActionsRow({
    required this.onAddIncome,
    required this.onAddExpense,
    required this.onAddDebt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: Icons.add_circle_outline_rounded,
          label: 'Pemasukan',
          color: AppColors.positive,
          onTap: onAddIncome,
        ),
        _ActionButton(
          icon: Icons.remove_circle_outline_rounded,
          label: 'Pengeluaran',
          color: Colors.redAccent,
          onTap: onAddExpense,
        ),
        _ActionButton(
          icon: Icons.handshake_outlined,
          label: 'Utang/Piutang',
          color: Colors.deepOrange,
          onTap: onAddDebt,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionsHeader extends StatelessWidget {
  final int selectedFilter;
  final ValueChanged<int> onFilterChanged;

  const _TransactionsHeader({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Riwayat Transaksi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _FilterChip(
                label: 'Semua',
                isSelected: selectedFilter == 0,
                onTap: () => onFilterChanged(0),
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: 'Pemasukan',
                isSelected: selectedFilter == 1,
                onTap: () => onFilterChanged(1),
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: 'Pengeluaran',
                isSelected: selectedFilter == 2,
                onTap: () => onFilterChanged(2),
              ),
              const SizedBox(width: 6),
              _FilterChip(
                label: 'Utang / Piutang',
                isSelected: selectedFilter == 3,
                onTap: () => onFilterChanged(3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final FinancialRecord item;
  const _TransactionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final state = FinanceProvider.of(context);
    final isIncome = item.type == RecordType.income;
    final isDebt = item.type == RecordType.debt;
    final sign = isIncome ? '+' : (isDebt ? '' : '-');

    Color iconBg = AppColors.inputFill;
    IconData icon = item.categoryIcon;
    Color amountColor = AppColors.textPrimary;

    if (isIncome) {
      amountColor = AppColors.positive;
    } else if (item.type == RecordType.expense) {
      amountColor = Colors.redAccent;
    } else {
      amountColor = item.debtType == DebtType.payable ? Colors.deepOrange : Colors.blueAccent;
    }

    final dateStr = '${item.date.day}/${item.date.month}/${item.date.year}';

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        state.deleteRecord(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaksi "${item.title}" dihapus')),
        );
      },
      child: InkWell(
        onTap: () {
          // Edit Record
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddRecordScreen(recordToEdit: item),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '• $dateStr',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$sign${state.formatCurrency(item.amount)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: amountColor,
                    ),
                  ),
                  if (isDebt)
                    Text(
                      item.isPaid ? 'LUNAS' : 'BELUM LUNAS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: item.isPaid ? Colors.green : Colors.redAccent,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 6),
              const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
