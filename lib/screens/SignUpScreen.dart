
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_version/screens/SignInScreen.dart';
import 'package:first_version/screens/UserDetailsScreen.dart';
import 'package:flutter/material.dart';

import '../Models/UserProfile.dart';
import 'BusinessHiringScreen.dart';
// This is the create a Profile screen

class UserProfileFormScreen extends StatefulWidget {
  const UserProfileFormScreen({super.key});

  @override
  State<UserProfileFormScreen> createState() => _UserProfileFormScreenState();
}

class _UserProfileFormScreenState extends State<UserProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profile = UserProfile();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _desiredRoleCtrl = TextEditingController();
  final _yoeCtrl = TextEditingController(text: '0');
  final _bioCtrl = TextEditingController();
  final _companyNameCtrl = TextEditingController();
  final _companyAboutCtrl = TextEditingController();
  final _skillCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    for (final c in [
      _firstNameCtrl,
      _lastNameCtrl,
      _emailCtrl,
      _passwordCtrl,
      _phoneCtrl,
      _locationCtrl,
      _desiredRoleCtrl,
      _yoeCtrl,
      _bioCtrl,
      _companyNameCtrl,
      _companyAboutCtrl,
      _skillCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _addSkillChip() {
    final s = _skillCtrl.text.trim();
    if (s.isEmpty) return;
    if (!_profile.skills.contains(s)) setState(() => _profile.skills.add(s));
    _skillCtrl.clear();
  }

  void _removeSkill(String s) => setState(() => _profile.skills.remove(s));

  String? _emailValidator(String? v) {
    v = v?.trim() ?? '';
    if (v.isEmpty) return 'Required';
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v);
    return ok ? null : 'Invalid email';
  }


  Future<void> addUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String location,
    required String uid,
    required UserProfile profile,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'location': location,
        'accountType': profile.accountType,
        'bio': profile.bio,
        'desiredRole': profile.desiredRole,
        'workType': profile.workType,
        'yearsOfExperience': profile.yearsOfExperience,
        'skills': profile.skills,
        'companyName': profile.companyName,
        'companyAbout': profile.companyAbout,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ User added successfully!');
    } catch (e) {
      print('❌ Error adding user: $e');
      rethrow;
    }
  }


  Future<void> addUser2({
    required String firstName,
    required String email,
    required String lastName,
    required String password,
    required String phone,
    required String location,
    String? bio ,
    String? company ,
    String? companyBio,

  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').add({
        'firstName': firstName,
        'email': email,
        'lastName':lastName,
        'password':password,
        'phone':phone,
        'location':location,
        'bio':bio,
        'company':company,
        'companyName':companyBio,

        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ User added successfully!');
    } catch (e) {
      print('❌ Error adding user: $e');
    }
  }




  Future<void> _saveThenNavigate() async {
    if (!_formKey.currentState!.validate()) {
      _showSnack('Please fix the errors', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // // Create Firebase Auth user
      // final userCredential =
      // await FirebaseAuth.instance.createUserWithEmailAndPassword(
      //   email: _emailCtrl.text.trim(),
      //   password: _passwordCtrl.text.trim(),
      // );

      // Update profile with user data
      // _profile
      //   ..uid = userCredential.user!.uid
      //   ..firstName = _firstNameCtrl.text.trim()
      //   ..lastName = _lastNameCtrl.text.trim()
      //   ..email = _emailCtrl.text.trim()
      //   ..phone = _phoneCtrl.text.trim()
      //   ..location = _locationCtrl.text.trim()
      //   ..desiredRole = _desiredRoleCtrl.text.trim()
      //   ..yearsOfExperience = int.tryParse(_yoeCtrl.text.trim()) ?? 0
      //   ..bio = _bioCtrl.text.trim()
      //   ..companyName = _companyNameCtrl.text.trim()
      //   ..companyAbout = _companyAboutCtrl.text.trim();

      //Save to Firestore with user's actual data
      await addUser2(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),

      );

      if (!mounted) return;

      _showSnack('Account created successfully!');

      // Navigate to appropriate screen
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      if (_profile.accountType == 'candidate') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => SignInScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) => SignInScreen()),
        );
      }
    // } on FirebaseAuthException catch (e) {
    //   String message = 'Registration failed';
    //   if (e.code == 'weak-password') {
    //     message = 'Password is too weak';
    //   } else if (e.code == 'email-already-in-use') {
    //     message = 'An account already exists with this email';
    //   } else if (e.code == 'invalid-email') {
    //     message = 'Invalid email address';
    //   }
    //   _showSnack(message, isError: true);
     } catch (e) {
      _showSnack('Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: isError ? Colors.red[700] : Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Your Profile',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 28,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Let\'s get to know you better',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ],
        ),
        centerTitle: false,
        toolbarHeight: 80,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _accountTypeCard(),
              const SizedBox(height: 28),
              _basicInfoCard(),
              const SizedBox(height: 28),
              if (_profile.accountType == 'candidate') ...[
                _candidateInfoCard(),
                const SizedBox(height: 28),
                _skillsCard(),
              ] else ...[
                _businessInfoCard(),
              ],
              const SizedBox(height: 40),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _saveThenNavigate,
          borderRadius: BorderRadius.circular(20),
          child: _isLoading
              ? const Center(
            child: SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          )
              : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Create Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(width: 12),
              Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 26),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountTypeCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blue[50]!.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.person_outline,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              const Text(
                'I am a...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildAccountTypeOption(
                  'candidate',
                  'Job Seeker',
                  Icons.work_outline_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAccountTypeOption(
                  'business',
                  'Hiring Manager',
                  Icons.business_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTypeOption(String value, String label, IconData icon) {
    final isSelected = _profile.accountType == value;
    return GestureDetector(
      onTap: () => setState(() => _profile.accountType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [Colors.grey[50]!, Colors.grey[100]!],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.5)
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF667EEA).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 36,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _basicInfoCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.purple[50]!.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple[400]!, Colors.pink[400]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.badge_outlined,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              const Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                  child: _buildTextField(
                      _firstNameCtrl, 'First Name', Icons.person_outline)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildTextField(
                      _lastNameCtrl, 'Last Name', Icons.person_outline)),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(_emailCtrl, 'Email', Icons.email_outlined,
              validator: _emailValidator),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            validator: (v) => (v?.isEmpty ?? true)
                ? 'Required'
                : v!.length < 6
                ? 'Min 6 characters'
                : null,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(
                  color: Colors.grey[600], fontWeight: FontWeight.w500),
              prefixIcon: const Icon(Icons.lock_outline,
                  color: Color(0xFF667EEA), size: 22),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey[600],
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                const BorderSide(color: Color(0xFF667EEA), width: 2.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red[300]!, width: 1.5),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(_phoneCtrl, 'Phone', Icons.phone_outlined),
          const SizedBox(height: 20),
          _buildTextField(_locationCtrl, 'Location', Icons.location_on_outlined,
              hint: 'City, Country'),
          const SizedBox(height: 20),
          _buildTextField(_bioCtrl, 'Brief Bio', Icons.edit_note_rounded,
              maxLines: 3, hint: 'Tell us about yourself...'),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        String? hint,
        int maxLines = 1,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator ?? (v) => v!.trim().isEmpty ? 'Required' : null,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle:
        TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: const Color(0xFF667EEA), size: 22),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red[300]!, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red[400]!, width: 2.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  Widget _candidateInfoCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.green[50]!.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[400]!, Colors.teal[400]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.work_outline_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              const Text(
                'Job Preferences',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _buildTextField(_desiredRoleCtrl, 'Desired Role',
              Icons.assignment_outlined,
              hint: 'e.g., Flutter Developer'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  value: _profile.workType,
                  items: const ['Onsite', 'Hybrid', 'Remote'],
                  label: 'Work Type',
                  icon: Icons.place_outlined,
                  onChanged: (v) => setState(() => _profile.workType = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  _yoeCtrl,
                  'Years of Exp.',
                  Icons.timeline_outlined,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 0) return 'Invalid';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
        TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: const Color(0xFF667EEA), size: 22),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  Widget _skillsCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.orange[50]!.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[400]!, Colors.deepOrange[400]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.stars_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              const Text(
                'Skills',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skillCtrl,
                  onSubmitted: (_) => _addSkillChip(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Add a skill',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.lightbulb_outline,
                        color: Color(0xFF667EEA), size: 22),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                      BorderSide(color: Colors.grey[200]!, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFF667EEA), width: 2.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _addSkillChip,
                  icon: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _profile.skills.isEmpty
              ? Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.style_outlined,
                      size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'No skills added yet',
                    style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          )
              : Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
            _profile.skills.map((s) => _buildSkillChip(s)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _removeSkill(skill),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _businessInfoCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.indigo[50]!.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo[400]!, Colors.blue[400]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.business_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              const Text(
                'Company Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _buildTextField(
            _companyNameCtrl,
            'Company Name',
            Icons.domain,
            hint: 'e.g., Tech Solutions Inc.',
            validator: (v) => _profile.accountType == 'business' &&
                (v?.trim().isEmpty ?? true)
                ? 'Required'
                : null,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            _companyAboutCtrl,
            'About Your Company',
            Icons.info_outline,
            maxLines: 3,
            hint: 'Tell us about your company...',
            validator: (_) => null,
          ),
        ],
      ),
    );
  }
}