import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sophiered/guest_details_page.dart';

class GuestProfilePage extends StatelessWidget {
  final String fullName = 'Juan Dela Cruz';
  final String address = '123 Main Street, City, Country';
  final String phoneno = '09328148123';
  final String email = 'juandcruz@gmail.com';

  final List<Map<String, dynamic>> transactionHistory = [
    {
      'date': '2024-08-01',
      'description': 'Room Booking - Sea View Room',
      'amount': '3,000',
      'rating': 4.0,
      'comments': 'Great experience and comfortable to stay with state of the art designs!',
    },
    {
      'date': '2024-07-15',
      'description': 'Room Booking - Deluxe Room',
      'amount': '3,000',
      'rating': 3.0,
      'comments': 'Good, but could be better.',
    },
    {
      'date': '2024-06-30',
      'description': 'Room Booking - Family Suite',
      'amount': '5,800',
      'rating': 5.0,
      'comments': 'Perfect for our family!',
    },
  ];

  //const GuestProfilePage({super.key});

  void _showRatingDialog(BuildContext context, Map<String, dynamic> transaction) {
    double? rating = transaction['rating'];
    TextEditingController commentsController = TextEditingController(text: transaction['comments']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rate Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: rating ?? 0.0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (newRating) {
                  rating = newRating;
                },
              ),
              TextField(
                controller: commentsController,
                decoration: const InputDecoration(labelText: 'Comments'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Update the transaction with the new rating and comments
                transaction['rating'] = rating;
                transaction['comments'] = commentsController.text;

                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, Map<String, dynamic> transaction) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(transaction['description']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction['date']),
            const SizedBox(height: 4),
            if (transaction['rating'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RatingBarIndicator(
                    rating: transaction['rating'],
                    itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                    itemCount: 5,
                    itemSize: 20.0,
                  ),
                  const SizedBox(height: 4),
                  // Wrap the comments in a Container to apply constraints and overflow handling
                  Container(
                    constraints: const BoxConstraints(maxWidth: 200), // Adjust maxWidth as needed
                    child: Text(
                      transaction['comments'] ?? '',
                      style: TextStyle(color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2, // Adjust the number of lines to fit your design
                    ),
                  ),
                ],
              ),
          ],
        ),
        trailing: Column(
          children: [
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: () {
                _showRatingDialog(context, transaction);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Adjust padding for button size
                textStyle: const TextStyle(fontSize: 14), // Adjust font size for button text
              ),
              child: Text('Rate'),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Profile'),
        backgroundColor: Colors.white70,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Icon, Name, and Address
              Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/profile_icon.png'), // Replace with guest's profile image
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        email,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        address,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        phoneno,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Edit Profile Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Handle edit profile logic here
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GuestDetailsPage()),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Transaction History
              const Text(
                'Transaction History',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Divider(thickness: 1),
              ListView.builder(
                padding: const EdgeInsets.all(6.0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactionHistory.length,
                itemBuilder: (context, index) {
                  final transaction = transactionHistory[index];
                  return _buildTransactionItem(context, transaction);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
