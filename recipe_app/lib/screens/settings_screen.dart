import 'package:flutter/material.dart';
import 'package:recipe_app/constants.dart';
import 'package:recipe_app/widgets/custom_bottom_nav_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final int _currentNavIndex = -1; // No bottom nav tab selected

  // Setting values
  bool _notificationsEnabled = true;
  String _measurementUnit = 'Metric';
  String _language = 'English';
  bool _saveRecipesOffline = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Account'),
            _buildAccountSettings(),
            _buildSectionHeader('App Preferences'),
            _buildAppPreferences(),
            _buildSectionHeader('Notifications'),
            _buildNotificationSettings(),
            _buildSectionHeader('Storage'),
            _buildStorageSettings(),
            _buildSectionHeader('About'),
            _buildAboutSettings(),
            const SizedBox(height: 32),
            _buildLogoutButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  void _onNavBarTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/favorites');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.person, color: AppColors.textPrimary),
          title: const Text('Edit Profile'),
          trailing:
              const Icon(Icons.chevron_right, color: AppColors.textPrimary),
          onTap: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock, color: AppColors.textPrimary),
          title: const Text('Privacy & Security'),
          trailing:
              const Icon(Icons.chevron_right, color: AppColors.textPrimary),
          onTap: () {
            // TODO: Navigate to Privacy & Security
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Privacy & Security settings coming soon!'),
                backgroundColor: AppColors.primary,
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.data_usage, color: AppColors.textPrimary),
          title: const Text('Data & Storage'),
          trailing:
              const Icon(Icons.chevron_right, color: AppColors.textPrimary),
          onTap: () {
            // TODO: Navigate to Data & Storage
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data & Storage settings coming soon!'),
                backgroundColor: AppColors.primary,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppPreferences() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.language, color: AppColors.textPrimary),
          title: const Text('Language'),
          subtitle: Text(_language),
          trailing:
              const Icon(Icons.chevron_right, color: AppColors.textPrimary),

        ),
        ListTile(
          leading: const Icon(Icons.straighten, color: AppColors.textPrimary),
          title: const Text('Measurement Units'),
          subtitle: Text(_measurementUnit),
          trailing:
              const Icon(Icons.chevron_right, color: AppColors.textPrimary),
          onTap: () {
            _showUnitSelector();
          },
        ),
      ],
    );
  }

  void _showUnitSelector() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Measurement Unit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUnitOption('Metric'),
              _buildUnitOption('Imperial'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnitOption(String unit) {
    return ListTile(
      title: Text(unit),
      trailing: _measurementUnit == unit
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () {
        setState(() {
          _measurementUnit = unit;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildNotificationSettings() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Receive updates about new recipes and more'),
          value: _notificationsEnabled,
          activeColor: AppColors.primary,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
          secondary:
              const Icon(Icons.notifications, color: AppColors.textPrimary),
        ),
        ListTile(
          leading: const Icon(Icons.notifications_active,
              color: AppColors.textPrimary),
          title: const Text('Notification Types'),
          subtitle: const Text('Customize what notifications you receive'),
          trailing:
              const Icon(Icons.chevron_right, color: AppColors.textPrimary),
          onTap: () {
            // TODO: Navigate to Notification Types
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notification type settings coming soon!'),
                backgroundColor: AppColors.primary,
              ),
            );
          },
          enabled: _notificationsEnabled,
        ),
      ],
    );
  }

  Widget _buildStorageSettings() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Save Recipes Offline'),
          subtitle: const Text('Access your favorite recipes without internet'),
          value: _saveRecipesOffline,
          activeColor: AppColors.primary,
          onChanged: (value) {
            setState(() {
              _saveRecipesOffline = value;
            });
          },
          secondary: const Icon(Icons.save_alt, color: AppColors.textPrimary),
        ),
        ListTile(
          leading: const Icon(Icons.delete, color: AppColors.textPrimary),
          title: const Text('Clear Cache'),
          subtitle: const Text('Free up storage space'),
          onTap: () {
            // TODO: Implement cache clearing
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cache cleared successfully!'),
                backgroundColor: AppColors.primary,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAboutSettings() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info, color: AppColors.textPrimary),
          title: const Text('App Version'),
          subtitle: const Text('1.0.0'),
        ),
        ListTile(
          leading: const Icon(Icons.description, color: AppColors.textPrimary),
          title: const Text('Terms of Service'),
          trailing:
              const Icon(Icons.chevron_right, color: AppColors.textPrimary),
          onTap: () {
            // TODO: Navigate to Terms of Service
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip, color: AppColors.textPrimary),
          title: const Text('Privacy Policy'),
          trailing:
              const Icon(Icons.chevron_right, color: AppColors.textPrimary),
          onTap: () {
            // TODO: Navigate to Privacy Policy
          },
        ),
        ListTile(
          leading: const Icon(Icons.help, color: AppColors.textPrimary),
          title: const Text('Help & Support'),
          trailing:
              const Icon(Icons.chevron_right, color: AppColors.textPrimary),
          onTap: () {
            Navigator.pushNamed(context, '/help_support');
          },
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // TODO: Implement logout
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Logout functionality coming soon!'),
                backgroundColor: AppColors.primary,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
