import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_version/Utils/Utils.dart';
import 'package:first_version/screens/JobsFiltersScreen.dart';
import 'package:first_version/screens/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:first_version/screens/UserDetailsScreen.dart';
import 'package:first_version/screens/RootTabs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/UserProfile.dart';
import 'SignUpScreen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  String _accountType = 'candidate'; // 'candidate' or 'business'

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }


  checkConnection(context) async {
    try { final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty)
    {
// print('connected to internet');
// print(result);
// return 1;
    }
    }
    on SocketException catch (_) {
// print('not connected to internet');
// print(result);
      showTextDialog(context, "אין אינטרנט", "האפליקציה דורשת חיבור לאינטרנט, נא להתחבר בבקשה");
      return;
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      if (!mounted) return;
      setState(() => _isLoading = true);

      // Simulate API call
      await Future.delayed(Duration(seconds: 2));
      try {
        // Query Firestore for a user with matching email and password
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: _emailCtrl.text.trim())
            .where('password', isEqualTo: _passwordCtrl.text.trim())
            .get();

        setState(() {
          _isLoading = false;
        });
        if (querySnapshot.docs.isNotEmpty) {
          // User found
          final userDoc = querySnapshot.docs.first;
          final userId = userDoc.id;
          final userData = userDoc.data();

          // Here you would handle the actual login logic
          print('Email: ${_emailCtrl.text}');
          print('Password: ${_passwordCtrl.text}');
          // Save user info locally
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('myUserID', userId);
          await prefs.setString('myEmail', _emailCtrl.text.trim());
          await prefs.setString('myPassword', _passwordCtrl.text.trim());

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('התחברת בהצלחה!'),
              backgroundColor: Colors.green,
            ),
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('התחברת בהצלחה!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to main screen
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
          // Navigate to main screen and clear login route

          var bb = new UserProfile();
          bb.accountType == 'candidate';


          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => RootTabs(profile: bb,)),
                (route) => false,
          );

          print('Welcome ${userData['name'] ?? 'User'}');
        } else {
          // No user found with matching email and password
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid email or password!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        print('Error logging in: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }




  // Future<void> _signIn() async {
  //   if (!_formKey.currentState!.validate()) return;
  //   setState(() => _isLoading = true);
  //   await Future.delayed(const Duration(milliseconds: 600));
  //   if (!mounted) return;
  //   setState(() => _isLoading = false);
  //
  //   // Minimal profile to start the flow
  //   final profile = UserProfile(accountType: _accountType);
  //
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (_) => RootTabs(profile: profile)), 
  //   );
  // }

  void _goToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserProfileFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    checkConnection(context);

    // Explicitly using the Blue color to match SignUpScreen
    const primaryColor = Color(0xFF1E88E5);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, title: const Text('')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: primaryColor.withOpacity(.12),
                      child: const Icon(Icons.work, color: primaryColor, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Blue & white theme • Sign in to continue',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('I am a', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'candidate', label: Text('Job Seeker'), icon: Icon(Icons.person)),
                    ButtonSegment(value: 'business', label: Text('Hiring Manager'), icon: Icon(Icons.business)),
                  ],
                  selected: {_accountType},
                  onSelectionChanged: (s) => setState(() => _accountType = s.first),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return primaryColor.withOpacity(0.2); // Light blue background when selected
                        }
                        return null; // Use the component's default.
                      },
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return primaryColor; // Blue text/icon when selected
                        }
                        return Colors.black87;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 1,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'you@example.com',
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor, width: 2)),
                              prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                                (v == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v))
                                    ? 'Enter a valid email'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor, width: 2)),
                              prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                            ),
                            obscureText: true,
                            validator: (v) => (v == null || v.length < 6)
                                ? 'Min 6 characters'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _login,
                              style: FilledButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _goToSignUp,
                  style: TextButton.styleFrom(foregroundColor: primaryColor),
                  child: const Text('New here? Create an account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


