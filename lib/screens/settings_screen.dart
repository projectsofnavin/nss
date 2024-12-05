import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nss/screens/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isNotificationsEnabled = false;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load saved preferences for notifications and theme
  _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isNotificationsEnabled = prefs.getBool('notifications') ?? true;
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
    });
  }

  // Save preferences for notifications and theme
  _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('notifications', _isNotificationsEnabled);
    prefs.setBool('dark_mode', _isDarkMode);
  }

  // Handle theme change
  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    _savePreferences();
    // Update the app theme
    if (_isDarkMode) {
      ThemeMode.dark;
    } else {
      ThemeMode.light;
    }
  }

  // Handle notifications toggle
  void _toggleNotifications(bool value) {
    setState(() {
      _isNotificationsEnabled = value;
    });
    _savePreferences();
    // You can implement your own notification logic here
  }

  // Log out the user
  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  // Reset the user's password
  Future<void> _changePassword() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        await _auth.sendPasswordResetEmail(email: user.email!);
        _showMessage("Password reset email sent!");
      } catch (e) {
        _showMessage("Error sending password reset email: $e");
      }
    }
  }

  // Show message to the user
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Notifications Toggle
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: _isNotificationsEnabled,
              onChanged: _toggleNotifications,
            ),
            const SizedBox(height: 20),

            // Theme Toggle
            SwitchListTile(
              title: const Text('Enable Dark Theme'),
              value: _isDarkMode,
              onChanged: _toggleTheme,
            ),
            const SizedBox(height: 20),

            // Password Reset Button
            ListTile(
              title: const Text('Change Password'),
              onTap: _changePassword,
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            const Divider(),

            // Logout Button
            ListTile(
              title: const Text('Log Out'),
              onTap: _logout,
              trailing: const Icon(Icons.exit_to_app),
            ),
          ],
        ),
      ),
    );
  }
}
