import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/fuel_type.dart';
import '../../providers/order_provider.dart';
import '../../widgets/fuel_type_card.dart';
import '../../widgets/gradient_button.dart';

class FuelSelectionScreen extends StatefulWidget {
  const FuelSelectionScreen({super.key});

  @override
  State<FuelSelectionScreen> createState() => _FuelSelectionScreenState();
}

class _FuelSelectionScreenState extends State<FuelSelectionScreen> {
  FuelType? _selected;
  int _quantity = 20;

  void _proceed() {
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a fuel type'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final provider = context.read<OrderProvider>();
    provider.selectFuel(_selected!);
    provider.setQuantity(_quantity);
    Navigator.pushNamed(context, '/order_summary');
  }

  @override
  Widget build(BuildContext context) {
    final total = _selected != null
        ? (_selected!.pricePerLiter * _quantity).toStringAsFixed(2)
        : '0.00';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Fuel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step indicator
                  StepBar(step: 1),
                  const SizedBox(height: 28),
                  const Text(
                    'Choose Fuel Type',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Select the fuel that matches your vehicle',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: FuelType.all
                        .map(
                          (f) => FuelTypeCard(
                            fuel: f,
                            selected: _selected?.id == f.id,
                            onTap: () => setState(() => _selected = f),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Quantity (Liters)',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Minimum 5L — Maximum 100L',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  _QuantitySelector(
                    value: _quantity,
                    onChanged: (v) => setState(() => _quantity = v),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Bottom total bar
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Estimated Total',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    Text(
                      '$total EGP',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GradientButton(
                  label: 'Continue',
                  icon: Icons.arrow_forward,
                  onPressed: _proceed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _QuantitySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _circleButton(
                icon: Icons.remove,
                onTap: () => onChanged((value - 5).clamp(5, 100)),
              ),
              const SizedBox(width: 24),
              Column(
                children: [
                  Text(
                    '$value',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Liters',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              _circleButton(
                icon: Icons.add,
                onTap: () => onChanged((value + 5).clamp(5, 100)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.15),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: value.toDouble(),
              min: 5,
              max: 100,
              divisions: 19,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
    );
  }
}

class StepBar extends StatelessWidget {
  final int step;
  const StepBar({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _stepDot(1, 'Fuel', step),
        _line(step > 1),
        _stepDot(2, 'Details', step),
        _line(step > 2),
        _stepDot(3, 'Tracking', step),
      ],
    );
  }

  Widget _stepDot(int n, String label, int current) {
    final active = current == n;
    final done = current > n;
    final color = done || active ? AppColors.primary : AppColors.border;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: done || active ? AppColors.primary : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, color: Colors.black, size: 14)
                : Text(
                    '$n',
                    style: TextStyle(
                      color: active ? Colors.black : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? AppColors.primary : AppColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _line(bool done) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
        decoration: BoxDecoration(
          color: done ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
