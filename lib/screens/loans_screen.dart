import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nss/screens/member_loan_details_screen.dart';

class LoansScreen extends StatelessWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Management'),
      ),
      body: Column(
        children: [
          // Loan Requests Panel
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.teal[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Loan Requests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('loanRequests')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Text('Error fetching loan requests.');
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text('No loan requests found.');
                    }

                    final requests = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final request =
                            requests[index].data() as Map<String, dynamic>;
                        final memberName = request['memberName'] ?? 'Unknown';
                        final amount = request['amount']?.toString() ?? '0';

                        return ListTile(
                          title: Text('Name: $memberName'),
                          subtitle: Text('Requested Amount: $amount'),
                          trailing: const Icon(Icons.arrow_forward,
                              color: Colors.teal),
                          onTap: () {
                            // Handle loan request details
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Members Loan Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('members').snapshots(),
              builder: (context, membersSnapshot) {
                if (membersSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (membersSnapshot.hasError) {
                  return const Center(child: Text('Error fetching members.'));
                }
                if (!membersSnapshot.hasData ||
                    membersSnapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No members found.'));
                }

                final members = membersSnapshot.data!.docs;

                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member =
                        members[index].data() as Map<String, dynamic>;
                    final memberId = members[index].id;
                    final memberName = member['name'] ?? 'Unknown';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      elevation: 3,
                      child: ListTile(
                        title: Text(
                          memberName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text('Tap to view loan details'),
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Text(
                            memberName.isNotEmpty
                                ? memberName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        trailing:
                            const Icon(Icons.arrow_forward, color: Colors.teal),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MemberLoanDetailsScreen(
                                memberId: '',
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddLoanScreen(),
            ),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddLoanScreen extends StatefulWidget {
  const AddLoanScreen({super.key});

  @override
  _AddLoanScreenState createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final _amountController = TextEditingController();
  final _interestController = TextEditingController();
  final _dueDateController = TextEditingController();
  String selectedMemberId = '';
  DateTime? dueDate;

  // Fetch members dynamically from Firestore
  Future<List<DocumentSnapshot>> _getMembers() async {
    final membersSnapshot =
        await FirebaseFirestore.instance.collection('members').get();
    return membersSnapshot.docs;
  }

  double _calculateInterest(double principal, double interestRate, int months) {
    if (months > 6) {
      // Apply different interest rate if the loan is more than 6 months
      interestRate = interestRate + 2.0; // Example of increased rate
    }
    return (principal * interestRate * months) / 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Loan'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching members.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No members available.'));
          }

          final members = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Member',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedMemberId.isEmpty ? null : selectedMemberId,
                    onChanged: (value) {
                      setState(() {
                        selectedMemberId = value!;
                      });
                    },
                    items: members.map((member) {
                      final memberName = member['name'] ?? 'Unknown';
                      return DropdownMenuItem<String>(
                        value: member.id,
                        child: Text(memberName),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Loan Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter loan amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _interestController,
                    decoration: const InputDecoration(
                      labelText: 'Interest Rate (%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter interest rate';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dueDateController,
                    decoration: const InputDecoration(
                      labelText: 'Due Date',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          dueDate = pickedDate;
                          _dueDateController.text =
                              "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                        });
                      }
                    },
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedMemberId.isEmpty ||
                          _amountController.text.isEmpty ||
                          _interestController.text.isEmpty ||
                          dueDate == null) {
                        // Handle form validation failure
                        return;
                      }

                      final amount = double.tryParse(_amountController.text);
                      final interestRate =
                          double.tryParse(_interestController.text);
                      if (amount == null || interestRate == null) {
                        // Handle invalid amount or interest rate
                        return;
                      }

                      final months =
                          dueDate!.difference(DateTime.now()).inDays ~/ 30;

                      final interest =
                          _calculateInterest(amount, interestRate, months);

                      // Save loan to Firestore
                      FirebaseFirestore.instance.collection('loans').add({
                        'memberId': selectedMemberId,
                        'amount': amount,
                        'interestRate': interestRate,
                        'dueDate': dueDate,
                        'interest': interest,
                        'remainingBalance': amount + interest,
                      });

                      // Show a confirmation message or navigate back
                      Navigator.pop(context);
                    },
                    child: const Text('Add Loan'),
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
