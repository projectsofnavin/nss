import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FundsScreen extends StatelessWidget {
  const FundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members Fund Status'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('members').snapshots(),
        builder: (context, membersSnapshot) {
          if (membersSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (membersSnapshot.hasError) {
            return const Center(child: Text('Error fetching members data.'));
          }
          if (!membersSnapshot.hasData || membersSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No members found.'));
          }

          final members = membersSnapshot.data!.docs;

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index].data() as Map<String, dynamic>;
              final memberId = members[index].id;

              final memberName = member['name'] ?? 'Unknown';

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 3,
                child: ExpansionTile(
                  title: Text(
                    memberName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Text(
                      memberName.isNotEmpty ? memberName[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('funds')
                          .where('memberId', isEqualTo: memberId)
                          .snapshots(),
                      builder: (context, fundsSnapshot) {
                        if (fundsSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (fundsSnapshot.hasError) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Error fetching fund data.'),
                          );
                        }
                        if (!fundsSnapshot.hasData ||
                            fundsSnapshot.data!.docs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No contributions found.'),
                          );
                        }

                        final contributions = fundsSnapshot.data!.docs;

                        return Column(
                          children: contributions.map((doc) {
                            final fund = doc.data() as Map<String, dynamic>;
                            final amount = fund['amount']?.toString() ?? '0';
                            final date = fund['date'] ?? 'Unknown';

                            return ListTile(
                              title: Text('Amount: $amount'),
                              subtitle: Text('Date: $date'),
                              leading: const Icon(Icons.attach_money,
                                  color: Colors.green),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
