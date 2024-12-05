import 'package:flutter/material.dart';

class BackupRestoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                // Implement backup logic here
                print('Backup initiated');
              },
              child: const Text('Backup Data'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement restore logic here
                print('Restore initiated');
              },
              child: const Text('Restore Data'),
            ),
          ],
        ),
      ),
    );
  }
}
