import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Models/UserProfile.dart';
import '../Models/application.dart';
import '../Models/job.dart';
import '../Models/jobs_store.dart';
import '../theme/app_theme.dart';
import 'ChatScreen.dart';
import 'LoginScreen.dart';

class BusinessHiringScreen extends StatefulWidget {
  final UserProfile profile;
  const BusinessHiringScreen({super.key, required this.profile});

  @override
  State<BusinessHiringScreen> createState() => _BusinessHiringScreenState();
}

class _BusinessHiringScreenState extends State<BusinessHiringScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  String _workType = 'Full-Time';
  final List<String> _requiredSkills = [];
  bool _isPosting = false;

  @override
  void dispose() {
    _jobTitleCtrl.dispose();
    _descriptionCtrl.dispose();
    _locationCtrl.dispose();
    _skillsCtrl.dispose();
    super.dispose();
  }

  void _addSkill() {
    final s = _skillsCtrl.text.trim();
    if (s.isEmpty) return;
    if (!_requiredSkills.contains(s)) setState(() => _requiredSkills.add(s));
    _skillsCtrl.clear();
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPosting = true);

    final user = FirebaseAuth.instance.currentUser;
    final job = Job(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _jobTitleCtrl.text.trim(),
      company: widget.profile.companyName.isEmpty
          ? 'My Company'
          : widget.profile.companyName,
      location: _locationCtrl.text.trim().isEmpty
          ? 'Not specified'
          : _locationCtrl.text.trim(),
      workType: _workType,
      description: _descriptionCtrl.text.trim(),
      skills: List.from(_requiredSkills),
      employerId: user?.uid ?? '',
      employerName: widget.profile.firstName.isEmpty
          ? widget.profile.companyName
          : '${widget.profile.firstName} ${widget.profile.lastName}',
    );

    await JobsStore.instance.addJob(job);

    _jobTitleCtrl.clear();
    _descriptionCtrl.clear();
    _locationCtrl.clear();
    _skillsCtrl.clear();
    setState(() {
      _requiredSkills.clear();
      _isPosting = false;
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ "${job.title}" posted successfully!'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          p.companyName.isEmpty ? 'Post a Job' : p.companyName,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: JobsStore.instance,
        builder: (context, _) {
          final myJobs = JobsStore.instance.jobs
              .where((j) =>
                  j.company ==
                  (p.companyName.isEmpty ? 'My Company' : p.companyName))
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Post a Job form ──────────────────────────────────────────
                _buildFormCard(),

                // ── My Posted Jobs ───────────────────────────────────────────
                if (myJobs.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.list_alt_rounded,
                            color: Colors.blue[700], size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'My Posted Jobs',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${myJobs.length} job${myJobs.length == 1 ? '' : 's'}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...myJobs.map((j) => _buildPostedJobCard(j)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormCard() {
    return Form(
      key: _formKey,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[50]!.withOpacity(0.4)],
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)], // Blue gradient
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E88E5).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.post_add_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Post a Job',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Visible to all job seekers',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Job Title
            _buildField(
              controller: _jobTitleCtrl,
              label: 'Job Title',
              hint: 'e.g. Flutter Developer',
              icon: Icons.badge_outlined,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Location
            _buildField(
              controller: _locationCtrl,
              label: 'Location',
              hint: 'e.g. Dubai, UAE',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),

            // Work Type
            DropdownButtonFormField<String>(
              value: _workType,
              items: const [
                DropdownMenuItem(value: 'Full-Time', child: Text('Full-Time')),
                DropdownMenuItem(value: 'Part-Time', child: Text('Part-Time')),
                DropdownMenuItem(value: 'Contract', child: Text('Contract')),
                DropdownMenuItem(value: 'Onsite', child: Text('Onsite')),
                DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                DropdownMenuItem(value: 'Remote', child: Text('Remote')),
              ],
              onChanged: (v) => setState(() => _workType = v!),
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87),
              decoration: _inputDecoration('Work Type', Icons.work_outline),
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionCtrl,
              maxLines: 4,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              decoration: _inputDecoration(
                      'Job Description', Icons.description_outlined)
                  .copyWith(
                hintText: 'Describe the role, responsibilities…',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.description_outlined,
                      color: Color(0xFF1E88E5), size: 22),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Skills
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillsCtrl,
                    onSubmitted: (_) => _addSkill(),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500),
                    decoration:
                        _inputDecoration('Add a skill', Icons.lightbulb_outline)
                            .copyWith(hintText: 'e.g. Flutter'),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _addSkill,
                  child: Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)], // Blue gradient
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 26),
                  ),
                ),
              ],
            ),

            if (_requiredSkills.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _requiredSkills
                    .map(
                      (s) => Chip(
                        label: Text(s,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        backgroundColor: const Color(0xFF1E88E5),
                        deleteIconColor: Colors.white70,
                        onDeleted: () =>
                            setState(() => _requiredSkills.remove(s)),
                      ),
                    )
                    .toList(),
              ),
            ],

            const SizedBox(height: 24),

            // Post button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isPosting ? null : _submitJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ).copyWith(
                  backgroundColor:
                      WidgetStateProperty.all(Colors.transparent),
                ),
                icon: const SizedBox.shrink(),
                label: const SizedBox.shrink(),
              ).copyWith(
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isPosting
                          ? [Colors.grey.shade400, Colors.grey.shade400]
                          : const [Color(0xFF1E88E5), Color(0xFF42A5F5)], // Blue gradient
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E88E5).withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: _isPosting ? null : _submitJob,
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: _isPosting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white)),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.publish_rounded,
                                    color: Colors.white, size: 22),
                                SizedBox(width: 10),
                                Text(
                                  'Post Job',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostedJobCard(Job j) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showJobApplicants(j),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        j.title.isNotEmpty ? j.title[0].toUpperCase() : '?',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(j.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(
                          '${j.location} · ${j.workType}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('applications')
                        .where('jobId', isEqualTo: j.id)
                        .snapshots(),
                    builder: (context, snap) {
                      final count = snap.data?.docs.length ?? 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: count > 0 ? Colors.blue[50] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count applicant${count == 1 ? '' : 's'}',
                          style: TextStyle(
                            color: count > 0 ? Colors.blue[700] : Colors.grey[500],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showJobApplicants(Job job) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, controller) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Applicants for ${job.title}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  job.company,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('applications')
                        .where('jobId', isEqualTo: job.id)
                        .snapshots(),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                              const SizedBox(height: 12),
                              Text('Could not load applicants',
                                  style: TextStyle(color: Colors.red[400], fontSize: 16)),
                            ],
                          ),
                        );
                      }
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final apps = snap.data?.docs ?? [];
                      if (apps.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_off_rounded,
                                  size: 48, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Text('No applicants yet',
                                  style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                            ],
                          ),
                        );
                      }
                      final sorted = apps.toList()..sort((a, b) {
                        final aTime = (a.data() as Map<String, dynamic>)['appliedAt'] ?? '';
                        final bTime = (b.data() as Map<String, dynamic>)['appliedAt'] ?? '';
                        return bTime.toString().compareTo(aTime.toString());
                      });
                      return ListView.separated(
                        controller: controller,
                        itemCount: sorted.length,
                        separatorBuilder: (_, __) => const Divider(height: 16),
                        itemBuilder: (_, i) {
                          final data = sorted[i].data() as Map<String, dynamic>;
                          final app = Application.fromJson(data, sorted[i].id);
                          return _buildApplicantTile(app, job);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildApplicantTile(Application app, Job job) {
    Color statusColor;
    switch (app.status) {
      case 'Accepted':
        statusColor = Colors.green;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        break;
      case 'Reviewed':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue[100],
                child: Text(
                  app.applicantName.isNotEmpty
                      ? app.applicantName[0].toUpperCase()
                      : '?',
                  style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.applicantName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(app.applicantEmail,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  app.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              if (app.status == 'Pending') ...[
                _smallButton('Accept', Colors.green, () => _updateAppStatus(app.id, 'Accepted')),
                const SizedBox(width: 6),
                _smallButton('Reject', Colors.red, () => _updateAppStatus(app.id, 'Rejected')),
                const SizedBox(width: 6),
              ],
              _smallButton('Message', Colors.blue, () => _openChat(app, job)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 32,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Future<void> _updateAppStatus(String appId, String status) async {
    await FirebaseFirestore.instance.collection('applications').doc(appId).update({'status': status});
  }

  void _openChat(Application app, Job job) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          otherUserId: app.applicantId,
          otherUserName: app.applicantName,
          currentUserId: user.uid,
          currentUserName: widget.profile.firstName.isEmpty
              ? widget.profile.companyName
              : '${widget.profile.firstName} ${widget.profile.lastName}',
        ),
      ),
    );
  }

  // ── helpers ─────────────────────────────────────────────────────────────────

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: _inputDecoration(label, icon).copyWith(hintText: hint),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: const Color(0xFF1E88E5), size: 22),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: Color(0xFF1E88E5), width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red[300]!, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    );
  }
}

// A tiny extension so we can swap in a `child` on ElevatedButton
extension on ElevatedButton {
  ElevatedButton copyWith({Widget? child}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child ?? this.child,
    );
  }
}