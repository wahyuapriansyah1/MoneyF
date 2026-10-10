import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme.dart';
import '../models.dart';
import '../state/finance_state.dart';
import '../widgets/responsive_layout.dart';
import 'all_transactions_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _tabIndex = 0; // 0: Pengeluaran, 1: Pemasukan
  int _selectedYear = DateTime.now().year;
  int? _selectedMonth = DateTime.now().month; // null = Semua Bulan (Tahunan)

  static const List<String> _monthNames = [
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

  static const List<String> _shortMonthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des'
  ];

  String get _filterLabel {
    if (_selectedMonth == null) {
      return 'Tahun $_selectedYear >';
    }
    return '${_monthNames[_selectedMonth! - 1]} $_selectedYear >';
  }

  String get _periodSubtitle {
    if (_selectedMonth == null) {
      return 'Tahun $_selectedYear';
    }
    return '${_monthNames[_selectedMonth! - 1]} $_selectedYear';
  }

  static const List<Color> _pieColors = [
    Color(0xFF1565C0),
    Color(0xFF42A5F5),
    Color(0xFF0D47A1),
    Color(0xFF90CAF9),
    Color(0xFF1E88E5),
    Color(0xFF64B5F6),
    Color(0xFF1976D2),
  ];

  void _openPeriodFilterSheet(BuildContext context) {
    int tempYear = _selectedYear;
    int? tempMonth = _selectedMonth;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pilih Periode Analisa',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempYear = DateTime.now().year;
                              tempMonth = DateTime.now().month;
                            });
                          },
                          child: const Text(
                            'Bulan Ini',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Selector Tahun
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bgScreen,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_left_rounded,
                              color: AppColors.textPrimary,
                            ),
                            onPressed: () {
                              setModalState(() => tempYear--);
                            },
                          ),
                          Text(
                            '$tempYear',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textPrimary,
                            ),
                            onPressed: () {
                              setModalState(() => tempYear++);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Opsi Filter Tahunan (Semua Bulan)
                    GestureDetector(
                      onTap: () {
                        setModalState(() => tempMonth = null);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: tempMonth == null
                              ? AppColors.primarySurface
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: tempMonth == null
                                ? AppColors.primary
                                : Colors.grey.shade300,
                            width: tempMonth == null ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              tempMonth == null
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              size: 20,
                              color: tempMonth == null
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Sepanjang Tahun $tempYear (Tahunan)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: tempMonth == null
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: tempMonth == null
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Opsi Filter Bulanan (12 Bulan)
                    const Text(
                      'Pilih Bulan Spesifik:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 2.2,
                      ),
                      itemCount: 12,
                      itemBuilder: (ctx, idx) {
                        final monthNum = idx + 1;
                        final isSelected = tempMonth == monthNum;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() => tempMonth = monthNum);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.bgScreen,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _shortMonthNames[idx],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Tombol Terapkan
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedYear = tempYear;
                          _selectedMonth = tempMonth;
                        });
                        Navigator.of(ctx).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Terapkan Filter',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = FinanceProvider.of(context);

    // Filter transaksi berdasarkan tab (pemasukan/pengeluaran), tahun, dan bulan
    final records = state.records.where((r) {
      if (r.type !=
          (_tabIndex == 0 ? RecordType.expense : RecordType.income)) {
        return false;
      }
      if (r.date.year != _selectedYear) {
        return false;
      }
      if (_selectedMonth != null && r.date.month != _selectedMonth) {
        return false;
      }
      return true;
    }).toList();

    final total = records.fold<double>(0, (s, r) => s + r.amount);

    final Map<String, double> categorySums = {};
    for (var r in records) {
      categorySums[r.category] = (categorySums[r.category] ?? 0.0) + r.amount;
    }
    final sortedEntries = categorySums.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Perhitungan pembanding periode sebelumnya
    double prevTotal = 0.0;
    if (_selectedMonth != null) {
      final prevYear =
          _selectedMonth == 1 ? _selectedYear - 1 : _selectedYear;
      final prevMonth = _selectedMonth == 1 ? 12 : _selectedMonth! - 1;
      prevTotal = state.records
          .where((r) =>
              r.type ==
                  (_tabIndex == 0 ? RecordType.expense : RecordType.income) &&
              r.date.year == prevYear &&
              r.date.month == prevMonth)
          .fold<double>(0.0, (s, r) => s + r.amount);
    } else {
      prevTotal = state.records
          .where((r) =>
              r.type ==
                  (_tabIndex == 0 ? RecordType.expense : RecordType.income) &&
              r.date.year == _selectedYear - 1)
          .fold<double>(0.0, (s, r) => s + r.amount);
    }
    final hasPrev = prevTotal > 0;
    final diff = total - prevTotal;
    final pctDiff =
        hasPrev ? (diff.abs() / prevTotal * 100).toStringAsFixed(0) : '0';
    final isIncrease = diff > 0;

    return Material(
      color: Colors.transparent,
      child: Container(
        color: AppColors.bgScreen,
        child: SafeArea(
          bottom: false,
          child: ResponsiveLayout(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                // Title & Filter Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Analisa',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openPeriodFilterSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _filterLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tab selector
                Container(
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
                      _TabBtn(
                        label: 'Pengeluaran',
                        selected: _tabIndex == 0,
                        onTap: () => setState(() => _tabIndex = 0),
                      ),
                      _TabBtn(
                        label: 'Pemasukan',
                        selected: _tabIndex == 1,
                        onTap: () => setState(() => _tabIndex = 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Summary card + Pie
                Container(
                  padding: const EdgeInsets.all(20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Total ${_tabIndex == 0 ? 'Pengeluaran' : 'Pemasukan'} ($_periodSubtitle)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.formatCurrency(total),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (hasPrev)
                        Text(
                          isIncrease
                              ? '↑ $pctDiff% dari periode sebelumnya'
                              : '↓ $pctDiff% dari periode sebelumnya',
                          style: TextStyle(
                            fontSize: 11,
                            color: (_tabIndex == 0 ? !isIncrease : isIncrease)
                                ? Colors.green.shade600
                                : Colors.red.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        Text(
                          'Periode: $_periodSubtitle',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Pie chart
                      if (sortedEntries.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: CustomPaint(
                                painter: _PieChartPainter(
                                  sections: sortedEntries
                                      .asMap()
                                      .entries
                                      .map((e) => _PieSection(
                                            value: e.value.value / total,
                                            color: _pieColors[
                                                e.key % _pieColors.length],
                                          ))
                                      .toList(),
                                  centerLabel: state.formatCurrency(total),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: sortedEntries
                                    .asMap()
                                    .entries
                                    .take(5)
                                    .map((e) {
                                  final pct = total > 0
                                      ? (e.value.value / total * 100)
                                          .toStringAsFixed(0)
                                      : '0';
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: _pieColors[
                                                e.key % _pieColors.length],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            e.value.key,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '$pct%',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        )
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'Belum ada data ${_tabIndex == 0 ? 'pengeluaran' : 'pemasukan'}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Rincian per kategori
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Rincian per Kategori',
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
                            builder: (_) => AllTransactionsScreen(
                              initialFilter: _tabIndex == 0
                                  ? RecordType.expense
                                  : RecordType.income,
                            ),
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

                if (sortedEntries.isEmpty)
                  const Text(
                    'Belum ada data',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  ...sortedEntries.asMap().entries.map((e) {
                    final pct = total > 0
                        ? (e.value.value / total * 100).toStringAsFixed(0)
                        : '0';
                    final color = _pieColors[e.key % _pieColors.length];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.pie_chart_rounded,
                                size: 18, color: color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.value.key,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: total > 0
                                        ? e.value.value / total
                                        : 0,
                                    minHeight: 4,
                                    backgroundColor:
                                        color.withValues(alpha: 0.1),
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(color),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                state.formatCurrency(e.value.value),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '$pct%',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.selected, required this.onTap});

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

class _PieSection {
  final double value;
  final Color color;
  const _PieSection({required this.value, required this.color});
}

class _PieChartPainter extends CustomPainter {
  final List<_PieSection> sections;
  final String centerLabel;

  _PieChartPainter({required this.sections, required this.centerLabel});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    double startAngle = -math.pi / 2;

    for (final section in sections) {
      final sweepAngle = section.value * 2 * math.pi;
      final paint = Paint()
        ..color = section.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 11),
        startAngle,
        sweepAngle - 0.04,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Center text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Total\n',
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(
            text: centerLabel,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: radius * 1.2);
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
