import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for number formatting
import 'package:sophiered/GuestProfilePage.dart';
import 'package:sophiered/SplashScreen.dart';
import 'guest_details_page.dart';
import 'book_page.dart';
import 'dashboard.dart';
import 'package:sophiered/GuestProfilePage.dart';
import 'package:sophiered/ConfirmedBookingsPage.dart';
import 'package:http/http.dart' as http;  // For making HTTP requests
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';



class ClientHomePage extends StatefulWidget {
  final String? token;

  const ClientHomePage({Key? key, this.token}) : super(key: key);

  @override
  _ClientHomePageState createState() => _ClientHomePageState();
}

class Room {
  final int id;
  final String roomNumber;
  final String roomType;
  final String description;
  final String pricePerNight;
  final String status;
  final String image;
  final String createdAt;
  final String updatedAt;

  Room({
    required this.id,
    required this.roomNumber,
    required this.roomType,
    required this.description,
    required this.pricePerNight,
    required this.status,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as int,
      roomNumber: json['room_number'] as String,
      roomType: json['room_type'] as String,
      description: json['description'] ?? '', // Default to empty string if null
      pricePerNight: json['price_per_night'] as String,
      status: json['status'] as String,
      image: json['image'] ?? '', // Default to empty string if null
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}


class RoomService {
  static Future<List<Room>> fetchRooms({
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required String token,  // Accept token as a parameter
  }) async {
    final String formattedCheckInDate = DateFormat('yyyy-MM-dd').format(checkInDate);
    final String formattedCheckOutDate = DateFormat('yyyy-MM-dd').format(checkOutDate);

    final String apiUrl =
        'http://161.35.97.230/api/availablerooms?checkInDate=$formattedCheckInDate&checkOutDate=$formattedCheckOutDate';


    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token', // Include the token
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      //print('Response status: ${response.statusCode}');
      //print('Response body: ${response.body}');

      if (response.statusCode == 200) {

          final List<dynamic> data = json.decode(response.body);
          //print('Parsed data: $data');
          return data.map((room) => Room.fromJson(room)).toList();

      } else {
        print('Error response status: ${response.statusCode}');
        print('Error response body: ${response.body}');
        throw Exception('Failed to load rooms: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}


class _ClientHomePageState extends State<ClientHomePage> {
  // API URL for logging out
  final String apiUrl = 'http://161.35.97.230/api/logout';
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  Map<String, String>? _selectedRoom; // Change to a single room
  int numberOfDays = 0;
  String firstName = '';
  String lastName = '';
  String email = '';
  int userId = 0;
  bool isLoading = true; // For showing a loader while fetching data

  String _promoCode = '';
  int _numberOfAdults = 1;
  int _numberOfKids = 0;

  int numberOfAdults = 0;
  int numberOfKids = 0;

  String? token;

  @override
  void initState() {
    super.initState();
    _loadToken();
    handleUserDetails();
  }

  List<Room> _rooms = [];
  bool _isLoading = false;

  Future<void> _fetchRooms() async {
    if (_checkInDate != null && _checkOutDate != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        final rooms = await RoomService.fetchRooms(
          checkInDate: _checkInDate!,
          checkOutDate: _checkOutDate!,
          token: token!,
        );
        setState(() {
          _rooms = rooms;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load rooms')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token'); // Replace 'authToken' with your key
    });
    print('Token: $token');
  }

  Future<void> handleUserDetails() async {
    if (token == null) {
      await _loadToken();
    }

    if (token == null) {
      print('Error: Token is still null after loading.');
      return; // Exit if token is not available
    }

    const String apiUrl = 'http://161.35.97.230/api/user-details';

    try {
      print('Sending request to: $apiUrl');
      print('Using token: $token');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Handling 200 response...');
        final data = json.decode(response.body);
        setState(() {
          firstName = data['first_name'];
          lastName = data['last_name'];
          email = data['email'];
          userId = data['id'];
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        print('Handling 401 Unauthorized...');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => IntroductionScreen(message: 'Unauthorized Access!'),
          ),
        );
      } else {
        print('Unhandled error status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }


  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: _checkInDate ?? DateTime.now(),
        end: _checkOutDate ?? DateTime.now().add(const Duration(days: 1)),
      ),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDateRange != null) {
      setState(() {
        _checkInDate = pickedDateRange.start;
        _checkOutDate = pickedDateRange.end;
      });
      _fetchRooms();
    }
  }

  // Method to store token
  Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);  // Save token
  }

  // Method to get the token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');  // Retrieve token
  }

  // Method to remove the token from SharedPreferences
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');  // Remove the token
  }

  // Method to handle logout
  Future<void> logout(BuildContext context) async {
    String? token = await getToken();

    if (token != null) {
      // Send token to backend to delete it from the database
      print('Token: $token');
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $token', // Include the token
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          // If logout is successful, remove the token from local storage
          await removeToken();
          print('Logged out successfully');

          // Navigate to IntroductionScreen and pass a success message
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => IntroductionScreen(message: 'Logout successful!'),
            ),
          );



        } else {
          print('Failed to log out');
        }
      } catch (e) {
        print('Error during logout: $e');
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not selected';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  int _calculateDaysBetween(DateTime? checkIn, DateTime? checkOut) {
    if (checkIn != null && checkOut != null) {
      return checkOut.difference(checkIn).inDays;
    }
    return 0;
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: ' ', decimalDigits: 0);
    return formatter.format(value);
  }

  double _calculateTotalCost(Map<String, String>? selectedRoom, int days) {
    if (selectedRoom == null) return 0;
    return double.parse(selectedRoom['price']!) * days;
  }

  void _incrementAdults() {
    setState(() {
      _numberOfAdults++;
    });
  }

  void _decrementAdults() {
    setState(() {
      if (_numberOfAdults > 1) _numberOfAdults--;
    });
  }

  void _incrementKids() {
    setState(() {
      _numberOfKids++;
    });
  }

  void _decrementKids() {
    setState(() {
      if (_numberOfKids > 0) _numberOfKids--;
    });
  }

  @override
  Widget build(BuildContext context) {
    numberOfDays = _calculateDaysBetween(_checkInDate, _checkOutDate);
    double totalCost = _calculateTotalCost(_selectedRoom, numberOfDays);
    String formattedCost = _formatCurrency(totalCost);
    int? _selectedRoomIndex;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sophie Red Hotel'),
        backgroundColor: Colors.white70,
        automaticallyImplyLeading: false, // Hides the left arrow (back button)
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert), // Displays three vertical dots
            onSelected: (String result) {
              switch (result) {
                case 'Dashboard':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardPage(token: token), // Pass the token here
                    ),
                  );
                  break;
                case 'Profile':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GuestProfilePage(), // Replace with your ProfilePage widget
                    ),
                  );
                case 'Transaction':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionHistoryPage(token: token), // Replace with your ProfilePage widget
                    ),
                  );
                  break;
                case 'Logout':
                  logout(context); // Call the logout function
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Dashboard',
                child: Text('Dashboard'),
              ),
              const PopupMenuItem<String>(
                value: 'Profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'Transaction',
                child: Text('Transaction'),
              ),
              const PopupMenuItem<String>(
                value: 'Logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                // Welcome label with client's full name
                Text(
                  'Welcome, $lastName',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _selectDateRange(context),
                  child: Text(
                    _checkInDate != null && _checkOutDate != null
                        ? 'Check-In: ${_formatDate(_checkInDate)} | Check-Out: ${_formatDate(_checkOutDate)}'
                        : 'Select Check-In & Check-Out Dates',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Number of Adults'),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _decrementAdults,
                                icon: const Icon(Icons.remove),
                              ),
                              Text(
                                '$_numberOfAdults',
                                style: const TextStyle(fontSize: 20),
                              ),
                              IconButton(
                                onPressed: _incrementAdults,
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Number of Kids'),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _decrementKids,
                                icon: const Icon(Icons.remove),
                              ),
                              Text(
                                '$_numberOfKids',
                                style: const TextStyle(fontSize: 20),
                              ),
                              IconButton(
                                onPressed: _incrementKids,
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_selectedRoom != null)
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_checkInDate != null && _checkOutDate != null && _selectedRoom != null) {
                          String? _token = await getToken();
                          print('UserID: $userId');
                          print('RoomID: $_selectedRoom');// Await token retrieval
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookPage(
                                selectedRoom: _selectedRoom,
                                checkInDate: _checkInDate!,
                                checkOutDate: _checkOutDate!,
                                numberOfDays: numberOfDays,
                                totalCost: totalCost,
                                numberOfAdults: _numberOfAdults,
                                numberOfKids: _numberOfKids,
                                userId: userId,
                                token: _token,
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Book Now'),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                final room = _rooms[index];
                String formattedPrice = _formatCurrency(double.parse(room.pricePerNight!));
                bool isSelected = _selectedRoomIndex == index; // Track selected room by index

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_selectedRoomIndex == index) {
                          _selectedRoomIndex = null;  // Deselect the room
                          _selectedRoom = null;
                        } else {
                          _selectedRoomIndex = index;  // Select the room
                          _selectedRoom = {
                            'id': room.id.toString(),
                            'name': room.roomNumber,
                            'price': room.pricePerNight,
                            'image': room.image,
                          };
                        }
                      });
                    },
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/${room.image}',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      title: Text(
                        room.roomNumber,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '$formattedPrice per night',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      trailing: Icon(
                        _selectedRoomIndex == index ? Icons.check_box : Icons.check_box_outline_blank,
                        color: _selectedRoomIndex == index ? Colors.green : null,
                      ),
                    ),
                  ),
                );


              },
            ),
          ),
        ],
      ),
    );
  }
}
