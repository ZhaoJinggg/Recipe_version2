import 'package:flutter/material.dart';
import 'package:recipe_app/constants.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          'Help & Support',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textPrimary.withOpacity(0.6),
          tabs: const [
            Tab(text: 'Getting Started'),
            Tab(text: 'FAQs'),
            Tab(text: 'Contact Us'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGettingStartedTab(),
          _buildFAQsTab(),
          _buildContactTab(),
        ],
      ),
    );
  }

  Widget _buildGettingStartedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildQuickStartGuide(),
          const SizedBox(height: 20),
          _buildFeatureOverview(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.restaurant_menu,
            size: 48,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Welcome to Cook Book!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your culinary journey starts here. Discover, cook, and share amazing recipes with our community.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Start Guide',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildGuideStep(
          1,
          'Explore Recipes',
          'Browse through thousands of recipes or use search to find specific dishes.',
          Icons.search,
        ),
        _buildGuideStep(
          2,
          'Save Favorites',
          'Tap the heart icon to save recipes you love for quick access later.',
          Icons.favorite,
        ),
        _buildGuideStep(
          3,
          'Create Grocery Lists',
          'Add ingredients from recipes to your grocery list automatically.',
          Icons.shopping_cart,
        ),
        _buildGuideStep(
          4,
          'Join Community',
          'Share your own recipes and connect with fellow food enthusiasts.',
          Icons.people,
        ),
      ],
    );
  }

  Widget _buildGuideStep(
      int step, String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          'Recipe Discovery',
          'Find recipes by cuisine, dietary restrictions, or cooking time.',
          Icons.explore,
        ),
        _buildFeatureCard(
          'Smart Grocery Lists',
          'Automatically generate shopping lists from your selected recipes.',
          Icons.list_alt,
        ),
        _buildFeatureCard(
          'Community Sharing',
          'Share your favorite recipes and discover new ones from other users.',
          Icons.share,
        ),
        _buildFeatureCard(
          'Offline Access',
          'Save recipes for offline viewing when cooking without internet.',
          Icons.offline_pin,
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildFAQSection('General Questions', [
            _buildFAQItem(
              'How do I create an account?',
              'You can create an account by tapping "Sign Up" on the login screen and filling out the required information including your name, email, and password.',
            ),
            _buildFAQItem(
              'Is Cook Book free to use?',
              'Yes! Cook Book is completely free to download and use. All recipes, features, and community access are included at no cost.',
            ),
            _buildFAQItem(
              'How do I reset my password?',
              'On the login screen, tap "Forgot Password?" and enter your email address. You\'ll receive instructions to reset your password.',
            ),
          ]),
          _buildFAQSection('Recipe Features', [
            _buildFAQItem(
              'How do I save recipes to favorites?',
              'Simply tap the heart icon on any recipe card or detail page. Your favorites are accessible from the Favorites tab in the bottom navigation.',
            ),
            _buildFAQItem(
              'Can I access recipes offline?',
              'Yes! Enable "Save Recipes Offline" in Settings, and your favorited recipes will be available even without an internet connection.',
            ),
            _buildFAQItem(
              'How do I share my own recipes?',
              'Go to the Community tab and tap the "+" button to add your own recipe. Fill in the details, add photos, and share with the community!',
            ),
          ]),
          _buildFAQSection('Grocery Lists', [
            _buildFAQItem(
              'How do grocery lists work?',
              'When viewing a recipe, tap "Add to Grocery List" to automatically add all ingredients. Access your list from the Grocery tab.',
            ),
            _buildFAQItem(
              'Can I edit my grocery list?',
              'Absolutely! You can add, remove, or modify items in your grocery list. Tap on any item to edit it or swipe to delete.',
            ),
          ]),
          _buildFAQSection('Technical Issues', [
            _buildFAQItem(
              'The app is running slowly. What should I do?',
              'Try clearing the app cache in Settings > Storage > Clear Cache. If issues persist, restart the app or your device.',
            ),
            _buildFAQItem(
              'I\'m having trouble with notifications.',
              'Check your device settings and ensure notifications are enabled for Cook Book. You can also adjust notification preferences in the app settings.',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildFAQSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...items,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ),
      ],
      iconColor: AppColors.primary,
      collapsedIconColor: AppColors.textPrimary.withOpacity(0.6),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Get in Touch',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'re here to help! Choose the best way to reach us:',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          _buildContactOption(
            'Email Support',
            'support@cookbook.com',
            'Get help via email. We typically respond within 24 hours.',
            Icons.email,
            () => _showContactForm('email'),
          ),
          _buildContactOption(
            'Live Chat',
            'Available 9 AM - 6 PM EST',
            'Chat with our support team for instant help.',
            Icons.chat,
            () => _showContactForm('chat'),
          ),
          _buildContactOption(
            'Phone Support',
            '+1 (555) 123-4567',
            'Call us for urgent issues. Available weekdays 9-5 EST.',
            Icons.phone,
            () => _showContactForm('phone'),
          ),
          _buildContactOption(
            'Bug Report',
            'Report technical issues',
            'Help us improve by reporting bugs or suggesting features.',
            Icons.bug_report,
            () => _showContactForm('bug'),
          ),
          const SizedBox(height: 32),
          _buildFeedbackSection(),
        ],
      ),
    );
  }

  Widget _buildContactOption(
    String title,
    String subtitle,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.feedback,
            size: 40,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Love Cook Book?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rate us on the app store or share your feedback to help us improve!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for your feedback!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Rate App',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showContactForm('feedback'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Send Feedback'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showContactForm(String type) {
    String title = '';
    String hintText = '';

    switch (type) {
      case 'email':
        title = 'Email Support';
        hintText = 'Describe your question or issue...';
        break;
      case 'chat':
        title = 'Live Chat';
        hintText = 'Start a conversation with our support team...';
        break;
      case 'phone':
        title = 'Phone Support';
        hintText = 'Describe your issue for a phone callback...';
        break;
      case 'bug':
        title = 'Bug Report';
        hintText = 'Describe the bug you encountered...';
        break;
      case 'feedback':
        title = 'Send Feedback';
        hintText = 'Share your thoughts and suggestions...';
        break;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: AppColors.textPrimary.withOpacity(0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Your email address',
                  hintStyle: TextStyle(
                    color: AppColors.textPrimary.withOpacity(0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Your $type has been sent successfully!'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
              ),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }
}
