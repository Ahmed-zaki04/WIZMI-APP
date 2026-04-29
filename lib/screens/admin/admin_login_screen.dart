import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/wizmi_dialog.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  // Simple hardcoded admin PIN — replace with Firebase-based auth in production
  static const _adminPin = 'wizmi2024';

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _loading = false);
      if (_passCtrl.text == _adminPin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else {
        WizmiDialog.show(
          context,
          title: 'Access Denied',
          message: 'Incorrect admin PIN.',
          type: WizmiDialogType.error,
        );
      }
    });
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.amber.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.admin_panel_settings,
                        color: AppColors.amber, size: 36),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Admin Access',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter the admin PIN to continue',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  style: const TextStyle(color: AppColors.textPrimary, letterSpacing: 3),
                  decoration: InputDecoration(
                    hintText: 'Admin PIN',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'PIN is required' : null,
                ),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Enter Dashboard',
                  icon: Icons.dashboard_outlined,
                  onPressed: _login,
                  loading: _loading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
