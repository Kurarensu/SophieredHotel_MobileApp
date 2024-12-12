import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class FeedbackPage extends StatefulWidget {
  final List<Map<String, String>> selectedRooms;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfDays;
  final int numberOfGuests;
  final double totalCost;

  const FeedbackPage({super.key, 
    required this.selectedRooms,
    required this.totalCost,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    required this.numberOfDays,
  });

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: ' ', decimalDigits: 0);
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reservation Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Check-In Date: ${DateFormat('yyyy-MM-dd').format(widget.checkInDate)}'),
                Text('Check-Out Date: ${DateFormat('yyyy-MM-dd').format(widget.checkOutDate)}'),
                Text('Number of Days: ${widget.numberOfDays}'),
                Text('Number of Guests: ${widget.numberOfGuests}'),
                const SizedBox(height: 20),
                const Text(
                  'Selected Rooms:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...widget.selectedRooms.map((room) {
                  return ListTile(
                    leading: room['image'] != null
                        ? Image.asset(
                      'assets/${room['image']}',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                        : const Icon(Icons.image, size: 80),
                    title: Text(room['name']!),
                    subtitle: Text('${_formatCurrency(double.parse(room['price']!))} per night'),
                  );
                }),
                const SizedBox(height: 20),
                Text(
                  'Total Cost: ${_formatCurrency(widget.totalCost)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Rate Your Experience',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  itemSize: 40,
                  itemBuilder: (context, index) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Leave a Comment',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a comment';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final feedback = {
                        'rating': _rating,
                        'comment': _commentController.text,
                        'rooms': widget.selectedRooms,
                        'totalCost': widget.totalCost,
                      };

                      // Process feedback here (e.g., send to a server or store locally)
                      print('Feedback: $feedback');

                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Thank You!'),
                            content: const Text('Your feedback has been submitted.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop(); // Navigate back to the previous screen
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: const Text('Submit Feedback'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
