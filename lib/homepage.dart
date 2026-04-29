import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color primaryColor = const Color.fromARGB(255, 10, 61, 102);

  final List<Map<String, dynamic>> services = [
    {
      'icon': Icons.build_circle_outlined,
      'title': 'Spare Parts',
      'subtitle': 'Quality assured components',
      'route': 'carbrands',
      'color': Color(0xFF1565C0),  // Blue 800
    },
    
    {
      'icon': Icons.local_shipping_outlined,
      'title': 'Premium Towing',
      'subtitle': 'Swift roadside assistance',
      'route': 'towing',
      'color': Color(0xFF1976D2),  // Blue 700
    },
    {
      'icon': Icons.engineering,
      'title': 'Expert Mechanic',
      'subtitle': 'Premium repair services',
      'route': 'mechanic',
      'color': Color(0xFF1E88E5),  // Blue 600
    },
    {
      'icon': Icons.cleaning_services_outlined,
      'title': 'Luxury Wash',
      'subtitle': 'Premium detailing service',
      'route': 'carwash',
      'color': Color(0xFF0D47A1),  // Blue 900
    },
    {
      'icon': Icons.directions_car_outlined,
      'title': 'Car Rentals',
      'subtitle': 'Premium fleet selection',
      'route': 'rentcar',
      'color': Color(0xFF0277BD),  // Light Blue 800
    },
    {
      'icon': Icons.speed_outlined,
      'title': 'Smart Diagnostics',
      'subtitle': 'Advanced system analysis',
      'route': 'diagnostic',
      'color': Color(0xFF01579B),  // Light Blue 900
    },
  ];

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context); // Close dialog
                Navigator.pushReplacementNamed(context, 'log');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'WIZMI',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner Image using StreamBuilder
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection("homepage").snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  return Container(
                    width: double.infinity,
                    child: Image.network(
                      snapshot.data!.docs[0]['image'],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Error loading image: $error');
                        return Center(child: Text('Error loading image'));
                      },
                    ),
                  );
                }
                return SizedBox(
                  height: 200,
                );
              },
            ),

            // Welcome Text
            Container(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 15),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to WIZMI',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Your one-stop solution for all car services',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Services Grid
            Padding(
              padding: EdgeInsets.fromLTRB(20, 2, 20, 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, service['route']),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              service['color'].withOpacity(0.8),
                              service['color'],
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              service['icon'],
                              size: 50,
                              color: Colors.white,
                            ),
                            SizedBox(height: 15),
                            Text(
                              service['title'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              service['subtitle'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, 'profile');
              break;
            case 2:
              Navigator.pushNamed(context, 'notifications');
              break;
          }
        },
      ),
    );
  }
}