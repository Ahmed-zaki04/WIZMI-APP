import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wizmi/carwashingpage.dart';
import 'package:wizmi/diagnosticservices.dart';
import 'package:wizmi/mechanicservicepage.dart';
import 'package:wizmi/towingservicepage.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  static const _services = [
    _ServiceItem(
      title: 'Towing Services',
      icon: Icons.local_shipping_outlined,
      price: 150,
      colors: [Color(0xFF0A3880), Color(0xFF0D47A1)],
      route: 'towing',
    ),
    _ServiceItem(
      title: 'Expert Mechanic',
      icon: Icons.engineering,
      price: 150,
      colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
      route: 'mechanic',
    ),
    _ServiceItem(
      title: 'Diagnostic Checks',
      icon: Icons.speed_outlined,
      price: 250,
      colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
      route: 'diagnostic',
    ),
    _ServiceItem(
      title: 'Luxury Car Wash',
      icon: Icons.cleaning_services_outlined,
      price: 25,
      colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
      route: 'carwash',
    ),
  ];

  Widget _pageFor(String route) {
    switch (route) {
      case 'towing':    return const TowingServicePage();
      case 'mechanic':  return const MechanicService();
      case 'diagnostic':return const DiagnosticService();
      case 'carwash':   return const CarWashingPage();
      default:          return const TowingServicePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Our Services')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: _services.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.88,
          ),
          itemBuilder: (context, index) {
            final s = _services[index];
            return _ServiceCard(
              item: s,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => _pageFor(s.route)),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
class _ServiceItem {
  final String title;
  final IconData icon;
  final int price;
  final List<Color> colors;
  final String route;

  const _ServiceItem({
    required this.title,
    required this.icon,
    required this.price,
    required this.colors,
    required this.route,
  });
}

// ── Card widget ───────────────────────────────────────────────────────────────
class _ServiceCard extends StatelessWidget {
  final _ServiceItem item;
  final VoidCallback onTap;

  const _ServiceCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      shadowColor: item.colors.first.withValues(alpha: 0.4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: item.colors,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon circle
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: Colors.white, size: 26),
                ),
                const Spacer(),
                // Title
                Text(
                  item.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Price hint
                Text(
                  'From EGP ${item.price}',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                // Arrow row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward,
                          color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
