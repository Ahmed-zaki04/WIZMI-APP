import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wizmi/theme.dart';
import 'signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> {
  final TextEditingController email = TextEditingController();
  final TextEditingController pass  = TextEditingController();
  final GlobalKey<FormState> form   = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!form.currentState!.validate()) return;
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: email.text.trim(), password: pass.text);
      if (credential.user!.emailVerified) {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('home', (r) => false);
        }
      } else {
        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.warning,
            animType: AnimType.rightSlide,
            title: 'Error',
            desc: 'Verify your email first!',
          ).show();
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = e.code == 'user-not-found'
          ? 'User not found!'
          : e.code == 'wrong-password'
              ? 'Wrong password.'
              : 'Login failed. Please try again.';
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error',
        desc: msg,
      ).show();
    }
  }

  void _forgotPassword() {
    if (email.text.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error',
        desc: 'Please enter your email first before pressing forgot password!',
      ).show();
      return;
    }
    try {
      FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim());
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Success',
        desc: 'Password reset email sent!',
      ).show();
    } catch (_) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error',
        desc: 'Check spelling or user not found!',
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── WIZMI logo header ──────────────────────────────────────
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryDark,
                    AppTheme.primary,
                    AppTheme.primaryLight,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_car_rounded,
                      color: Colors.white, size: 52),
                  const SizedBox(height: 10),
                  Text(
                    'WIZMI',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),

            // ── Form ──────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: Form(
                key: form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Welcome back!',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to continue',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Email
                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? "Email can't be empty" : null,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: pass,
                      obscureText: _obscure,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? "Password can't be empty" : null,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),

                    // Forgot password inline
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _forgotPassword,
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Login button
                    ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 20),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignUp()),
                          ),
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),

                    // Admin login
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, 'admin_login'),
                      child: Text(
                        'Admin Login',
                        style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
