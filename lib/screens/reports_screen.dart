// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // For PDF printing/exporting
import 'package:path_provider/path_provider.dart'; // For storing files locally
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to fetch data for the report
  Future<List<Map<String, dynamic>>> fetchDataForReport() async {
    try {
      final snapshot = await _firestore.collection('transactions').get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  // Function to generate a PDF report
  Future<void> generatePdfReport(List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Center(
        child: pw.Text(
          'Transaction Report',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
      );
    }));

    // Add the table with data
    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Table.fromTextArray(
        headers: ['ID', 'Description', 'Amount', 'Date'],
        data: data.map((transaction) {
          return [
            transaction['id'],
            transaction['description'] ?? '',
            transaction['amount']?.toString() ?? '0.0',
            transaction['date'] ?? '',
          ];
        }).toList(),
      );
    }));

    // Save the PDF to a file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/report.pdf');
    await file.writeAsBytes(await pdf.save());

    // Print the file or share it
    Printing.sharePdf(bytes: await pdf.save(), filename: 'report.pdf');
  }

  // Function to generate Excel report
  Future<void> generateExcelReport(List<Map<String, dynamic>> data) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Adding headers with correct CellValue types
    sheet.appendRow([
      'ID' as CellValue,
      'Description' as CellValue,
      'Amount' as CellValue,
      'Date' as CellValue
    ]);

    // Adding data rows with correct CellValue types
    for (var transaction in data) {
      sheet.appendRow([
        transaction['id'] as CellValue,
        transaction['description'] ?? '' as CellValue,
        (transaction['amount']?.toString() ?? '0.0') as CellValue,
        transaction['date'] ?? '' as CellValue,
      ]);
    }

    // Save Excel file to device
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/report.xlsx');
    await file.writeAsBytes(excel.encode()!);

    // Share the file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Excel file saved at ${file.path}')),
    );
  }

  // Display the report data as a table
  Widget buildReportTable(List<Map<String, dynamic>> data) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const <DataColumn>[
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('Amount')),
          DataColumn(label: Text('Date')),
        ],
        rows: data
            .map((transaction) => DataRow(cells: [
                  DataCell(Text(transaction['id'])),
                  DataCell(Text(transaction['description'] ?? '')),
                  DataCell(Text(transaction['amount']?.toString() ?? '0.0')),
                  DataCell(Text(transaction['date'] ?? '')),
                ]))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchDataForReport(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available for reports.'));
          }

          final data = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Report display options
                ElevatedButton(
                  onPressed: () => generatePdfReport(data),
                  child: const Text('Export to PDF'),
                ),
                ElevatedButton(
                  onPressed: () => generateExcelReport(data),
                  child: const Text('Export to Excel'),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Report Data:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                buildReportTable(data),
              ],
            ),
          );
        },
      ),
    );
  }
}
