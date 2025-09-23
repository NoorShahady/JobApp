import 'package:flutter/material.dart';
import 'package:first_version/screens/Shared/user.details.dart';
import 'package:google_fonts/google_fonts.dart';

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