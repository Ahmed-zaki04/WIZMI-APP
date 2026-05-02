import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color _primary = Color(0xFF0D47A1);

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

  String _userName = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: _primary,
        elevation: 0,
        title: const Text(
          'WIZMI',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
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
            _buildHeroBanner(),
            _buildSectionHeader(),
            _buildServicesGrid(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        elevation: 8,
        selectedIndex: _selectedIndex,
        indicatorColor: _primary.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF0D47A1)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF0D47A1)),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications, color: Color(0xFF0D47A1)),
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

  Widget _buildHeroBanner() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('homepage').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final imageUrl =
              snapshot.data!.docs[0]['image'] as String? ?? '';
          if (imageUrl.isNotEmpty) {
            return SizedBox(
              width: double.infinity,
              height: 200,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultHero(),
              ),
            );
          }
        }
        return _buildDefaultHero();
      },
    );
  }

  Widget _buildDefaultHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.directions_car, size: 48, color: Colors.white70),
          const SizedBox(height: 12),
          Text(
            _userName.isNotEmpty ? 'Hello, $_userName!' : 'Welcome to WIZMI',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your one-stop solution for all car services',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        'Our Services',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A2E),
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
          childAspectRatio: 0.88,
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
