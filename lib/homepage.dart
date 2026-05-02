import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:wizmi/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _services = [
    {
      'icon': Icons.build_circle_outlined,
      'title': 'Spare Parts',
      'subtitle': 'Quality assured components',
      'route': 'carbrands',
      'color': const Color(0xFF1565C0),
    },
    {
      'icon': Icons.local_shipping_outlined,
      'title': 'Premium Towing',
      'subtitle': 'Swift roadside assistance',
      'route': 'towing',
      'color': const Color(0xFF1976D2),
    },
    {
      'icon': Icons.engineering,
      'title': 'Expert Mechanic',
      'subtitle': 'Premium repair services',
      'route': 'mechanic',
      'color': const Color(0xFF1E88E5),
    },
    {
      'icon': Icons.cleaning_services_outlined,
      'title': 'Luxury Wash',
      'subtitle': 'Premium detailing service',
      'route': 'carwash',
      'color': const Color(0xFF0D47A1),
    },
    {
      'icon': Icons.directions_car_outlined,
      'title': 'Car Rentals',
      'subtitle': 'Premium fleet selection',
      'route': 'rentcar',
      'color': const Color(0xFF0277BD),
    },
    {
      'icon': Icons.speed_outlined,
      'title': 'Smart Diagnostics',
      'subtitle': 'Advanced system analysis',
      'route': 'diagnostic',
      'color': const Color(0xFF01579B),
    },
  ];

  static const List<Map<String, dynamic>> _bannerSlides = [
    {
      'icon': Icons.local_shipping,
      'title': '24/7 Emergency Towing',
      'subtitle': 'From EGP 150 — We come to you',
      'colors': [Color(0xFF0D47A1), Color(0xFF1565C0)],
    },
    {
      'icon': Icons.cleaning_services,
      'title': 'Luxury Car Wash',
      'subtitle': 'Packages from EGP 25',
      'colors': [Color(0xFF006064), Color(0xFF00838F)],
    },
    {
      'icon': Icons.speed,
      'title': 'Smart Diagnostics',
      'subtitle': 'Full scan — EGP 250 flat fee',
      'colors': [Color(0xFF1B5E20), Color(0xFF2E7D32)],
    },
  ];

  String _userName = '';
  String _carModel = '';
  int _selectedIndex = 0;
  int _bannerIndex = 0;

  late PageController _pageController;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadUserData();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_bannerIndex + 1) % _bannerSlides.length;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() => _bannerIndex = next);
    });
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _userName = doc.data()?['name'] ?? doc.data()?['firstName'] ?? '';
          _carModel = doc.data()?['carModel'] ?? '';
        });
      }
    } catch (_) {}
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) Navigator.pushReplacementNamed(context, 'log');
    }
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'WIZMI',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            tooltip: 'Cart',
            onPressed: () => Navigator.pushNamed(context, 'cart'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(),
            _buildMyCarCard(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Text(
                'Our Services',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            _buildServicesGrid(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppTheme.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppTheme.primary),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications, color: AppTheme.primary),
            label: 'Notifications',
          ),
        ],
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          if (index == 1) {
            Navigator.pushNamed(context, 'profile')
                .then((_) => setState(() => _selectedIndex = 0));
          } else if (index == 2) {
            Navigator.pushNamed(context, 'notifications')
                .then((_) => setState(() => _selectedIndex = 0));
          }
        },
      ),
    );
  }

  Widget _buildBanner() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _bannerSlides.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (context, index) {
              final slide = _bannerSlides[index];
              final colors = slide['colors'] as List<Color>;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colors.last.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slide['title'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            slide['subtitle'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (_userName.isNotEmpty)
                            Text(
                              'Hello, $_userName!',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white60,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      slide['icon'] as IconData,
                      size: 72,
                      color: Colors.white24,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SmoothPageIndicator(
          controller: _pageController,
          count: _bannerSlides.length,
          effect: ExpandingDotsEffect(
            dotHeight: 6,
            dotWidth: 6,
            expansionFactor: 3,
            activeDotColor: AppTheme.primary,
            dotColor: AppTheme.primary.withValues(alpha: 0.25),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMyCarCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, 'profile').then((_) => _loadUserData()),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_car, color: AppTheme.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _carModel.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Car',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            _carModel,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Add Your Car',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
              ),
              Text(
                _carModel.isNotEmpty ? 'Change →' : '→',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _services.length,
        itemBuilder: (context, index) =>
            _ServiceCard(service: _services[index]),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final Color color = service['color'] as Color;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, service['route'] as String),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.85), color],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    service['icon'] as IconData,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  service['title'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  service['subtitle'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
