import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class MemberLoanDetailsScreen extends StatelessWidget {
  final String memberId;

  const MemberLoanDetailsScreen({super.key, required this.memberId});

  // Function to calculate the interest dynamically based on loan duration
  double _calculateInterest(double principal, double interestRate,
      DateTime startDate, DateTime currentDate) {
    int months = currentDate.difference(startDate).inDays ~/ 30;
    if (months > 6) {
      interestRate += 2.0; // Apply different rate after 6 months
    }
    return (principal * interestRate * months) / 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Details'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('loans')
            .where('memberId', isEqualTo: memberId)
            .snapshots(),
        builder: (context, loanSnapshot) {
          if (loanSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (loanSnapshot.hasError) {
            return const Center(child: Text('Error fetching loan details.'));
          }
          if (!loanSnapshot.hasData || loanSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No loan information found.'));
          }

          final loan =
              loanSnapshot.data!.docs[0].data() as Map<String, dynamic>;

          // Check if the loan data exists
          if (loan['amount'] == null) {
            return const Center(
                child: Text('Loan data is incomplete or missing.'));
          }

          final amount = loan['amount']?.toDouble() ?? 0;
          final interestRate = loan['interestRate']?.toDouble() ?? 0;
          final startDate = (loan['startDate'] as Timestamp).toDate();
          final dueDate = (loan['dueDate'] as Timestamp).toDate();
          final memberName = loan['memberName'] ?? 'Unknown';
          final formattedStartDate = DateFormat('dd-MM-yyyy').format(startDate);
          final formattedDueDate = DateFormat('dd-MM-yyyy').format(dueDate);

          // Calculate the interest dynamically
          double interest = _calculateInterest(
              amount, interestRate, startDate, DateTime.now());

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Member Info Card
                  Card(
                    elevation: 5,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Text(
                              memberName.isNotEmpty
                                  ? memberName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                memberName,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text('Loan Start Date: $formattedStartDate'),
                              Text('Due Date: $formattedDueDate'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Loan Info Card
                  Card(
                    elevation: 5,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Loan Information',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('Principal Amount: ₹$amount'),
                          Text('Interest Rate: $interestRate%'),
                          Text(
                              'Calculated Interest: ₹${interest.toStringAsFixed(2)}'),
                          Text(
                            'Total Payable Amount: ₹${(amount + interest).toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          Text(
                            'Loan Duration: ${DateTime.now().difference(startDate).inDays ~/ 30} months',
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Loan Status Card
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Loan Status',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Current Balance: ₹${(amount + interest).toStringAsFixed(2)}',
                          ),
                          Text('Due Date: $formattedDueDate'),
                          Text(
                            'Remaining Days: ${dueDate.difference(DateTime.now()).inDays} days',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
