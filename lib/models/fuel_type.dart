import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class FuelType {
  final String id;
  final String name;
  final String subtitle;
  final double pricePerLiter;
  final Color color;
  final IconData icon;
  final String description;

  const FuelType({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.pricePerLiter,
    required this.color,
    required this.icon,
    required this.description,
  });

  static const List<FuelType> all = [
    FuelType(
      id: 'benzin_80',
      name: 'Benzin 80',
      subtitle: 'Standard Grade',
      pricePerLiter: 10.75,
      color: AppColors.textSecondary,
      icon: Icons.local_gas_station,
      description: 'Suitable for older vehicles and motorcycles',
    ),
    FuelType(
      id: 'benzin_92',
      name: 'Benzin 92',
      subtitle: 'Mid Grade',
      pricePerLiter: 13.75,
      color: AppColors.amber,
      icon: Icons.local_gas_station,
      description: 'Recommended for most modern vehicles',
    ),
    FuelType(
      id: 'benzin_95',
      name: 'Benzin 95',
      subtitle: 'Premium Grade',
      pricePerLiter: 15.25,
      color: AppColors.primary,
      icon: Icons.local_gas_station,
      description: 'High performance fuel for premium cars',
    ),
    FuelType(
      id: 'solar',
      name: 'Solar',
      subtitle: 'Diesel',
      pricePerLiter: 10.75,
      color: Color(0xFF3498DB),
      icon: Icons.water_drop,
      description: 'For diesel engines, trucks, and generators',
    ),
  ];
}
