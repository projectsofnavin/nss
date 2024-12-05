import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.teal[700],
        actions: [
          // Sorting options
          PopupMenuButton<String>(
            onSelected: (value) {
              // You can add functionality for sorting here later
              print(
                  value); // For now, just printing the selected sorting option
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'Date',
                child: Text('Sort by Date'),
              ),
              const PopupMenuItem<String>(
                value: 'Role',
                child: Text('Sort by Role'),
              ),
            ],
            icon: const Icon(Icons.sort, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            // Dummy Notification Card 1
            NotificationCard(
              message: 'Your loan request has been approved.',
              role: 'Member',
              date: DateTime.now().subtract(const Duration(days: 1)),
            ),
            // Dummy Notification Card 2
            NotificationCard(
              message: 'A new update is available for your account.',
              role: 'Admin',
              date: DateTime.now().subtract(const Duration(days: 2)),
            ),
            // Dummy Notification Card 3
            NotificationCard(
              message: 'A new product has been added to your catalog.',
              role: 'Admin',
              date: DateTime.now().subtract(const Duration(days: 3)),
            ),
            // Dummy Notification Card 4
            NotificationCard(
              message: 'You have a new message from support.',
              role: 'User',
              date: DateTime.now().subtract(const Duration(days: 5)),
            ),
            // More notifications can be added here
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String message;
  final String role;
  final DateTime date;

  const NotificationCard({
    super.key,
    required this.message,
    required this.role,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4.0,
      color: Colors.red[50],
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          message,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.teal[800],
          ),
        ),
        subtitle: Text(
          'Role: $role\nDate: ${date.day}/${date.month}/${date.year}',
          style: TextStyle(color: Colors.teal[600]),
        ),
        leading: const Icon(
          Icons.notifications_active,
          color: Colors.green,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.red,
        ),
        onTap: () {
          // Add functionality for tapping on a notification
        },
      ),
    );
  }
}
