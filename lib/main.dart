import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/members_screen.dart';
import 'screens/funds_screen.dart';
import 'screens/loans_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const NSSApp());
}

class NSSApp extends StatefulWidget {
  const NSSApp({super.key});

  @override
  _NSSAppState createState() => _NSSAppState();
}

class _NSSAppState extends State<NSSApp> {
  // Check if the user is logged in
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  // Check the authentication status
  Future<void> _checkUserLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nawa Urjasil Sathi Samuha',
      theme: ThemeData(primarySwatch: Colors.teal),
      initialRoute:
          _user == null ? '/login' : '/', // Navigate based on auth status
      routes: {
        '/login': (context) => LoginScreen(),
        '/': (context) => const HomeScreen(),
        '/members': (context) => const MembersScreen(),
        '/funds': (context) => const FundsScreen(),
        '/loans': (context) => const LoansScreen(),
        '/transactions': (context) => const TransactionsScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
