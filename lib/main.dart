import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'providers/auth_provider.dart';
import 'providers/opportunity_provider.dart';
import 'providers/application_provider.dart';
import 'providers/startup_provider.dart';
import 'providers/admin_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/startup_onboarding_screen.dart';
import 'screens/student/student_shell.dart';
import 'screens/student/explore_screen.dart';
import 'screens/startup/startup_dashboard_screen.dart';
import 'screens/admin/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ALUVenturesApp());
}

class ALUVenturesApp extends StatelessWidget {
  const ALUVenturesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OpportunityProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationProvider()),
        ChangeNotifierProvider(create: (_) => StartupProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'ALU Career Center',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/startup-onboarding': (_) => const StartupOnboardingScreen(),
          '/home': (_) => const _StudentShellWrapper(),
          '/explore': (_) => const ExploreScreen(),
          '/startup-dashboard': (_) => const _StartupDashboardWrapper(),
          '/admin': (_) => const _AdminWrapper(),
        },
      ),
    );
  }
}

// Wrappers initialize providers once on mount, safely inside widget tree.

class _StudentShellWrapper extends StatefulWidget {
  const _StudentShellWrapper();

  @override
  State<_StudentShellWrapper> createState() => _StudentShellWrapperState();
}

class _StudentShellWrapperState extends State<_StudentShellWrapper> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final user = context.read<AuthProvider>().user;
      if (user != null && user.isStudent) {
        context.read<OpportunityProvider>().init(user.skills);
        context.read<ApplicationProvider>().init(user.uid);
      }
    }
  }

  @override
  Widget build(BuildContext context) => const StudentShell();
}

class _StartupDashboardWrapper extends StatefulWidget {
  const _StartupDashboardWrapper();

  @override
  State<_StartupDashboardWrapper> createState() =>
      _StartupDashboardWrapperState();
}

class _StartupDashboardWrapperState extends State<_StartupDashboardWrapper> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<StartupProvider>().init(user.uid);
      }
    }
  }

  @override
  Widget build(BuildContext context) => const StartupDashboardScreen();
}

class _AdminWrapper extends StatefulWidget {
  const _AdminWrapper();

  @override
  State<_AdminWrapper> createState() => _AdminWrapperState();
}

class _AdminWrapperState extends State<_AdminWrapper> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      context.read<AdminProvider>().init();
    }
  }

  @override
  Widget build(BuildContext context) => const AdminScreen();
}
