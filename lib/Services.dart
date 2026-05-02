import 'package:flutter/material.dart';
import 'package:wizmi/mechanicservicepage.dart';
import 'package:wizmi/towingservicepage.dart';
import 'package:wizmi/diagnosticservices.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  // Constants (exactly like HomePage)
  static const Color _primaryColor = Color(0xFF0D47A1); // Navy Blue from homepage
  static const Color _whiteColor = Colors.white;

  // State variables (same pattern as HomePage)
  int? _hoveredIndex;

  // Service data (modeled after HomePage's ServiceButton approach)
  final List<Map<String, dynamic>> _services = [
    {
      'title': 'Towing Services',
      'icon': Icons.local_shipping,
      'page': const TowingServicePage(),
    },
    {
      'title': 'Mechanical Services',
      'icon': Icons.engineering,
      'page': const MechanicService(),
    },
    {
      'title': 'Emergency Assistance',
      'icon': Icons.emergency,
      'page': const TowingServicePage(), // Reuse or create new page
    },
    {
      'title': 'Diagnostic Checks',
      'icon': Icons.car_repair,
      'page': const DiagnosticService(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeaderSection(),
          _buildServiceList(),
        ],
      ),
    );
  }

  // 1. App Bar (same structure as HomePage)
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _primaryColor,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Our Services',
        style: TextStyle(
          color: _whiteColor,
          fontWeight: FontWeight.bold,
          fontSize: 24, // Matches your style
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: _whiteColor),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  // 2. Header Section (same pattern as HomePage's image section)
  Widget _buildHeaderSection() {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.car_repair, size: 56, color: Colors.white70),
            SizedBox(height: 8),
            Text(
              'Professional Auto Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Service List (same approach as HomePage's button list)
  Widget _buildServiceList() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: ListView.separated(
            itemCount: _services.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final service = _services[index];
              return _buildServiceCard(
                icon: service['icon'] as IconData,
                title: service['title'] as String,
                onPressed: () => _navigateToService(service['page'] as Widget),
                isHovered: _hoveredIndex == index,
                index: index, 
              );
            },
          ),
        ),
      ),
    );
  }

  // Service Card builder (identical structure to HomePage's button builder)
  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
    required bool isHovered,
     required int index,
  }) {
    return InkWell(
      onTap: onPressed,
      onHover: (hovering) => setState(() => _hoveredIndex = hovering ? index : null),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            if (isHovered)
              BoxShadow(
                color: _primaryColor.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: _primaryColor, size: 28),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: _primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: isHovered ? _primaryColor : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // Navigation handler (same as HomePage)
  void _navigateToService(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}