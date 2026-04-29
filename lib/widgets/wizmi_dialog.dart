import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum WizmiDialogType { success, error, warning, info }

class WizmiDialog {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    WizmiDialogType type = WizmiDialogType.info,
    VoidCallback? onOk,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _WizmiDialogWidget(
        title: title,
        message: message,
        type: type,
        onOk: onOk,
      ),
    );
  }
}

class _WizmiDialogWidget extends StatelessWidget {
  final String title;
  final String message;
  final WizmiDialogType type;
  final VoidCallback? onOk;

  const _WizmiDialogWidget({
    required this.title,
    required this.message,
    required this.type,
    this.onOk,
  });

  Color get _color {
    switch (type) {
      case WizmiDialogType.success: return AppColors.primary;
      case WizmiDialogType.error: return AppColors.error;
      case WizmiDialogType.warning: return AppColors.amber;
      case WizmiDialogType.info: return const Color(0xFF3498DB);
    }
  }

  IconData get _icon {
    switch (type) {
      case WizmiDialogType.success: return Icons.check_circle_outline;
      case WizmiDialogType.error: return Icons.error_outline;
      case WizmiDialogType.warning: return Icons.warning_amber_outlined;
      case WizmiDialogType.info: return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _color, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _color,
                  foregroundColor: type == WizmiDialogType.success
                      ? Colors.black
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  onOk?.call();
                },
                child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
