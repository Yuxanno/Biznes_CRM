import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/order_provider.dart';
import 'providers/debt_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/period_provider.dart';
import 'providers/notification_provider.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'utils/l10n.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_shell.dart';
import 'screens/orders/order_detail_screen.dart';
import 'screens/customers/customer_detail_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const BusinessManagerApp());
}

class BusinessManagerApp extends StatelessWidget {
  const BusinessManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LangProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => DebtProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => PeriodProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProv, _) {
          return MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: _resolveMaterialThemeMode(themeProv.mode),
            initialRoute: '/',
            onGenerateRoute: _generateRoute,
          );
        },
      ),
    );
  }

  static ThemeMode _resolveMaterialThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return ThemeMode.light;
      case ThemeMode.dark:
        return ThemeMode.dark;
      case ThemeMode.system:
        return ThemeMode.system;
    }
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _fade(const _SplashGate());
      case '/login':
        return _fade(const LoginScreen());
      case '/register':
        return _fade(const RegisterScreen());
      case '/dashboard':
        return _fade(MainShell(initialIndex: 0));
      case '/transactions':
        return _fade(MainShell(initialIndex: 1));
      case '/orders':
        return _fade(MainShell(initialIndex: 2));
      case '/profile':
        return _fade(MainShell(initialIndex: 3));
      default:
        if (settings.name?.startsWith('/orders/') == true) {
          final id = settings.name!.substring('/orders/'.length);
          return _slide(OrderDetailScreen(orderId: id));
        }
        if (settings.name?.startsWith('/customers/') == true) {
          final id = settings.name!.substring('/customers/'.length);
          return _slide(CustomerDetailScreen(customerId: id));
        }
        return _fade(const LoginScreen());
    }
  }

  static PageRoute _fade(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      );

  static PageRoute _slide(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutCubic))
              .animate(anim),
          child: child,
        ),
      );
}

// ─── Splash ───────────────────────────────────────────────────────────────────
class _SplashGate extends StatefulWidget {
  const _SplashGate();
  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _reduceMotion = WidgetsBinding.instance.disableAnimations;
    _ctrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: _reduceMotion ? 0 : 400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _checkAuth();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    await auth.tryAutoLogin();
    if (!mounted) return;
    if (auth.isAuthenticated) {
      context.read<PeriodProvider>().load();
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Scaffold(
      backgroundColor: c.background,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: c.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child:
                    Icon(Icons.business_center_rounded, color: c.onPrimary, size: 36),
              ),
              const SizedBox(height: 20),
              Text('Business Manager',
                  style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(context.read<LangProvider>().t.loading,
                  style: TextStyle(color: c.textMuted, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
