import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nss/screens/notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Method to fetch the current user's profile data from Firebase
  Future<User?> _getUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user;
    }
    return null;
  }

  // Method to fetch real-time data (Total Members, Funds, Loans)
  Stream<DocumentSnapshot> _getRealTimeData() {
    return FirebaseFirestore.instance
        .collection('dashboard')
        .doc('stats')
        .snapshots();
  }

  // Method to fetch recent activity data
  Stream<QuerySnapshot> _getRecentActivities() {
    return FirebaseFirestore.instance
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nawa Urjasil Sathi Samuha'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to the notifications screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search members, funds, transactions...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) {
                // Handle search query
              },
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section with User Profile and Dynamic Data
              FutureBuilder<User?>(
                future: _getUserProfile(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasData) {
                    User? user = snapshot.data;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      color: Colors.teal[100],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${user?.displayName ?? 'Super Admin'}!',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text('Here is your quick overview:'),
                            const SizedBox(height: 16),
                            StreamBuilder<DocumentSnapshot>(
                              stream: _getRealTimeData(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                if (snapshot.hasData && snapshot.data!.exists) {
                                  var data = snapshot.data!.data()
                                      as Map<String, dynamic>;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '📋 Total Members: ${data['membersCount']}'),
                                      Text('💰 Total Funds: ${data['funds']}'),
                                      Text(
                                          '📊 Loans Disbursed: ${data['loansDisbursed']}'),
                                    ],
                                  );
                                }
                                return const Text('No data available');
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const Text('Failed to load user profile');
                },
              ),
              const SizedBox(height: 16),

              // Stats Charts Section
              const Text(
                'Quick Stats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildStatsChart(),

              const SizedBox(height: 16),

              // Navigation Options (Quick Links)
              const Text(
                'Quick Links',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildNavigationCard(context, 'Members', Icons.people,
                      Colors.blue, '/members'),
                  _buildNavigationCard(context, 'Funds',
                      Icons.account_balance_wallet, Colors.green, '/funds'),
                  _buildNavigationCard(context, 'Loans', Icons.request_quote,
                      Colors.orange, '/loans'),
                  _buildNavigationCard(context, 'Transactions',
                      Icons.receipt_long, Colors.purple, '/transactions'),
                  _buildNavigationCard(context, 'Reports', Icons.bar_chart,
                      Colors.red, '/reports'),
                  _buildNavigationCard(context, 'Settings', Icons.settings,
                      Colors.grey, '/settings'),
                ],
              ),
              const SizedBox(height: 16),

              // Activity Feed with Filters
              const Text(
                'Recent Activities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: _getRecentActivities(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasData) {
                    var activities = snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        var activity = activities[index];
                        return ListTile(
                          leading: const Icon(Icons.check_circle,
                              color: Colors.green),
                          title: Text(activity['title']),
                          subtitle:
                              Text(activity['timestamp'].toDate().toString()),
                          onTap: () {
                            // Show details of the activity
                          },
                        );
                      },
                    );
                  }
                  return const Text('No recent activities');
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for adding a new member, transaction, etc.
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Stats Chart Widget
  Widget _buildStatsChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: const FlTitlesData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 50000), // Example data points
                const FlSpot(1, 100000),
                const FlSpot(2, 150000),
                const FlSpot(3, 200000),
              ],
              isCurved: true,
              color: Colors.green, // Use 'color' instead of 'colors'
              belowBarData: BarAreaData(
                show: true,
                color:
                    Colors.green.withOpacity(0.3), // Correct usage of 'color'
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation Card Widget
  Widget _buildNavigationCard(BuildContext context, String title, IconData icon,
      Color color, String routeName) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.7), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
