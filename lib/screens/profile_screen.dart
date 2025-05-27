import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/screens/login_screen.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    authProvider.user?.email ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Settings Section
          Card(
            child: Column(
              children: [
                _buildSettingsTile(
                  context,
                  'Help & Support',
                  'Get help and contact support',
                  Icons.help,
                      () => _showInfoBottomSheet(
                    context: context,
                    helpTitle: 'Help & Support',
                    helpDescription: 'If you’re experiencing issues, contact us at:',
                    helpEmail: 'support@bereketapp.com',
                    ),
                ),
                const Divider(height: 1),
                _buildSettingsTile(
                  context,
                  'About',
                  'App information and version',
                  Icons.info,
                      () => _showInfoBottomSheet(
                    context: context,
                    aboutTitle: 'About Bereket App',
                    aboutDescription:
                    'Version 1.0.0\n\nBereket is your personal task manager.\nAll rights reserved © 2025.',
                  ),
                ),
                const Divider(height: 1),
                _buildSettingsTile(
                  context,
                  'Sign Out',
                  'Sign out of your account',
                  Icons.logout,
                      () async {
                    await authProvider.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      VoidCallback onTap, {
        bool isDestructive = false,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showInfoBottomSheet({
    required BuildContext context,
     String? helpTitle,
     String? helpDescription,
     String? helpEmail,
     String? aboutTitle,
     String? aboutDescription,
  }) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Help & Support Section
                Text(
                  helpTitle ?? '',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  helpDescription ?? '',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                SelectableText(
                  helpEmail ?? '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Divider(color: Theme.of(context).colorScheme.outlineVariant),
                const SizedBox(height: 24),

                // About Section
                Text(
                  aboutTitle ?? '',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  aboutDescription ?? '',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}