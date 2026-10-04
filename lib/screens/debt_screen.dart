import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../state/finance_state.dart';
import '../widgets/responsive_layout.dart';
import 'add_record_screen.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  int _filterIndex = 0; // 0: Semua, 1: Utang Saya, 2: Piutang Orang

  @override
  Widget build(BuildContext context) {
    final state = FinanceProvider.of(context);
    final debtRecords = state.records.where((r) => r.type == RecordType.debt).toList();

    final filteredRecords = debtRecords.where((r) {
      if (_filterIndex == 1) return r.debtType == DebtType.payable;
      if (_filterIndex == 2) return r.debtType == DebtType.receivable;
      return true;
    }).toList();

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: screenBackground(),
        child: SafeArea(
          bottom: false,
          child: ResponsiveLayout(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pencatatan',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          Text(
                            'Utang & Piutang',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AddRecordScreen(initialType: RecordType.debt),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Tambah Utang', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Debt & Receivable Summary Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Utang Saya',
                          subtitle: 'Harus Dibayar',
                          amount: state.formatCurrency(state.totalDebtPayable),
                          cardColor: AppColors.peachStart,
                          accentColor: Colors.deepOrange,
                          icon: Icons.upload_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Piutang Saya',
                          subtitle: 'Harus Ditagih',
                          amount: state.formatCurrency(state.totalDebtReceivable),
                          cardColor: AppColors.chipBlue,
                          accentColor: Colors.blueAccent,
                          icon: Icons.download_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Filter Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _FilterTab(
                        label: 'Semua',
                        isSelected: _filterIndex == 0,
                        onTap: () => setState(() => _filterIndex = 0),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'Utang Saya',
                        isSelected: _filterIndex == 1,
                        onTap: () => setState(() => _filterIndex = 1),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'Piutang Orang',
                        isSelected: _filterIndex == 2,
                        onTap: () => setState(() => _filterIndex = 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // List of Debt Records
                Expanded(
                  child: filteredRecords.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.handshake_outlined,
                                size: 56,
                                color: AppColors.textSecondary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Belum ada pencatatan utang',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                          itemCount: filteredRecords.length,
                          itemBuilder: (context, index) {
                            final item = filteredRecords[index];
                            return _DebtTile(item: item);
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final Color cardColor;
  final Color accentColor;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.cardColor,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.black : Colors.white,
          borderRadius: BorderRadius.circular(18),
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

class _DebtTile extends StatelessWidget {
  final FinancialRecord item;
  const _DebtTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final state = FinanceProvider.of(context);
    final isPayable = item.debtType == DebtType.payable;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isPayable ? AppColors.peachStart : AppColors.chipBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.categoryIcon,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (item.personName != null && item.personName!.isNotEmpty)
                      Text(
                        isPayable
                            ? 'Ke: ${item.personName}'
                            : 'Dari: ${item.personName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    Text(
                      '${item.date.day}/${item.date.month}/${item.date.year}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    state.formatCurrency(item.amount),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isPayable ? Colors.deepOrange : Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.isPaid
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.isPaid ? 'LUNAS' : 'BELUM LUNAS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: item.isPaid ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (item.note != null && item.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.inputFill.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Catatan: ${item.note}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  state.toggleDebtPaid(item.id);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(
                  item.isPaid ? Icons.undo_rounded : Icons.check_circle_rounded,
                  size: 16,
                  color: item.isPaid ? Colors.orange : Colors.green[700],
                ),
                label: Text(
                  item.isPaid ? 'Batal Lunas' : 'Tandai Lunas',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: item.isPaid ? Colors.orange : Colors.green[700],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddRecordScreen(recordToEdit: item),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 6),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
                onPressed: () {
                  state.deleteRecord(item.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Utang "${item.title}" dihapus')),
                  );
                },
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
