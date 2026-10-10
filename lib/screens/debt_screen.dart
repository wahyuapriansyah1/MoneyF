import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../state/finance_state.dart';
import '../widgets/responsive_layout.dart';
import 'add_record_screen.dart';

class DebtScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<int>? onNavigateTab;

  const DebtScreen({
    super.key,
    this.onBack,
    this.onNavigateTab,
  });

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = FinanceProvider.of(context);
    final debtRecords =
        state.records.where((r) => r.type == RecordType.debt).toList();
    final utangList =
        debtRecords.where((r) => r.debtType == DebtType.payable).toList();
    final piutangList =
        debtRecords.where((r) => r.debtType == DebtType.receivable).toList();

    return Material(
      color: Colors.transparent,
      child: Container(
        color: AppColors.bgScreen,
        child: SafeArea(
          bottom: false,
          child: ResponsiveLayout(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _handleBack,
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                        splashRadius: 20,
                        tooltip: 'Kembali',
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'Utang / Piutang',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddRecordScreen(
                              initialType: RecordType.debt,
                              initialDebtType: _tabController.index == 0
                                  ? DebtType.payable
                                  : DebtType.receivable,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Tambah',
                            style: TextStyle(fontSize: 12)),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tab bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _TabBtn2(
                          label: 'Utang Saya',
                          selected: _tabController.index == 0,
                          onTap: () => _tabController.animateTo(0),
                        ),
                        _TabBtn2(
                          label: 'Piutang Saya',
                          selected: _tabController.index == 1,
                          onTap: () => _tabController.animateTo(1),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Summary cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCard2(
                          label: 'Total Utang',
                          amount: state.formatCurrency(state.totalDebtPayable),
                          icon: Icons.upload_rounded,
                          color: AppColors.negative,
                          bgColor: const Color(0xFFFFEBEE),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard2(
                          label: 'Total Piutang',
                          amount: state
                              .formatCurrency(state.totalDebtReceivable),
                          icon: Icons.download_rounded,
                          color: AppColors.positive,
                          bgColor: const Color(0xFFE8F5E9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // List
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _DebtList(
                        items: utangList,
                        emptyLabel: 'Tidak ada utang saat ini',
                        isPayable: true,
                      ),
                      _DebtList(
                        items: piutangList,
                        emptyLabel: 'Tidak ada piutang saat ini',
                        isPayable: false,
                      ),
                    ],
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

class _TabBtn2 extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabBtn2(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard2 extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;
  final Color bgColor;
  const _SummaryCard2({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    amount,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtList extends StatelessWidget {
  final List<FinancialRecord> items;
  final String emptyLabel;
  final bool isPayable;
  const _DebtList({
    required this.items,
    required this.emptyLabel,
    required this.isPayable,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 56,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              emptyLabel,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _DebtTile(item: items[i]),
    );
  }
}

class _DebtTile extends StatelessWidget {
  final FinancialRecord item;
  const _DebtTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final state = FinanceProvider.of(context);
    final isPayable = item.debtType == DebtType.payable;
    final amountColor = isPayable ? AppColors.negative : AppColors.positive;
    final iconBg = isPayable
        ? const Color(0xFFFFEBEE)
        : const Color(0xFFE8F5E9);

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final dateStr =
        'Jatuh tempo ${item.date.day} ${months[item.date.month - 1]} ${item.date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(item.categoryIcon, size: 20, color: amountColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.personName ?? item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  state.formatCurrency(item.amount),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: amountColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => state.toggleDebtPaid(item.id),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: item.isPaid
                        ? AppColors.badgePaidBg
                        : AppColors.badgeUnpaidBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.isPaid ? 'Lunas' : 'Belum dibayar',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: item.isPaid
                          ? AppColors.badgePaidText
                          : AppColors.badgeUnpaidText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
