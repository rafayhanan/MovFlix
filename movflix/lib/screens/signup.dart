import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  SignupState createState() => SignupState();
}

class SignupState extends State<Signup> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;

  late FirebaseAuth firebaseAuth;

  @override
  void initState() {
    super.initState();
    firebaseAuth = FirebaseAuth.instance;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void signUp(String email, String password) async {
    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred";
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Please enter a valid email address.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.red.shade900,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo and Title
                    Icon(
                      Icons.movie,
                      size: 80,
                      color: Colors.red.shade100,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'MOVFLIX',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Signup Form
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: emailController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Email",
                              labelStyle: TextStyle(color: Colors.red.shade100),
                              prefixIcon: Icon(Icons.email, color: Colors.red.shade100),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.red.shade100),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: passwordController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle: TextStyle(color: Colors.red.shade100),
                              prefixIcon: Icon(Icons.lock, color: Colors.red.shade100),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.red.shade100),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: confirmPasswordController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              labelStyle: TextStyle(color: Colors.red.shade100),
                              prefixIcon: Icon(Icons.lock_outline, color: Colors.red.shade100),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.red.shade100),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(color: Colors.white),
                              ),
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                final email = emailController.text.trim();
                                final password = passwordController.text.trim();
                                final confirmPassword = confirmPasswordController.text.trim();

                                if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Please fill in all fields."),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } else if (password != confirmPassword) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Passwords do not match."),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } else {
                                  signUp(email, password);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade900,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                "SIGN UP",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Already have an account? Login",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red.shade100,
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
}