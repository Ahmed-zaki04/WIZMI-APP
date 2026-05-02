import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wizmi/theme.dart';

// ── Shared text field ────────────────────────────────────────────────────────
class WizmiTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final String? hint;
  final int maxLines;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;

  const WizmiTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.hint,
    this.maxLines = 1,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      validator: validator ?? (v) => (v == null || v.isEmpty) ? 'Please enter $label' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primary),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// ── Hero header gradient banner ───────────────────────────────────────────────
class WizmiHeroHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;

  const WizmiHeroHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryDark, AppTheme.primary, AppTheme.primaryLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
          ],
          Text(title,
              style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.85), fontSize: 14)),
        ],
      ),
    );
  }
}

// ── Price / cost summary card ─────────────────────────────────────────────────
class WizmiPriceCard extends StatelessWidget {
  final List<PriceRow> rows;
  final String totalLabel;
  final int totalAmount;

  const WizmiPriceCard({
    super.key,
    required this.rows,
    this.totalLabel = 'Total',
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cost Summary',
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 10),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(r.label, style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary)),
                  Text('EGP ${r.amount}',
                      style: GoogleFonts.poppins(
                          fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                ],
              ),
            ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(totalLabel,
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              Text('EGP $totalAmount',
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primary)),
            ],
          ),
        ],
      ),
    );
  }
}

class PriceRow {
  final String label;
  final int amount;
  const PriceRow(this.label, this.amount);
}

// ── Submit button with built-in loading state ─────────────────────────────────
class WizmiSubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const WizmiSubmitButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────
class WizmiSectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const WizmiSectionTitle({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!,
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary)),
          ),
      ],
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = _resolve(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: GoogleFonts.poppins(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  (Color, String) _resolve(String s) {
    switch (s.toLowerCase()) {
      case 'pending':
        return (Colors.orange, 'Pending');
      case 'confirmed':
      case 'accepted':
      case 'processing':
        return (Colors.blue, 'Confirmed');
      case 'completed':
        return (AppTheme.success, 'Completed');
      case 'cancelled':
      case 'rejected':
        return (AppTheme.error, 'Cancelled');
      default:
        return (AppTheme.textSecondary, s);
    }
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class WizmiEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onButton;

  const WizmiEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onButton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: AppTheme.primary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
                style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary),
                textAlign: TextAlign.center),
            if (buttonLabel != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 180,
                child: ElevatedButton(
                  onPressed: onButton,
                  child: Text(buttonLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
