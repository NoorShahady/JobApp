import 'package:flutter/material.dart';
import 'package:first_version/screens/Shared/user.details.dart';
import 'package:google_fonts/google_fonts.dart';

class RootTabs extends StatefulWidget {
  final UserProfile profile;
  const RootTabs({super.key, required this.profile});

  @override
  State<RootTabs> createState() => _RootTabsState();
}

class _RootTabsState extends State<RootTabs> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isCandidate = widget.profile.accountType == 'candidate';
    final pages = <Widget>[
      // 1) Home
      if (isCandidate)
        JobsFeedScreen(profile: widget.profile)
      else
        BusinessHiringScreen(profile: widget.profile),
      // 2) My Applications / My Jobs (history)
      const _PlaceholderScreen(
        icon: Icons.work_outline,
        title: 'My Applications',
        subtitle: 'Jobs you applied to will show up here.',
      ),
      // 3) My Job / Management
      _PlaceholderScreen(
        icon: isCandidate ? Icons.badge_outlined : Icons.settings_suggest_outlined,
        title: isCandidate ? 'My Job' : 'Management',
        subtitle: isCandidate
            ? 'Once you are hired, your job details will be here.'
            : 'Manage postings, candidates and hires (coming soon).',
      ),
      // 4) Messages
      const _PlaceholderScreen(
        icon: Icons.chat_bubble_outline,
        title: 'Messages',
        subtitle: 'Conversations between candidates and businesses will appear here.',
      ),
      // 5) Profile
      _ProfileScreen(profile: widget.profile),
    ];

    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.folder_open), label: 'Applications',
      ),
      BottomNavigationBarItem(
        icon: Icon(isCandidate ? Icons.badge_outlined : Icons.settings_suggest_outlined),
        label: isCandidate ? 'My Job' : 'Management',
      ),
      const BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
      const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar:Theme(data: Theme.of(context).copyWith(
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: 10,  // Smaller label text
              fontWeight: FontWeight.w600,
            ),

          ),
        ),
      ), child:  NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i), // i is for which page to open on the bar

        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          const NavigationDestination(icon: Icon(Icons.folder_open), selectedIcon: Icon(Icons.folder), label: 'Applications'
          ),
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


