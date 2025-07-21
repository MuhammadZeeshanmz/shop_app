import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop_app/Home_screen/home_screen.dart';
import 'package:shop_app/login/login_view.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool isPasswordVisible = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        _showSnackBar("Passwords do not match");
        return;
      }

      setState(() => isLoading = true);

      try {
        final UserCredential userCredential = await auth
            .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );

        await firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'createdAt': Timestamp.now(),
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } on FirebaseAuthException catch (e) {
        _showSnackBar(e.message ?? "Signup failed");
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.2),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 196, 152, 136),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Join us to get started",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 24),

                    // Name
                    TextFormField(
                      controller: nameController,
                      validator:
                          (value) => value!.isEmpty ? "Enter name" : null,
                      decoration: _inputDecoration(
                        "Name",
                        Icons.person_outline,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: emailController,
                      validator:
                          (value) => value!.isEmpty ? "Enter email" : null,
                      decoration: _inputDecoration(
                        "Email",
                        Icons.email_outlined,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      validator:
                          (value) =>
                              value!.length < 6 ? "Password too short" : null,
                      decoration: _inputDecoration(
                        "Password",
                        Icons.lock_outline,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Confirm Password
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      validator:
                          (value) =>
                              value!.isEmpty ? "Confirm your password" : null,
                      decoration: _inputDecoration(
                        "Confirm Password",
                        Icons.lock_outline,
                      ),
                    ),
                    SizedBox(height: 24),

                    // Sign Up Button
                    isLoading
                        ? CircularProgressIndicator(
                          color: Color.fromARGB(255, 196, 152, 136),
                        )
                        : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              196,
                              152,
                              136,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: handleSignUp,
                          child: Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),

                    SizedBox(height: 12),

                    // Login Redirect
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      },
                      child: Text(
                        "Already have an account? Login",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 196, 152, 136),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
