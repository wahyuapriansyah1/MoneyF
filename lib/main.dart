import 'package:flutter/material.dart';
import 'theme.dart';
import 'state/finance_state.dart';
import 'services/auth_service.dart';
import 'widgets/bottom_nav.dart';
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
        home: widget.home ?? const AuthGate(),
      ),
    );
  }
}

/// Gerbang Otentikasi: mengecek token di SharedPreferences.
/// Jika token ada -> ke MainTabScreen.
/// Jika belum login -> ke LoginScreen.
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
          decoration: screenBackground(),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.black,
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
      // Center FAB (+) tapped: Open Add Record Screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const AddRecordScreen(),
        ),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateTab: _onTabTapped),
      const AnalyticsScreen(),
      const DebtScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1.0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: MoneyBottomNav(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
