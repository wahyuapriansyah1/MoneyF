import 'package:flutter/material.dart';
import 'theme.dart';
import 'state/finance_state.dart';
import 'services/auth_service.dart';
import 'widgets/bottom_nav.dart';
import 'models.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/debt_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/add_record_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MoneyFApp());
}

class MoneyFApp extends StatefulWidget {
  final Widget? home;

  const MoneyFApp({
    super.key,
    this.home,
  });

  @override
  State<MoneyFApp> createState() => _MoneyFAppState();
}

class _MoneyFAppState extends State<MoneyFApp> {
  final FinanceState _financeState = FinanceState();

  @override
  Widget build(BuildContext context) {
    return FinanceProvider(
      financeState: _financeState,
      child: MaterialApp(
        title: 'MoneyF',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: widget.home ?? const SplashGate(),
      ),
    );
  }
}

/// Splash screen biru dengan animasi logo
class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    final authService = AuthService();
    final loggedIn = await authService.isLoggedIn();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            loggedIn ? const MainTabScreen() : const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: blueGradientHeader(),
        child: Stack(
          children: [
            // Wave decoration bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                painter: _WavePainter(),
                size: Size(MediaQuery.of(context).size.width, 200),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Official Logo
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Moneyf',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Catat, Kelola, Wujudkan\nRencana Keuanganmu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
        size.width * 0.25, size.height * 0.3, size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.7, size.width, size.height * 0.5);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);

    final paint2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    final path2 = Path();
    path2.moveTo(0, size.height * 0.65);
    path2.quadraticBezierTo(
        size.width * 0.3, size.height * 0.45, size.width * 0.6, size.height * 0.65);
    path2.quadraticBezierTo(
        size.width * 0.8, size.height * 0.78, size.width, size.height * 0.6);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Gerbang Otentikasi
class AuthGate extends StatefulWidget {
  final AuthService? authService;

  const AuthGate({
    super.key,
    this.authService,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthService _authService;
  bool _isChecking = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final loggedIn = await _authService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        body: Container(
          decoration: blueGradientHeader(),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          ),
        ),
      );
    }

    if (_isLoggedIn) {
      return const MainTabScreen();
    }

    return LoginScreen(authService: _authService);
  }
}

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index == 4) {
      _showAddTransactionSheet();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showAddTransactionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddTransactionSheet(
        onSelected: (type) {
          Navigator.of(ctx).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddRecordScreen(initialType: type),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateTab: _onTabTapped),
      const AnalyticsScreen(),
      DebtScreen(
        onBack: () => _onTabTapped(0),
        onNavigateTab: _onTabTapped,
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: MoneyBottomNav(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet tambah transaksi (pilih jenis)
class _AddTransactionSheet extends StatelessWidget {
  final ValueChanged<RecordType> onSelected;
  const _AddTransactionSheet({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Tambah Transaksi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _SheetItem(
            icon: Icons.remove_circle_outline_rounded,
            color: AppColors.negative,
            bgColor: const Color(0xFFFFEBEE),
            title: 'Pengeluaran',
            subtitle: 'Catat pengeluaran harianmu',
            onTap: () => onSelected(RecordType.expense),
          ),
          const SizedBox(height: 12),
          _SheetItem(
            icon: Icons.add_circle_outline_rounded,
            color: AppColors.positive,
            bgColor: const Color(0xFFE8F5E9),
            title: 'Pemasukan',
            subtitle: 'Catat pemasukanmu',
            onTap: () => onSelected(RecordType.income),
          ),
          const SizedBox(height: 12),
          _SheetItem(
            icon: Icons.handshake_rounded,
            color: AppColors.warning,
            bgColor: const Color(0xFFFFF3E0),
            title: 'Utang / Piutang',
            subtitle: 'Catat utang atau pinjaman',
            onTap: () => onSelected(RecordType.debt),
          ),
        ],
      ),
    );
  }
}

class _SheetItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetItem({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
