import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class DashboardPage extends StatefulWidget {
  final String? token;

  const DashboardPage({Key? key, required this.token}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  //final List<Map<String, String>> rooms = []; // Initially empty list

  String? token;


  @override
  void initState() {
    super.initState();
    _loadToken();
    //fetchRooms(); // Fetch data when the screen is loaded
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token'); // Replace 'authToken' with your key
    });
    print('Token: $token');
  }



  final List<Map<String, String>> rooms = [
    {'image': 'assets/seaview.jpg', 'name': 'Sea View Room'},
    {'image': 'assets/deluxe.jpg', 'name': 'Deluxe Room'},
    {'image': 'assets/juniorsuite.jpg', 'name': 'Junior Suite'},
    {'image': 'assets/family.jpg', 'name': 'Family Room'},
    {'image': 'assets/presidentialsuite.jpg', 'name': 'Presidential Suite'},
    {'image': 'assets/watervilla2.jpg', 'name': 'Water Villa'},
  ];

  final List<Map<String, dynamic>> facilities = [
    {'icon': Icons.restaurant, 'label': 'All-day Dining'},
    {'icon': Icons.local_parking, 'label': 'Carpark'},
    {'icon': Icons.wifi, 'label': 'Wifi Area'},
    {'icon': Icons.meeting_room, 'label': 'Meeting Room'},
    {'icon': Icons.smoke_free, 'label': 'Non Smoking Room'},
    {'icon': Icons.lock, 'label': 'In-Room Safe'},
    {'icon': Icons.accessibility, 'label': 'WheelChair Access'},
  ];

  final List<Map<String, dynamic>> services = [
    {'icon': Icons.room_service, 'label': 'In Room Dining'},
    {'icon': Icons.access_alarm, 'label': '24 Hour Front Desk'},
    {'icon': Icons.security, 'label': '24 Hour Security'},
    {'icon': Icons.airplanemode_active, 'label': 'Airport Transfer'},
    {'icon': Icons.local_laundry_service, 'label': 'Laundry Service'},
    {'icon': Icons.add_card, 'label': 'Bellboy Service'},
    {'icon': Icons.luggage, 'label': 'Luggage Storage'},
  ];

  //const DashboardPage({super.key});


  Widget _buildListItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, size: 40, color: Colors.blueAccent),
      title: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar removed to hide it completely
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add padding of 50px from the top
            const Padding(
              padding: EdgeInsets.only(top: 50.0, left: 8.0, right: 8.0),
              child: Text('Rooms', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 250,
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 250,
                  autoPlay: true,
                  aspectRatio: 16 / 9,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: true,
                  viewportFraction: 0.8,
                ),
                items: rooms.map((room) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.asset(room['image']!, fit: BoxFit.cover),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            color: Colors.black54,
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              room['name']!,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Facilities
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Facilities', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            ListView.builder(
              padding: const EdgeInsets.all(8.0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: facilities.length,
              itemBuilder: (context, index) {
                final facility = facilities[index];
                return _buildListItem(facility['icon'], facility['label']);
              },
            ),
            const SizedBox(height: 20),

            // Services
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Services', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            ListView.builder(
              padding: const EdgeInsets.all(8.0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return _buildListItem(service['icon'], service['label']);
              },
            ),
            const SizedBox(height: 20),

            // Book Now Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the SecondPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClientHomePage(token: token), // Pass the token here
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.amber,
                ),
                child: Text('Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
