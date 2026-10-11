import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';
import '../state/finance_state.dart';
import '../widgets/responsive_layout.dart';
import 'add_record_screen.dart';
import 'all_transactions_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;
  const HomeScreen({super.key, this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _balanceVisible = true;


  void _openAddRecord(RecordType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddRecordScreen(initialType: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = FinanceProvider.of(context);
    final media = MediaQuery.of(context);
    final topPadding = media.padding.top;

    // Tinggi minimum konten body supaya header selalu bisa collapse penuh,
    // walaupun jumlah transaksi sedikit.
    const bodyVerticalPadding = 20.0 + 100.0;
    final minBodyHeight = (media.size.height -
            (topPadding + _HomeHeaderDelegate.collapsedContentHeight) -
            bodyVerticalPadding)
        .clamp(0.0, double.infinity);

    return Material(
      color: AppColors.bgScreen,
      child: CustomScrollView(
        slivers: [
          // ── Header biru (collapsible) ─────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _HomeHeaderDelegate(
              topPadding: topPadding,
              balanceText: state.formatCurrency(state.totalBalance),
              balanceVisible: _balanceVisible,
              onToggleBalance: () =>
                  setState(() => _balanceVisible = !_balanceVisible),
              onExpense: () => _openAddRecord(RecordType.expense),
              onIncome: () => _openAddRecord(RecordType.income),
              onDebt: () => widget.onNavigateTab?.call(2),
            ),
          ),

          // ── Body ──────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverToBoxAdapter(
              child: ResponsiveLayout(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minBodyHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Metric Cards
                      _MetricsRow(
                        state: state,
                        onDebtTap: () => widget.onNavigateTab?.call(2),
                        onExpenseTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AllTransactionsScreen(
                                initialFilter: RecordType.expense,
                              ),
                            ),
                          );
                        },
                        onIncomeTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AllTransactionsScreen(
                                initialFilter: RecordType.income,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Transaksi Terbaru
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Transaksi Terbaru',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AllTransactionsScreen(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Lihat Semua >',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Transaction list
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: state.records.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 36, horizontal: 20),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: AppColors.primarySurface,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.receipt_long_outlined,
                                          size: 26,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Belum Ada Transaksi',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Mulai catat pengeluaran, pemasukan, atau utang pertamamu dengan tombol + di bawah.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                itemCount: state.records.length > 5
                                    ? 5
                                    : state.records.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  indent: 72,
                                  endIndent: 16,
                                  color: Colors.grey.shade100,
                                ),
                                itemBuilder: (context, index) {
                                  return _TransactionTile(
                                    item: state.records[index],
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header biru beranda yang menyusut saat di-scroll.
/// - Sapaan dan tombol aksi cepat (Pengeluaran, Pemasukan, Utang/Piutang)
///   memudar lalu hilang.
/// - Kartu Total Uang Bersih ikut menyusut, tapi tetap terlihat.
class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  static const double expandedContentHeight = 306;
  static const double collapsedContentHeight = 72;

  final double topPadding;
  final String balanceText;
  final bool balanceVisible;
  final VoidCallback onToggleBalance;
  final VoidCallback onExpense;
  final VoidCallback onIncome;
  final VoidCallback onDebt;

  _HomeHeaderDelegate({
    required this.topPadding,
    required this.balanceText,
    required this.balanceVisible,
    required this.onToggleBalance,
    required this.onExpense,
    required this.onIncome,
    required this.onDebt,
  });

  @override
  double get maxExtent => topPadding + expandedContentHeight;

  @override
  double get minExtent => topPadding + collapsedContentHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final range = maxExtent - minExtent;
    final t = range <= 0 ? 1.0 : (shrinkOffset / range).clamp(0.0, 1.0);
    // Elemen yang hilang memudar lebih cepat dari proses menyusut.
    final fade = (1 - t * 1.6).clamp(0.0, 1.0);
    double lerp(double a, double b) => a + (b - a) * t;

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.0,
      child: DecoratedBox(
        decoration: blueGradientHeader(),
        child: ClipRect(
          child: Stack(
            children: [
              Positioned(
                left: 20,
                right: 20,
                top: topPadding + lerp(16, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting (hilang saat collapse)
                    _Collapsible(
                      factor: 1 - t,
                      opacity: fade,
                      child: const _Greeting(),
                    ),
                    SizedBox(height: lerp(24, 0)),

                    // Balance card (menyusut, tetap tampil)
                    _CollapsibleBalanceCard(
                      t: t,
                      fade: fade,
                      balanceText: balanceText,
                      balanceVisible: balanceVisible,
                      onToggleBalance: onToggleBalance,
                    ),
                    SizedBox(height: lerp(16, 0)),

                    // Quick action buttons (hilang saat collapse)
                    _Collapsible(
                      factor: 1 - t,
                      opacity: fade,
                      child: Row(
                        children: [
                          Expanded(
                            child: _QuickActionChip(
                              icon: Icons.remove_circle_outline_rounded,
                              label: 'Pengeluaran',
                              onTap: onExpense,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _QuickActionChip(
                              icon: Icons.add_circle_outline_rounded,
                              label: 'Pemasukan',
                              onTap: onIncome,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _QuickActionChip(
                              icon: Icons.account_balance_wallet_outlined,
                              label: 'Utang/Piutang',
                              onTap: onDebt,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HomeHeaderDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding ||
        oldDelegate.balanceText != balanceText ||
        oldDelegate.balanceVisible != balanceVisible ||
        oldDelegate.onToggleBalance != onToggleBalance ||
        oldDelegate.onExpense != onExpense ||
        oldDelegate.onIncome != onIncome ||
        oldDelegate.onDebt != onDebt;
  }
}

/// Menyusutkan tinggi child secara vertikal (factor 1 = penuh, 0 = hilang)
/// sambil memudarkannya. Tidak bisa di-tap saat hampir hilang.
class _Collapsible extends StatelessWidget {
  final double factor;
  final double opacity;
  final Widget child;

  const _Collapsible({
    required this.factor,
    required this.opacity,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: opacity < 0.3,
      child: ClipRect(
        child: Align(
          alignment: Alignment.topLeft,
          heightFactor: factor.clamp(0.0, 1.0),
          child: Opacity(opacity: opacity, child: child),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Halo, Wahan',
          style: TextStyle(
            fontSize: 20,
            height: 1.2,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Semoga hari ini penuh dengan hal baik!',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            height: 1.3,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _CollapsibleBalanceCard extends StatelessWidget {
  final double t;
  final double fade;
  final String balanceText;
  final bool balanceVisible;
  final VoidCallback onToggleBalance;

  const _CollapsibleBalanceCard({
    required this.t,
    required this.fade,
    required this.balanceText,
    required this.balanceVisible,
    required this.onToggleBalance,
  });

  double _lerp(double a, double b) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: _lerp(20, 0),
        vertical: _lerp(20, 6),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15 * (1 - t)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2 * (1 - t)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Total Uang Bersih',
                style: TextStyle(
                  fontSize: _lerp(13, 12),
                  height: 1.3,
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onToggleBalance,
                behavior: HitTestBehavior.opaque,
                child: Icon(
                  balanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          SizedBox(height: _lerp(6, 2)),
          balanceVisible
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    balanceText,
                    style: TextStyle(
                      fontSize: _lerp(32, 20),
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                )
              : Text(
                  '••••••••',
                  style: TextStyle(
                    fontSize: _lerp(28, 18),
                    height: 1.2,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
          _Collapsible(
            factor: 1 - t,
            opacity: fade,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF69FF47),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Terupdate real-time',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  final FinanceState state;
  final VoidCallback? onDebtTap;
  final VoidCallback? onExpenseTap;
  final VoidCallback? onIncomeTap;

  const _MetricsRow({
    required this.state,
    this.onDebtTap,
    this.onExpenseTap,
    this.onIncomeTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _MetricCard(
              title: 'Pengeluaran',
              amount: state.formatCurrency(state.totalExpense),
              icon: Icons.arrow_upward_rounded,
              iconColor: AppColors.negative,
              iconBg: const Color(0xFFFFEBEE),
              onTap: onExpenseTap,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MetricCard(
              title: 'Pemasukan',
              amount: state.formatCurrency(state.totalIncome),
              icon: Icons.arrow_downward_rounded,
              iconColor: AppColors.positive,
              iconBg: const Color(0xFFE8F5E9),
              onTap: onIncomeTap,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _DebtMetricCard(
              payableAmount: state.formatCurrency(state.totalDebtPayable),
              receivableAmount: state.formatCurrency(state.totalDebtReceivable),
              onTap: onDebtTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
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
      ),
    );
  }
}

class _DebtMetricCard extends StatelessWidget {
  final String payableAmount;
  final String receivableAmount;
  final VoidCallback? onTap;

  const _DebtMetricCard({
    required this.payableAmount,
    required this.receivableAmount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 15,
                    color: AppColors.warning,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Utang Saya',
              style: TextStyle(
                fontSize: 9,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                payableAmount,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.negative,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Piutang Orang',
              style: TextStyle(
                fontSize: 9,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                receivableAmount,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.positive,
                ),
              ),
            ),
          ],
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

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final dateStr =
        '${item.date.day} ${months[item.date.month - 1]} ${item.date.year}';
    final typeLabel = isIncome
        ? 'Pemasukan'
        : isDebt
            ? (item.debtType == DebtType.payable ? 'Utang' : 'Piutang')
            : 'Pengeluaran';

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AddRecordScreen(recordToEdit: item),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    item.title,
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
                    '$dateStr · $typeLabel',
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
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '$sign${state.formatCurrency(item.amount)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
