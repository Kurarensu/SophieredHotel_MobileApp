import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'package:intl/intl.dart';

class TransactionHistoryPage extends StatefulWidget {
  final String? token;

  const TransactionHistoryPage({Key? key, required this.token}) : super(key: key);

  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  late String? token;
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  String? requestType = 'Cleaning'; // Default request type
  TextEditingController roomServiceController = TextEditingController();


  @override
  void initState() {
    super.initState();
    token = widget.token;
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    const String apiUrl = 'http://161.35.97.230/api/transaction-history';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        setState(() {
          transactions = responseData.map((item) {
            return {
              'id': item['id'] ?? '',
              'date': item['date'] ?? '',
              'description': item['description'] ?? '',
              'amount': NumberFormat('#,###.00').format(_parseAmount(item['amount'] ?? '0')),
              'paymentStatus': item['paymentStatus'] ?? '',
              'paymentMode': item['paymentMode'] ?? 'N/A',
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching transactions: $e');
    }
  }

  int _parseAmount(dynamic amount) {
    if (amount is int) return amount;
    if (amount is String) {
      return int.tryParse(amount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    return 0;
  }


  // Show the dialog for selecting request type
  void _showRequestTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Request Type'),
          content: DropdownButton<String>(
            value: requestType,
            onChanged: (newValue) {
              setState(() {
                requestType = newValue!;
              });
              Navigator.of(context).pop(); // Close the dialog once selected
            },
            items: ['Cleaning', 'Maintenance', 'Supplies'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Function to send POST request for room service
  Future<void> _requestRoomService(int bookingId, String requestType, String description) async {
    const String apiUrl = 'http://161.35.97.230/api/room-service-request'; // Replace with your actual API endpoint

      setState(() {
        isLoading = true;
      });

      // Construct request data
      final Map<String, dynamic> requestData = {
        'booking_id': bookingId,
        'request_type': requestType,
        'description': description,
        'status': 'pending', // Default status
      };

      // Print the request data for debugging
      print('Request Data: ${json.encode(requestData)}');

      // Send the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token', // Use the token for authorization
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        // Handle the successful response
        print('Room service request submitted successfully');
        setState(() {
          isLoading = false;
        });

        // Show success message or handle UI update
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Room Service Request Submitted Successfully')),
        );
      } else {
        throw Exception('Failed to submit room service request');
      }

  }

  // Show the main transaction details dialog
  void _showTransactionDetails(BuildContext context, Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Transaction Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Date: ${transaction['date']}'),
              Text('Description: ${transaction['description']}'),
              Text('Amount: ${transaction['amount']}'),
              Text('Payment Status: ${transaction['paymentStatus']}'),
              Text('Payment Mode: ${transaction['paymentMode']}'),
              const SizedBox(height: 16),
              const Text('Request Room Service:', style: TextStyle(fontWeight: FontWeight.bold)),

              // Button to open request type dialog
              ElevatedButton(
                onPressed: () {
                  _showRequestTypeDialog(context); // Show dropdown for request type
                },
                child: Text('Select Request Type: $requestType'),
              ),

              const SizedBox(height: 16),
              TextField(
                controller: roomServiceController,
                decoration: const InputDecoration(
                  hintText: 'Enter your request here',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                // Call the post request with booking_id, requestType, and description

                // Print the data being passed to _requestRoomService
                print('Transaction ID: ${transaction['id']}'); // Print the booking ID
                print('Request Type: $requestType'); // Print the selected request type
                print('Room Service Request: ${roomServiceController.text}'); // Print the room service request

                _requestRoomService(
                  transaction['id'], // Assuming you have the booking ID in the transaction
                  requestType!,
                  roomServiceController.text,
                );
                Navigator.of(context).pop(); // Close dialog after submitting
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
              child: const Text('Request Service'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.white60,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
          ? const Center(child: Text('No transactions found.'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(transaction['description']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction['date']),
                    const SizedBox(height: 4),
                    Text('Amount: ${transaction['amount']}'),
                    const SizedBox(height: 4),
                    Text('Payment Status: ${transaction['paymentStatus']}'),
                    const SizedBox(height: 4),
                    Text('Payment Mode: ${transaction['paymentMode']}'),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    _showTransactionDetails(context, transaction);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                  ),
                  child: const Text('Details'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
