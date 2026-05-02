import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wizmi/Services.dart';
import 'package:wizmi/sparepartspage.dart';
import 'package:wizmi/towingservicepage.dart';
import 'package:wizmi/admin/admin_dashboard.dart';
import 'package:wizmi/admin/admin_login.dart';
import 'package:wizmi/admin/admin_signup.dart';
import 'package:wizmi/carbrands.dart';
import 'package:wizmi/cartpage.dart';
import 'package:wizmi/checkout.dart';
import 'package:wizmi/carrentalpage.dart';
import 'package:wizmi/carwashingpage.dart';
import 'package:wizmi/diagnosticservices.dart';
import 'package:wizmi/homepage.dart';
import 'package:wizmi/login.dart';
import 'package:wizmi/mechanicservicepage.dart';
import 'package:wizmi/my_bookings.dart';
import 'package:wizmi/profile.dart';
import 'package:wizmi/splash_screen.dart';
import 'package:wizmi/theme.dart';
import 'firebase_options.dart';
import 'package:wizmi/signup.dart';
import 'package:flutter/material.dart';
import 'package:wizmi/notifications_page.dart';
import 'package:wizmi/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  debugPrint('firebase initialized');
  runApp(const Main());
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        debugPrint('User is currently signed out!');
      } else {
        debugPrint('User is signed in!');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const Splash(),
      routes: {
        'splash':          (context) => const Splash(),
        'login':           (context) => const Login(),
        'signup':          (context) => const SignUp(),
        'home':            (context) => const HomePage(),
        'admin_login':     (context) => const AdminLogin(),
        'admin_signup':    (context) => const AdminSignup(),
        'admin_dashboard': (context) => const AdminDashboard(),
        'services':        (context) => ServicesPage(),
        'towing':          (context) => TowingServicePage(),
        'mechanic':        (context) => MechanicService(),
        'diagnostic':      (context) => DiagnosticService(),
        'spareparts':      (context) => const Product(),
        'carwash':         (context) => CarWashingPage(),
        'rentcar':         (context) => CarRentalPage(),
        'carbrands':       (context) => const CarBrands(),
        'cart':            (context) => const CartPage(),
        'checkout':        (context) => const CheckoutPage(items: [], total: 0),
        'profile':         (context) => const ProfilePage(),
        'log':             (context) => const Login(),
        'sign':            (context) => const SignUp(),
        'notifications':   (context) => const NotificationsPage(),
        'my_bookings':     (context) => const MyBookingsPage(),
      },
    );
  }
}
