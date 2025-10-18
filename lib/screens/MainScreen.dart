import 'package:flutter/material.dart';
import 'package:first_version/screens/UserDetailsScreen.dart';

import 'SignUpScreen.dart';
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.primary.withOpacity(.12), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header / Logo
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: color.primaryContainer.withOpacity(.4),
                      child: Icon(Icons.work, color: color.primary, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'HireMe',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: color.primary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'About',
                      onPressed: () => _showAbout(context),
                      icon: const Icon(Icons.info_outline),
                    )
                  ],
                ),
                const SizedBox(height: 24),

                // Tagline
                Text(
                  'Find your next job.\nHire the right people.',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'One place for candidates and businesses.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(.8),
                  ),
                ),
                const SizedBox(height: 24),

                // Illustration
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: color.surfaceVariant.withOpacity(.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.outlineVariant.withOpacity(.4)),
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: LayoutBuilder(builder: (_, c) {
                          final s = c.maxWidth * 0.18;
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 12,
                                left: 12,
                                child: _iconCard(Icons.person_pin_circle, 'Candidates', color),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: _iconCard(Icons.apartment, 'Businesses', color),
                              ),
                              Icon(Icons.sync_alt, color: color.primary, size: s),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // CTA buttons
                SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserProfileFormScreen(), // 👈 target page here
                        ),
                      );
                    },
                    icon: const Icon(Icons.badge),
                    label: const Text('I’m looking for a job'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserProfileFormScreen(), // 👈 target page here
                        ),
                      );
                    },
                    icon: const Icon(Icons.business_center_outlined),
                    label: const Text('I’m a business hiring'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconCard(IconData icon, String label, ColorScheme color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.surface.withOpacity(.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.outlineVariant.withOpacity(.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.primary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'HireMe',
      applicationVersion: '0.1.0',
      applicationIcon: const CircleAvatar(child: Icon(Icons.work)),
      children: const [
        Text('A simple demo for candidates and businesses to connect.'),
      ],
    );
  }
}