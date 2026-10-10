import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../state/finance_state.dart';
import '../widgets/responsive_layout.dart';
import 'add_record_screen.dart';

enum TransactionSortOption {
  newest,
  oldest,
  largestAmount,
  smallestAmount,
}

class AllTransactionsScreen extends StatefulWidget {
  final RecordType? initialFilter;

  const AllTransactionsScreen({
    super.key,
    this.initialFilter,
  });

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  RecordType? _selectedTypeFilter;
  TransactionSortOption _sortOption = TransactionSortOption.newest;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedTypeFilter = widget.initialFilter;
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FinancialRecord> _getFilteredRecords(List<FinancialRecord> records) {
    var result = records.where((r) {
      // Filter by type
      if (_selectedTypeFilter != null && r.type != _selectedTypeFilter) {
        return false;
      }
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final matchesTitle = r.title.toLowerCase().contains(_searchQuery);
        final matchesCategory = r.category.toLowerCase().contains(_searchQuery);
        final matchesNote = (r.note ?? '').toLowerCase().contains(_searchQuery);
        final matchesPerson =
            (r.personName ?? '').toLowerCase().contains(_searchQuery);
        final matchesAmount = r.amount.toInt().toString().contains(_searchQuery);
        if (!matchesTitle &&
            !matchesCategory &&
            !matchesNote &&
            !matchesPerson &&
            !matchesAmount) {
          return false;
        }
      }
      return true;
    }).toList();

    // Sorting
    switch (_sortOption) {
      case TransactionSortOption.newest:
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
      case TransactionSortOption.oldest:
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case TransactionSortOption.largestAmount:
        result.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case TransactionSortOption.smallestAmount:
        result.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return result;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Hari Ini';
    } else if (targetDate == today.subtract(const Duration(days: 1))) {
      return 'Kemarin';
    }

    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = FinanceProvider.of(context);
    final filtered = _getFilteredRecords(state.records);

    final totalIncome = filtered
        .where((r) => r.type == RecordType.income)
        .fold(0.0, (sum, r) => sum + r.amount);
    final totalExpense = filtered
        .where((r) => r.type == RecordType.expense)
        .fold(0.0, (sum, r) => sum + r.amount);

    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Semua Transaksi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          PopupMenuButton<TransactionSortOption>(
            icon: const Icon(
              Icons.sort_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
            tooltip: 'Urutkan',
            onSelected: (val) => setState(() => _sortOption = val),
            itemBuilder: (ctx) => [
              _buildSortItem(
                TransactionSortOption.newest,
                'Terbaru (Tanggal)',
              ),
              _buildSortItem(
                TransactionSortOption.oldest,
                'Terlama (Tanggal)',
              ),
              _buildSortItem(
                TransactionSortOption.largestAmount,
                'Nominal Terbesar',
              ),
              _buildSortItem(
                TransactionSortOption.smallestAmount,
                'Nominal Terkecil',
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveLayout(
        child: Column(
          children: [
            // Header Search & Filter Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  // Search Box
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.bgScreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari catatan, kategori, nominal...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () => _searchController.clear(),
                                child: const Icon(
                                  Icons.cancel_rounded,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'Semua',
                          isSelected: _selectedTypeFilter == null,
                          onTap: () => setState(() => _selectedTypeFilter = null),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Pengeluaran',
                          isSelected:
                              _selectedTypeFilter == RecordType.expense,
                          onTap: () => setState(
                            () => _selectedTypeFilter = RecordType.expense,
                          ),
                          activeColor: AppColors.negative,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Pemasukan',
                          isSelected:
                              _selectedTypeFilter == RecordType.income,
                          onTap: () => setState(
                            () => _selectedTypeFilter = RecordType.income,
                          ),
                          activeColor: AppColors.positive,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Utang / Piutang',
                          isSelected: _selectedTypeFilter == RecordType.debt,
                          onTap: () => setState(
                            () => _selectedTypeFilter = RecordType.debt,
                          ),
                          activeColor: AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Summary mini card of current view
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    '${filtered.length} Transaksi',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedTypeFilter == null ||
                      _selectedTypeFilter == RecordType.income) ...[
                    Text(
                      '+${state.formatCurrency(totalIncome)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.positive,
                      ),
                    ),
                  ],
                  if (_selectedTypeFilter == null) const SizedBox(width: 12),
                  if (_selectedTypeFilter == null ||
                      _selectedTypeFilter == RecordType.expense) ...[
                    Text(
                      '-${state.formatCurrency(totalExpense)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.negative,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Transaction List
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final showDateHeader = index == 0 ||
                            _formatDateHeader(item.date) !=
                                _formatDateHeader(filtered[index - 1].date);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDateHeader)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 14,
                                  bottom: 8,
                                  left: 4,
                                ),
                                child: Text(
                                  _formatDateHeader(item.date),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            _buildTransactionCard(context, item, state),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<TransactionSortOption> _buildSortItem(
    TransactionSortOption value,
    String label,
  ) {
    final isSelected = _sortOption == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
          if (isSelected)
            const Icon(
              Icons.check_rounded,
              size: 18,
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color activeColor = AppColors.primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppColors.bgScreen,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? activeColor
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    FinancialRecord item,
    FinanceState state,
  ) {
    final isIncome = item.type == RecordType.income;
    final isDebt = item.type == RecordType.debt;

    Color iconBg;
    Color amountColor;
    String sign;

    if (isIncome) {
      iconBg = const Color(0xFFE8F5E9);
      amountColor = AppColors.positive;
      sign = '+ ';
    } else if (isDebt) {
      iconBg = const Color(0xFFFFF3E0);
      amountColor = AppColors.warning;
      sign = '';
    } else {
      iconBg = const Color(0xFFFFEBEE);
      amountColor = AppColors.negative;
      sign = '- ';
    }

    final typeLabel = isIncome
        ? 'Pemasukan'
        : isDebt
            ? (item.debtType == DebtType.payable ? 'Utang' : 'Piutang')
            : 'Pengeluaran';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddRecordScreen(recordToEdit: item),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.categoryIcon, size: 22, color: amountColor),
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
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.bgScreen,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '· $typeLabel',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (isDebt && item.isPaid) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.badgePaidBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Lunas',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.badgePaidText,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (item.note != null && item.note!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.note!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
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
                        '$sign${state.formatCurrency(item.amount)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: amountColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak Ada Transaksi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tidak ada transaksi yang cocok dengan kata kunci "$_searchQuery".'
                  : 'Belum ada transaksi pada kategori yang dipilih.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
