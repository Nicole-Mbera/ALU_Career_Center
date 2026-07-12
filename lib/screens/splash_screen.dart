import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    if (auth.status == AuthStatus.authenticated) {
      _routeByRole(auth);
    } else if (auth.status == AuthStatus.unauthenticated) {
      Navigator.pushReplacementNamed(context, '/login');
    }
    // If still unknown, authStateChanges listener will handle it
  }

  void _routeByRole(AuthProvider auth) {
    if (auth.isAdmin) {
      Navigator.pushReplacementNamed(context, '/admin');
    } else if (auth.isFounder) {
      Navigator.pushReplacementNamed(context, '/startup-dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.status != AuthStatus.unknown) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (auth.status == AuthStatus.authenticated) {
              _routeByRole(auth);
            } else {
              Navigator.pushReplacementNamed(context, '/login');
            }
          });
        }

        return Scaffold(
          backgroundColor: AppColors.primary,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.rocket_launch,
                      size: 50, color: AppColors.primary),
                ),
                const SizedBox(height: 24),
                Text(
                  'ALU Ventures',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connecting students with startups',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.onPrimary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.secondary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
