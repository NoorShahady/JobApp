import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:first_version/screens/UserDetailsScreen.dart';

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
      _ApplicationsScreen(uid: _uid),
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
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
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
    final c = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: c.primaryContainer,
                  child: Text(
                    (profile.firstName.isNotEmpty ? profile.firstName[0] : 'U').toUpperCase(),
                    style: TextStyle(color: c.onPrimaryContainer, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${profile.firstName} ${profile.lastName}'.trim().isEmpty ? 'Your Name' : '${profile.firstName} ${profile.lastName}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(profile.email.isEmpty ? 'your@email.com' : profile.email,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('About', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  profile.bio.isEmpty ? 'Tell others about yourself.' : profile.bio,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ApplicationsScreen extends StatelessWidget {
  final String uid;
  const _ApplicationsScreen({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('applicantId', isEqualTo: uid)
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
                  Text('No applications yet',
                      style: TextStyle(color: Colors.grey[400], fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text('Apply to a job to see it here',
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
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.business, color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  title: Text(app.jobTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.companyName),
                      const SizedBox(height: 4),
                      Text(
                        'Applied ${_formatDate(app.appliedAt)}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      app.status,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
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
