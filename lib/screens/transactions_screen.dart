// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> transactions = [];
  Map<String, double> transactionSummary = {};

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      final snapshot = await _firestore.collection('transactions').get();
      final List<Map<String, dynamic>> fetchedTransactions =
          snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();

      final summary = <String, double>{};
      for (var transaction in fetchedTransactions) {
        final String date = transaction['date'] ?? 'Unknown';
        final double amount = transaction['amount']?.toDouble() ?? 0.0;

        if (summary.containsKey(date)) {
          summary[date] = summary[date]! + amount;
        } else {
          summary[date] = amount;
        }
      }

      setState(() {
        transactions = fetchedTransactions;
        transactionSummary = summary;
      });
    } catch (e) {
      print('Error fetching transactions: $e');
    }
  }

  List<BarChartGroupData> generateGraphData() {
    return transactionSummary.entries
        .map((entry) => BarChartGroupData(
              x: transactionSummary.keys.toList().indexOf(entry.key),
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: Colors.teal,
                  width: 15,
                ),
              ],
            ))
        .toList();
  }

  Widget buildTransactionList() {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final bool isCredit = transaction['type'] == 'credit';
        final arrowIcon = isCredit
            ? const Icon(Icons.arrow_upward, color: Colors.green)
            : const Icon(Icons.arrow_downward, color: Colors.red);

        return ListTile(
          leading: arrowIcon,
          title: Text(transaction['description'] ?? 'No Description'),
          subtitle: Text('Date: ${transaction['date'] ?? 'Unknown'}'),
          trailing: Text(
            '${isCredit ? '+' : '-'}₹${transaction['amount']?.toStringAsFixed(2) ?? '0.00'}',
            style: TextStyle(
              color: isCredit ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: Column(
        children: [
          Container(
            height: 250,
            padding: const EdgeInsets.all(16.0),
            child: BarChart(
              BarChartData(
                barGroups: generateGraphData(),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < transactionSummary.keys.length) {
                          return Text(
                            transactionSummary.keys.toList()[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'All Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text('No transactions found'))
                : buildTransactionList(),
          ),
        ],
      ),
    );
  }
}
