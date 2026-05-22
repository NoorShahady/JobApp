import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:first_version/screens/UserDetailsScreen.dart';
import 'package:first_version/theme/app_theme.dart';
import 'SignInScreen.dart';

import '../Models/UserProfile.dart';
import '../Models/application.dart';
import 'BusinessHiringScreen.dart';
import 'MessagesListScreen.dart';

class RootTabs extends StatefulWidget {
  final UserProfile profile;
  const RootTabs({super.key, required this.profile});

  @override
  State<RootTabs> createState() => _RootTabsState();
}

class _RootTabsState extends State<RootTabs> {
  int _index = 0;
  late final String _uid;
  late final String _userName;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _userName = '${widget.profile.firstName} ${widget.profile.lastName}'.trim();
  }

  @override
  Widget build(BuildContext context) {
    final isCandidate = widget.profile.accountType == 'candidate';
    final pages = <Widget>[
      if (isCandidate)
        JobsFeedScreen(profile: widget.profile)
      else
        BusinessHiringScreen(profile: widget.profile),
      _ApplicationsScreen(uid: _uid, isCandidate: isCandidate),
      if (isCandidate)
        _PlaceholderScreen(
          icon: Icons.badge_outlined,
          title: 'My Job',
          subtitle: 'Once you are hired, your job details will be here.',
        )
      else
        _PlaceholderScreen(
          icon: Icons.settings_suggest_outlined,
          title: 'Management',
          subtitle: 'Manage postings, candidates and hires.',
        ),
      MessagesListScreen(currentUserId: _uid, currentUserName: _userName),
      _ProfileScreen(profile: widget.profile),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            indicatorColor: AppColors.primary.withValues(alpha: 0.15),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary);
              }
              return TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey[600]);
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: AppColors.primary, size: 22);
              }
              return IconThemeData(color: Colors.grey[500], size: 22);
            }),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            const NavigationDestination(icon: Icon(Icons.folder_open), selectedIcon: Icon(Icons.folder), label: 'Applications'),
            NavigationDestination(
              icon: Icon(isCandidate ? Icons.badge_outlined : Icons.settings_suggest_outlined),
              selectedIcon: Icon(isCandidate ? Icons.badge : Icons.settings_suggest),
              label: isCandidate ? 'My Job' : 'Management',
            ),
            const NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Messages'),
            const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _PlaceholderScreen({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: c.primary),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  final UserProfile profile;
  const _ProfileScreen({required this.profile});

  @override
  Widget build(BuildContext context) {
    final isCandidate = profile.accountType == 'candidate';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          if (profile.bio.isNotEmpty || isCandidate) ...[
            _buildSection(
              context,
              icon: Icons.edit_note_rounded,
              title: 'About',
              child: Text(
                profile.bio.isEmpty ? 'Tell others about yourself.' : profile.bio,
                style: TextStyle(color: Colors.grey[700], fontSize: 15, height: 1.4),
              ),
            ),
            const SizedBox(height: 16),
          ],
          _buildSection(
            context,
            icon: Icons.person_outline,
            title: 'Personal Info',
            child: Column(
              children: [
                _infoRow(Icons.email_outlined, 'Email', profile.email),
                if (profile.phone.isNotEmpty) _infoRow(Icons.phone_outlined, 'Phone', profile.phone),
                if (profile.location.isNotEmpty) _infoRow(Icons.location_on_outlined, 'Location', profile.location),
                _infoRow(Icons.category_outlined, 'Account Type', isCandidate ? 'Worker' : 'Hiring Manager'),
              ],
            ),
          ),
          if (isCandidate) ...[
            const SizedBox(height: 16),
            _buildSection(
              context,
              icon: Icons.work_outline,
              title: 'Work Preferences',
              child: Column(
                children: [
                  if (profile.desiredRole.isNotEmpty) _infoRow(Icons.badge_outlined, 'Desired Role', profile.desiredRole),
                  _infoRow(Icons.schedule_outlined, 'Work Type', profile.workType),
                  _infoRow(Icons.timeline_outlined, 'Experience', '${profile.yearsOfExperience} years'),
                ],
              ),
            ),
            if (profile.skills.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection(
                context,
                icon: Icons.stars_rounded,
                title: 'Skills',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.skills.map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Text(s, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                  )).toList(),
                ),
              ),
            ],
          ],
          if (!isCandidate) ...[
            if (profile.companyName.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection(
                context,
                icon: Icons.business_rounded,
                title: 'Company',
                child: Column(
                  children: [
                    _infoRow(Icons.domain, 'Name', profile.companyName),
                    if (profile.companyAbout.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(profile.companyAbout,
                          style: TextStyle(color: Colors.grey[700], fontSize: 14, height: 1.4)),
                    ],
                  ],
                ),
              ),
            ],
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isCandidate = profile.accountType == 'candidate';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.lighterGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            child: Text(
              (profile.firstName.isNotEmpty ? profile.firstName[0] : 'U').toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${profile.firstName} ${profile.lastName}'.trim().isEmpty ? 'Your Name' : '${profile.firstName} ${profile.lastName}',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            profile.email.isEmpty ? 'your@email.com' : profile.email,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isCandidate ? 'Worker' : 'Hiring Manager',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[400]),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value.isEmpty ? 'Not set' : value,
                style: TextStyle(color: value.isEmpty ? Colors.grey[400] : Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _ApplicationsScreen extends StatelessWidget {
  final String uid;
  final bool isCandidate;
  const _ApplicationsScreen({required this.uid, required this.isCandidate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isCandidate ? 'My Applications' : 'Applicants',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where(isCandidate ? 'applicantId' : 'employerId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 12),
                  Text('Could not load applications',
                      style: TextStyle(color: Colors.red[400], fontSize: 16)),
                ],
              ),
            );
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_off_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(isCandidate ? 'No applications yet' : 'No applicants yet',
                      style: TextStyle(color: Colors.grey[400], fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text(isCandidate ? 'Apply to a job to see it here' : 'Applicants will appear once workers apply to your jobs',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                ],
              ),
            );
          }
          final sorted = docs.toList()..sort((a, b) {
            final aTime = (a.data() as Map<String, dynamic>)['appliedAt'] ?? '';
            final bTime = (b.data() as Map<String, dynamic>)['appliedAt'] ?? '';
            return bTime.toString().compareTo(aTime.toString());
          });
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final app = Application.fromJson(sorted[i].data() as Map<String, dynamic>, sorted[i].id);
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
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(isCandidate ? Icons.business : Icons.person,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isCandidate) ...[
                            Text(app.jobTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text(app.companyName,
                                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          ] else ...[
                            Text(app.applicantName,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text(app.jobTitle,
                                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          ],
                          const SizedBox(height: 4),
                          Text('Applied ${_formatDate(app.appliedAt)}',
                              style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        app.status,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
