// Relevant imports here
import 'package:flutter/material.dart';
import 'package:sophiered/SplashScreen.dart';
import 'home.dart';
import 'dart:convert'; // For encoding JSON
import 'package:http/http.dart' as http;

class CreateAccountPage extends StatefulWidget {
  final String? token;

  const CreateAccountPage({Key? key, this.token}) : super(key: key);

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _selectedGender = 'Male';
  int _selectedRole = 4; // Default role


  Future<void> _registerUser() async {
    const String apiUrl = 'http://161.35.97.230/api/register'; // Update with your API endpoint

    final Map<String, dynamic> requestData = {
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'address': _addressController.text,
      'phone_number': _phoneController.text,
      'gender': _selectedGender,
      'email': _emailController.text,
      'password': _passwordController.text,
      'role': _selectedRole,
    };

    // Print the requestData to the console
    print('Request Data: ${jsonEncode(requestData)}'); // Encodes as JSON for better readability


    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {

        final data = json.decode(response.body);

          // Navigate to the home page or show success message
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Your account has been created successfully.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(), // Replace with your login page
                        ),
                      );
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );


      } else {
        _showErrorMessage('Failed to register. Please try again.');
      }
    } catch (error) {
      _showErrorMessage('Error: $error');
    }
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
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
              child: SingleChildScrollView(
                child: Column(
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // First Name
                            _buildTextField(
                              controller: _firstNameController,
                              labelText: 'First Name',
                              prefixIcon: Icons.person,
                            ),
                            const SizedBox(height: 16),
                            // Last Name
                            _buildTextField(
                              controller: _lastNameController,
                              labelText: 'Last Name',
                              prefixIcon: Icons.person,
                            ),
                            const SizedBox(height: 16),
                            // Phone Number
                            _buildTextField(
                              controller: _phoneController,
                              labelText: 'Phone No.',
                              prefixIcon: Icons.phone,
                            ),
                            const SizedBox(height: 16),
                            // Gender Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: InputDecoration(
                                labelText: 'Gender',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              items: ['Male', 'Female']
                                  .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ))
                                  .toList(),
                              onChanged: (value) => setState(() => _selectedGender = value!),
                            ),
                            const SizedBox(height: 16),
                            // Address
                            _buildTextField(
                              controller: _addressController,
                              labelText: 'Address',
                              prefixIcon: Icons.home,
                            ),
                            const SizedBox(height: 16),
                            // Email
                            _buildTextField(
                              controller: _emailController,
                              labelText: 'Email',
                              prefixIcon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            // Password
                            _buildTextField(
                              controller: _passwordController,
                              labelText: 'Password',
                              prefixIcon: Icons.lock,
                              obscureText: true,
                            ),
                            const SizedBox(height: 32),
                            // Sign Up Button
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // Handle sign-up logic here
                                  _registerUser();
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
                                'SIGN UP',
                                style: TextStyle(fontSize: 18, color: Colors.white),
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
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.grey[100],
        filled: true,
        prefixIcon: Icon(prefixIcon),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText.toLowerCase()';
        }
        return null;
      },
    );
  }
}
