import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noteshelper/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _defaultProvider = 'openai';

  final List<Map<String, String>> _providers = [
    {'value': 'openai', 'label': 'OpenAI GPT-4 Vision'},
    {'value': 'gemini', 'label': 'Google Gemini'},
    {'value': 'claude', 'label': 'Anthropic Claude'},
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).user;
    if (user?.defaultAiProvider != null) {
      _defaultProvider = user!.defaultAiProvider!;
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authStateProvider.notifier).logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Account Section
          _SectionHeader(title: 'Account'),
          if (authState.user != null) ...[
            ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  authState.user!.displayName.isNotEmpty
                      ? authState.user!.displayName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(authState.user!.displayName),
              subtitle: Text(authState.user!.email),
            ),
            const Divider(indent: 16, endIndent: 16),
          ],

          // AI Provider
          _SectionHeader(title: 'AI Provider'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: _defaultProvider,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.smart_toy_outlined),
                labelText: 'Default Provider',
              ),
              items: _providers
                  .map((p) => DropdownMenuItem<String>(
                        value: p['value'],
                        child: Text(p['label']!),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _defaultProvider = value);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          const Divider(indent: 16, endIndent: 16),

          // Appearance
          _SectionHeader(title: 'Appearance'),
          RadioListTile<ThemeMode>(
            title: const Text('System Default'),
            subtitle: const Text('Follow your device theme'),
            value: ThemeMode.system,
            groupValue: themeMode,
            onChanged: (mode) =>
                ref.read(themeModeProvider.notifier).setTheme(mode!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: themeMode,
            onChanged: (mode) =>
                ref.read(themeModeProvider.notifier).setTheme(mode!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: themeMode,
            onChanged: (mode) =>
                ref.read(themeModeProvider.notifier).setTheme(mode!),
          ),
          const Divider(indent: 16, endIndent: 16),

          // Logout
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // App Info
          Center(
            child: Text(
              'NotesHelper v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
