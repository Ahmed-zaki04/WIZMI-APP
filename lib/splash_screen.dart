import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:wizmi/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<Splash> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 2800), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      Navigator.pushReplacementNamed(context, 'home');
    } else {
      Navigator.pushReplacementNamed(context, 'log');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryDark, AppTheme.primary, Color(0xFF1565C0)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                SizedBox(
                  height: 200,
                  child: Lottie.asset(
                    'assets/animations/car_loading.json',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.directions_car, size: 100, color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'WIZMI',
                  style: GoogleFonts.poppins(
                    fontSize: 42, fontWeight: FontWeight.w900,
                    color: Colors.white, letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Car Service Partner',
                  style: GoogleFonts.poppins(
                    fontSize: 15, color: Colors.white70, letterSpacing: 1,
                  ),
                ),
                const Spacer(flex: 3),
                const CircularProgressIndicator(
                  color: Colors.white38, strokeWidth: 2,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
