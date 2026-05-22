import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Models/UserProfile.dart';
import '../Models/job.dart';
import '../Models/jobs_store.dart';
import '../theme/app_theme.dart';
import 'ChatScreen.dart';
import 'JobsFiltersScreen.dart';
import 'LoginScreen.dart';




class JobsFeedScreen extends StatefulWidget {
  final UserProfile profile;
  const JobsFeedScreen({super.key, required this.profile});

  @override
  State<JobsFeedScreen> createState() => _JobsFeedScreenState();


}

class _JobsFeedScreenState extends State<JobsFeedScreen> {
  String _query = '';
  String _workType = 'Any';

  List<Job> _filtered(List<Job> all) {
    return all.where((j) {
      final qOk = _query.isEmpty ||
          j.title.toLowerCase().contains(_query.toLowerCase()) ||
          j.company.toLowerCase().contains(_query.toLowerCase());
      final wtOk = _workType == 'Any' || j.workType == _workType;
      return qOk && wtOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Available Jobs',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 28,
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
      body: Column(
        children: [
          JobsFiltersScreen(
            initialQuery: widget.profile.desiredRole,
            onQuery: (v) => setState(() => _query = v),
            onWorkType: (v) => setState(() => _workType = v),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: JobsStore.instance,
              builder: (context, _) {
                final jobs = _filtered(JobsStore.instance.jobs);
                if (jobs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('No jobs found',
                            style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemBuilder: (_, i) => _buildJobCard(jobs[i]),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: jobs.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(Job j) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showJob(j),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.lighterGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      j.company.isNotEmpty ? j.company[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        j.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${j.company} • ${j.location}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          j.workType,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.grey[400], size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showJob(Job j) {
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
        expand: false,
        maxChildSize: 0.9,
        builder: (context, controller) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: ListView(
              controller: controller,
              children: [
                Text(
                  j.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.business_rounded,
                        size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      j.company,
                      style:
                      TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.location_on_outlined,
                        size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      j.location,
                      style:
                      TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    j.workType,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Job Description',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  j.description,
                  style: TextStyle(
                      fontSize: 16, color: Colors.grey[700], height: 1.5),
                ),
                const SizedBox(height: 24),
                _buildJobActions(j),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobActions(Job j) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('applications')
          .where('jobId', isEqualTo: j.id)
          .where('applicantId', isEqualTo: user.uid)
          .limit(1)
          .snapshots(),
      builder: (context, snap) {
        final hasApplied = snap.data?.docs.isNotEmpty ?? false;

        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: hasApplied
                      ? LinearGradient(colors: [Colors.grey[400]!, Colors.grey[400]!])
                      : AppColors.lighterGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: hasApplied ? null : () => _applyForJob(j, user),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            hasApplied ? Icons.check_circle : Icons.send_rounded,
                            color: Colors.white, size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            hasApplied ? 'Applied' : 'Apply Now',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (j.employerId.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _openChatWithEmployer(j, user),
                  icon: const Icon(Icons.chat_outlined, size: 18),
                  label: const Text('Message Employer',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _applyForJob(Job j, User user) async {
    final profile = widget.profile;
    await FirebaseFirestore.instance.collection('applications').add({
      'jobId': j.id,
      'jobTitle': j.title,
      'companyName': j.company,
      'applicantId': user.uid,
      'applicantName': '${profile.firstName} ${profile.lastName}'.trim(),
      'applicantEmail': profile.email,
      'employerId': j.employerId,
      'appliedAt': DateTime.now().toIso8601String(),
      'status': 'Pending',
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Applied to ${j.title} at ${j.company}'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _openChatWithEmployer(Job j, User user) {
    final profile = widget.profile;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          otherUserId: j.employerId,
          otherUserName: j.employerName.isEmpty ? j.company : j.employerName,
          currentUserId: user.uid,
          currentUserName: '${profile.firstName} ${profile.lastName}'.trim(),
        ),
      ),
    );
  }
}
