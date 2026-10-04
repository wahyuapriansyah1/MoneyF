import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../state/finance_state.dart';
import '../widgets/responsive_layout.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = FinanceProvider.of(context);
    final totalIn = state.totalIncome;
    final totalOut = state.totalExpense;
    final maxVal = (totalIn + totalOut) == 0 ? 1.0 : (totalIn + totalOut);

    final inRatio = (totalIn / maxVal).clamp(0.0, 1.0);
    final outRatio = (totalOut / maxVal).clamp(0.0, 1.0);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: screenBackground(),
        child: SafeArea(
          bottom: false,
          child: ResponsiveLayout(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              children: [
                const Text(
                  'Analisis',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const Text(
                  'Arus Kas Keuangan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // Cashflow Card
                Container(
                  padding: const EdgeInsets.all(20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Rasio Pemasukan & Pengeluaran',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Income bar
                      _ProgressBarItem(
                        label: 'Pemasukan',
                        amount: state.formatCurrency(totalIn),
                        ratio: inRatio,
                        color: AppColors.positive,
                      ),
                      const SizedBox(height: 14),

                      // Expense bar
                      _ProgressBarItem(
                        label: 'Pengeluaran',
                        amount: state.formatCurrency(totalOut),
                        ratio: outRatio,
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Rincian Pengeluaran per Kategori',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Expense breakdown list
                ..._buildExpenseBreakdown(state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpenseBreakdown(FinanceState state) {
    final expenseRecords = state.records.where((r) => r.type == RecordType.expense).toList();
    if (expenseRecords.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'Belum ada data pengeluaran',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
      ];
    }

    final Map<String, double> categorySums = {};
    for (var r in expenseRecords) {
      categorySums[r.category] = (categorySums[r.category] ?? 0.0) + r.amount;
    }

    final sortedEntries = categorySums.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalExp = state.totalExpense > 0 ? state.totalExpense : 1.0;

    return sortedEntries.map((e) {
      final percentage = (e.value / totalExp * 100).toStringAsFixed(1);
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.inputFill,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pie_chart_rounded, size: 18, color: AppColors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.key,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '$percentage% dari total pengeluaran',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              state.formatCurrency(e.value),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

class _ProgressBarItem extends StatelessWidget {
  final String label;
  final String amount;
  final double ratio;
  final Color color;

  const _ProgressBarItem({
    required this.label,
    required this.amount,
    required this.ratio,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            backgroundColor: AppColors.inputFill,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
