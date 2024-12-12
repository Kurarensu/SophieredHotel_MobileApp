import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'create_account_page.dart'; // Import the create account page
import 'forgot_password_page.dart'; // Import the forgot password page
import 'dart:convert';  // For JSON encoding and decoding
import 'package:http/http.dart' as http;  // For making HTTP requests
import 'package:shared_preferences/shared_preferences.dart';



class IntroductionScreen extends StatefulWidget {
  final String? message;

  const IntroductionScreen({Key? key, this.message}) : super(key: key);


  @override
  _IntroductionScreenState createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {

  @override
  void initState() {
    super.initState();
    //checkConnection();  // Call the connection test function
    // Show the SnackBar if there's a message
    if (widget.message != null) {
      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.message!),
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
  }

  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> checkConnection() async {
    final url = Uri.parse('http://161.35.97.230/test-connection');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parse the response
        final data = json.decode(response.body);
        print('Response from server: ${data['message']}');
      } else {
        print('Failed to connect. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  List<Map<String, String>> introData = [
    {
      "title": "Our Facilities",
      "description": "We offer top-notch facilities including a Wifi Area, Carpark, and more.",
      "image": "assets/facilities.png", // Add your image here
    },
    {
      "title": "Our Services",
      "description": "Enjoy premium services like 24/7 room service, free WiFi, and airport shuttle.",
      "image": "assets/services.png", // Add your image here
    },
    {
      "title": "Welcome",
      "description": "Experience luxury and comfort with us. Book now and enjoy a memorable stay.",
      "image": "assets/hero_4.jpg", // Add your image here
    }
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: introData.length,
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center, // Centers content vertically
                children: [
                  IntroContent(
                    title: introData[index]["title"]!,
                    description: introData[index]["description"]!,
                    image: introData[index]["image"]!,
                  ),
                  const SizedBox(height: 30),
                  _currentPage == introData.length - 1
                      ? ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(), // Replace with your login page
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text("Login", style: TextStyle(fontSize: 18)),
                  )
                      : ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text("Next", style: TextStyle(fontSize: 18)),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                introData.length,
                    (index) => buildDot(index, context),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // Dot indicator for pages
  Widget buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 5),
      height: 10,
      width: _currentPage == index ? 20 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blueAccent : Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class IntroContent extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  const IntroContent({
    super.key,
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          image,
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 30),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}


class LoginScreen extends StatelessWidget {
  //const LoginScreen({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // Change _isPasswordVisible to a ValueNotifier<bool> initialized to false
  final ValueNotifier<bool> _isPasswordVisible = ValueNotifier(false);

  Future<http.Response> getUserData(String token) {
    return http.get(
      Uri.parse('http://161.35.97.230/api/user'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<bool> login(String email, String password, BuildContext context) async {
    // Replace with your Laravel backend URL
    final url = Uri.parse('http://161.35.97.230/api/login');

    try {
      // Send a POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,  // Send email and password to the server
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // If the login is successful, you will get a token
        final data = json.decode(response.body);
        String token = data['token'];
        await storeToken(token);


        // Save token for future authenticated requests (use shared_preferences or other method)
        print('Login successful. Token: $token');
        getUserData(token);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(token: token),
          ),
        );
        return true;

      } else {
        // If the login fails, handle the error
        print('Login failed. Status code: ${response.statusCode}');
        return false;
        //print('Error: ${response.body}');
      }
    } catch (e) {
      print('Error during login: $e');
      return false;
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 300,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/hero_4.jpg'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            hintText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        ValueListenableBuilder<bool>(
                          valueListenable: _isPasswordVisible,
                          builder: (context, isPasswordVisible, child) {
                            return TextField(
                              controller: passwordController,
                              obscureText: !isPasswordVisible,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[100],
                                hintText: 'Password',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    _isPasswordVisible.value = !_isPasswordVisible.value;
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgotPasswordPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            bool success = await login(emailController.text, passwordController.text, context);
                            if (success) {
                              // If login is successful, navigate to DashboardPage with the token
                              final token = await getToken(); // Retrieve the token after login
                              if (token != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DashboardPage(token: token),
                                  ),
                                );
                              }
                            } else {
                              // If login fails, show error dialog
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Login Failed"),
                                    content: const Text("Please check your credentials and try again."),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.orangeAccent,
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateAccountPage(),
                        ),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: "Sign up",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
