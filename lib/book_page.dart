import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:sophiered/ConfirmedBookingsPage.dart';

class BookPage extends StatefulWidget {
  final Map<String, String>? selectedRoom;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfDays;
  final double totalCost;
  final int numberOfAdults;
  final int numberOfKids;
  final String? token;
  final int? userId;  // Pass the user ID for booking creation

  const BookPage({
    super.key,
    required this.selectedRoom,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfDays,
    required this.totalCost,
    required this.numberOfAdults,
    required this.numberOfKids,
    required this.token,
    required this.userId,  // Add user ID to constructor
  });

  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  TextEditingController _notesController = TextEditingController();
  double downPayment = 0;

  @override
  void initState() {
    super.initState();
    downPayment = widget.totalCost * 0.5;  // 50% down payment
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '₱', decimalDigits: 2);
    return formatter.format(value);
  }

  // Function to send POST request to save booking
  Future<void> _saveBooking(String paymentMethod) async {
    final String apiUrl = 'http://161.35.97.230/api/save-booking'; // Replace with your API URL


    // Prepare the booking data to be sent
    final Map<String, dynamic> bookingData = {
      'users_id': widget.userId,  // User ID for the booking
      'rooms_id': widget.selectedRoom?['id'] ?? '',  // Send the room ID
      'book_date_start': DateFormat('yyyy-MM-dd').format(widget.checkInDate),
      'book_date_end': DateFormat('yyyy-MM-dd').format(widget.checkOutDate),
      'number_of_adults': widget.numberOfAdults,
      'number_of_children': widget.numberOfKids,
      'promo_code': '',  // You can leave this empty or send a promo code if needed
      'specialreq': _notesController.text,  // Special request (additional notes)
      'total_price': widget.totalCost,  // Total price for the booking
    };

    try {

      // Print the entire map for checking
      print('Booking Data: $bookingData');

      // Alternatively, print individual elements
      print('User ID: ${bookingData['users_id']}');
      print('Room ID: ${bookingData['rooms_id']}');
      print('Booking Start Date: ${bookingData['book_date_start']}');
      print('Booking End Date: ${bookingData['book_date_end']}');
      print('Number of Adults: ${bookingData['number_of_adults']}');
      print('Number of Children: ${bookingData['number_of_children']}');
      print('Promo Code: ${bookingData['promo_code']}');
      print('Special Request: ${bookingData['specialreq']}');
      print('Total Price: ${bookingData['total_price']}');

      print('Token:${widget.token}');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${widget.token}',  // Send the token for authentication
          'Content-Type': 'application/json',
        },
        body: json.encode(bookingData),
      );

      if (response.statusCode == 200) {
        // Handle successful response (Booking saved)
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          // Show confirmation and navigate to the next screen
          _showBookingConfirmation(context, paymentMethod);
        } else {
          // Handle failure case
          _showErrorMessage('Failed to save booking.');
        }
      } else {
        _showErrorMessage('Failed to save booking. Please try again.');
      }
    } catch (e) {
      _showErrorMessage('Error: $e');
    }
  }

  void _showPaymentOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Payment Method'),
          content: const Text('Please select a payment method to complete your booking.'),
          actions: [
            TextButton(
              onPressed: () {
                // Handle GCash payment
                Navigator.of(context).pop();
                _saveBooking('GCash');
              },
              child: const Text('GCash'),
            ),
            TextButton(
              onPressed: () {
                // Handle Over-the-Counter payment
                Navigator.of(context).pop();
                _saveBooking('Over-the-Counter');
              },
              child: const Text('Over-the-Counter'),
            ),
          ],
        );
      },
    );
  }

  void _showBookingConfirmation(BuildContext context, String paymentMethod) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Booking Confirmed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Thank you for booking with us!'),
              Text('Payment Method: $paymentMethod'),
              SizedBox(height: 20),
              Text('Down Payment (50%): ${_formatCurrency(downPayment)}'),
              SizedBox(height: 20),
              if (paymentMethod == 'GCash')
                Image.asset('assets/qrcode.png', width: 500, height: 500),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionHistoryPage(token: widget.token),
                  ),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedCost = _formatCurrency(widget.totalCost);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: Colors.white60,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Summary',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Check-In Date: ${DateFormat('yyyy-MM-dd').format(widget.checkInDate)}'),
            Text('Check-Out Date: ${DateFormat('yyyy-MM-dd').format(widget.checkOutDate)}'),
            Text('Number of Days: ${widget.numberOfDays}'),
            Text('Number of Adults: ${widget.numberOfAdults}'),
            Text('Number of Kids: ${widget.numberOfKids}'),
            const SizedBox(height: 20),
            const Text(
              'Selected Rooms:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('- ${widget.selectedRoom?['name'] ?? 'Unknown Room'} (${_formatCurrency(double.parse(widget.selectedRoom?['price'] ?? '0'))} per night)'),
            const SizedBox(height: 20),
            Text(
              'Total Cost: $formattedCost',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 20),

            // Additional notes TextField
            const Text(
              'Additional Notes:',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Enter any additional notes for your booking...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),

            // Payment Breakdown
            Text(
              'Down Payment (50%): ${_formatCurrency(downPayment)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Show payment options dialog
                  _showPaymentOptionsDialog(context);
                },
                child: const Text('Confirm Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
