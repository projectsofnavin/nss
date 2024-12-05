import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to Change Password Screen
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notification Settings'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to Notification Settings Screen
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Backup Data'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Handle Backup Logic
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Restore Data'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Handle Restore Logic
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About the App'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to About Screen
              },
            ),
          ],
        ),
      ),
    );
  }
}
