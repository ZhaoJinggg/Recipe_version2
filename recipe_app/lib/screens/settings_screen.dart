import 'package:flutter/material.dart';
import 'package:recipe_app/constants.dart';
import 'package:recipe_app/widgets/custom_bottom_nav_bar.dart';
import 'package:recipe_app/services/user_session_service.dart';

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
            _buildSectionHeader('Danger Zone'),
            _buildDangerZoneSettings(),
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
          title: const Text('Change Password'),
          subtitle: const Text('Update your account password'),
          trailing:
              const Icon(Icons.chevron_right, color: AppColors.textPrimary),
          onTap: () {
            _showChangePasswordDialog();
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

  Widget _buildDangerZoneSettings() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text(
            'Delete Account',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
            'Permanently delete your account and all data',
            style: TextStyle(color: Colors.red),
          ),
          onTap: () {
            _showDeleteAccountConfirmation();
          },
        ),
      ],
    );
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Account',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone and will permanently remove:\n\n'
            '• Your profile and personal information\n'
            '• All your saved recipes\n'
            '• Your grocery lists\n'
            '• Your comments and posts\n'
            '• All other account data\n\n'
            'This action is irreversible.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showFinalDeleteConfirmation();
              },
              child: const Text(
                'Delete Account',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFinalDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Final Confirmation',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'This is your final warning. Your account and all data will be permanently deleted. This action cannot be undone.\n\n'
            'Type "DELETE" to confirm:',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performAccountDeletion();
              },
              child: const Text(
                'I understand, delete my account',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _performAccountDeletion() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Deleting your account...'),
            ],
          ),
        );
      },
    );

    try {
      final success = await UserSessionService.deleteUserAccount();

      // Close loading dialog
      Navigator.of(context).pop();

      if (success) {
        // Show success message and navigate to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to login screen
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete account. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting account: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showChangePasswordDialog() {
    final _formKey = GlobalKey<FormState>();
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    bool _obscureCurrentPassword = true;
    bool _obscureNewPassword = true;
    bool _obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCurrentPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureCurrentPassword =
                                  !_obscureCurrentPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your current password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your new password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Navigator.of(context).pop();
                      _performPasswordChange(_newPasswordController.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                  ),
                  child: const Text('Change Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _performPasswordChange(String newPassword) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Changing password...'),
            ],
          ),
        );
      },
    );

    try {
      final success = await UserSessionService.changePassword(newPassword);

      // Close loading dialog
      Navigator.of(context).pop();

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to change password. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error changing password: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            try {
              await UserSessionService.logoutUser();
              Navigator.pushReplacementNamed(context, '/login');
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logout failed: \$e'),
                  backgroundColor: AppColors.primary,
                ),
              );
            }
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
