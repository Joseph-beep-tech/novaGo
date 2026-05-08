import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String _userName = 'John Doe';
  final String _userEmail = 'john.doe@example.com';
  final String _userPhone = '+1 (555) 123-4567';
  final String _userAvatar = 'https://via.placeholder.com/100x100/00B14F/FFFFFF?text=JD';

  List<ProfileMenuItem> get _menuItems => [
    ProfileMenuItem(
      icon: Icons.person_outline,
      title: 'Personal Information',
      subtitle: 'Update your profile details',
      onTap: () => context.go('/edit-profile'),
    ),
    ProfileMenuItem(
      icon: Icons.location_on_outlined,
      title: 'Addresses',
      subtitle: 'Manage your saved addresses',
      onTap: () => context.go('/address-book'),
    ),
    ProfileMenuItem(
      icon: Icons.receipt_long_outlined,
      title: 'Order History',
      subtitle: 'View your past orders',
      onTap: () => context.go('/order-history'),
    ),
    ProfileMenuItem(
      icon: Icons.settings_outlined,
      title: 'Settings',
      subtitle: 'App preferences and settings',
      onTap: () => context.go('/settings'),
    ),
    ProfileMenuItem(
      icon: Icons.payment_outlined,
      title: 'Payment Methods',
      subtitle: 'Manage your payment options',
      onTap: () => context.go('/wallet'),
    ),
    ProfileMenuItem(
      icon: Icons.notifications_outlined,
      title: 'Notifications',
      subtitle: 'Customize your notifications',
      onTap: () => _showNotificationsSettings(context),
    ),
    ProfileMenuItem(
      icon: Icons.security_outlined,
      title: 'Privacy & Security',
      subtitle: 'Manage your privacy settings',
      onTap: () => _showPrivacySettings(context),
    ),
    ProfileMenuItem(
      icon: Icons.help_outline,
      title: 'Help & Support',
      subtitle: 'Get help and contact support',
      onTap: () => _showHelpSupport(context),
    ),
    ProfileMenuItem(
      icon: Icons.info_outline,
      title: 'About',
      subtitle: 'App version and legal information',
      onTap: () => _showAbout(context),
    ),
    ProfileMenuItem(
      icon: Icons.logout,
      title: 'Sign Out',
      subtitle: 'Sign out of your account',
      onTap: () => _showSignOutDialog(context),
      isDestructive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF00B14F),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF00B14F),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 45,
                            backgroundImage: NetworkImage(_userAvatar),
                            child: _userAvatar.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Color(0xFF00B14F),
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Color(0xFF00B14F),
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // User Info
                    Text(
                      _userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userEmail,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userPhone,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Edit Profile Button
                    ElevatedButton(
                      onPressed: () => context.go('/edit-profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF00B14F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Stats Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Orders',
                      value: '127',
                      icon: Icons.shopping_bag_outlined,
                      color: const Color(0xFF00B14F),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Saved',
                      value: r'$245',
                      icon: Icons.savings_outlined,
                      color: const Color(0xFF4A90E2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Rewards',
                      value: '1,250',
                      icon: Icons.card_giftcard_outlined,
                      color: const Color(0xFFFF6B35),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Menu Items
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: _menuItems.map(_buildMenuItem).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // App Version
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'NovaGo v1.0.0',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

  Widget _buildMenuItem(ProfileMenuItem item) => ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: item.isDestructive
              ? Colors.red.withOpacity(0.1)
              : const Color(0xFF00B14F).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          item.icon,
          color: item.isDestructive ? Colors.red : const Color(0xFF00B14F),
          size: 20,
        ),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: item.isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(
        item.subtitle,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: item.onTap,
    );

  void _showNotificationsSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Notification Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text('Push Notifications'),
              subtitle: Text('Receive push notifications'),
              trailing: Switch(value: true, onChanged: null),
            ),
            ListTile(
              title: Text('Order Updates'),
              subtitle: Text('Get notified about order status'),
              trailing: Switch(value: true, onChanged: null),
            ),
            ListTile(
              title: Text('Promotions'),
              subtitle: Text('Receive promotional offers'),
              trailing: Switch(value: false, onChanged: null),
            ),
            ListTile(
              title: Text('Ride Updates'),
              subtitle: Text('Get notified about ride status'),
              trailing: Switch(value: true, onChanged: null),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Privacy & Security',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text('Location Services'),
              subtitle: Text('Allow location access for better service'),
              trailing: Switch(value: true, onChanged: null),
            ),
            ListTile(
              title: Text('Data Sharing'),
              subtitle: Text('Share data for personalized experience'),
              trailing: Switch(value: false, onChanged: null),
            ),
            ListTile(
              title: Text('Two-Factor Authentication'),
              subtitle: Text('Add extra security to your account'),
              trailing: Switch(value: false, onChanged: null),
            ),
            ListTile(
              title: Text('Biometric Login'),
              subtitle: Text('Use fingerprint or face ID'),
              trailing: Switch(value: true, onChanged: null),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Help & Support',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildHelpOption(
                    'FAQ',
                    'Frequently asked questions',
                    Icons.help_outline,
                    () => Navigator.pop(context),
                  ),
                  _buildHelpOption(
                    'Contact Support',
                    'Get help from our support team',
                    Icons.support_agent,
                    () => Navigator.pop(context),
                  ),
                  _buildHelpOption(
                    'Report a Problem',
                    'Report issues or bugs',
                    Icons.bug_report,
                    () => Navigator.pop(context),
                  ),
                  _buildHelpOption(
                    'Live Chat',
                    'Chat with support agent',
                    Icons.chat,
                    () => Navigator.pop(context),
                  ),
                  _buildHelpOption(
                    'Call Support',
                    'Call our support hotline',
                    Icons.phone,
                    () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpOption(String title, String subtitle, IconData icon, VoidCallback onTap) => ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF00B14F).withOpacity(0.1),
        child: Icon(icon, color: const Color(0xFF00B14F)),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About NovaGo'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Build: 2024.01.15'),
            SizedBox(height: 8),
            Text('NovaGo - The Ultimate Lifestyle Super App'),
            SizedBox(height: 16),
            Text('© 2024 NovaGo. All rights reserved.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login page
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class ProfileMenuItem {

  ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
}