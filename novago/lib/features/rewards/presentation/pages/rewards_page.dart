import 'package:flutter/material.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final int _points = 1250;
  String _selectedTab = 'Earn';

  final List<RewardItem> _earnRewards = [
    RewardItem(
      name: 'Complete Profile',
      description: 'Add your profile picture and details',
      points: 50,
      icon: Icons.person,
      color: const Color(0xFF00B14F),
      isCompleted: true,
    ),
    RewardItem(
      name: 'First Ride',
      description: 'Take your first ride with NovaGo',
      points: 100,
      icon: Icons.local_taxi,
      color: const Color(0xFF4A90E2),
      isCompleted: true,
    ),
    RewardItem(
      name: 'Order Food',
      description: 'Order food delivery 5 times',
      points: 200,
      icon: Icons.restaurant,
      color: const Color(0xFFFF6B35),
      isCompleted: false,
    ),
    RewardItem(
      name: 'Refer Friend',
      description: 'Invite a friend to join NovaGo',
      points: 150,
      icon: Icons.people,
      color: const Color(0xFF9B59B6),
      isCompleted: false,
    ),
  ];

  final List<RewardItem> _redeemRewards = [
    RewardItem(
      name: r'$5 Voucher',
      description: 'Use on any NovaGo service',
      points: 500,
      icon: Icons.card_giftcard,
      color: const Color(0xFF00B14F),
      isCompleted: false,
    ),
    RewardItem(
      name: 'Free Delivery',
      description: 'Free delivery on next order',
      points: 300,
      icon: Icons.local_shipping,
      color: const Color(0xFF4A90E2),
      isCompleted: false,
    ),
    RewardItem(
      name: 'Discount Coupon',
      description: '20% off on food delivery',
      points: 400,
      icon: Icons.discount,
      color: const Color(0xFFFF6B35),
      isCompleted: false,
    ),
    RewardItem(
      name: 'Premium Membership',
      description: '1 month premium access',
      points: 1000,
      icon: Icons.star,
      color: const Color(0xFF9B59B6),
      isCompleted: false,
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
        title: const Text('Rewards'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: Column(
        children: [
          // Points Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00B14F), Color(0xFF00A047)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00B14F).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your NovaGo Points',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_points',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, color: Color(0xFF00B14F)),
                        label: const Text(
                          'Earn More',
                          style: TextStyle(color: Color(0xFF00B14F)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.card_giftcard, color: Colors.white),
                        label: const Text(
                          'Redeem',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
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
            child: Row(
              children: [
                Expanded(
                  child: _buildTab('Earn', _selectedTab == 'Earn'),
                ),
                Expanded(
                  child: _buildTab('Redeem', _selectedTab == 'Redeem'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Content based on selected tab
          Expanded(
            child: Container(
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
              child: _buildTabContent(),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );

  Widget _buildTab(String title, bool isSelected) => GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00B14F) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 'Earn':
        return _buildEarnContent();
      case 'Redeem':
        return _buildRedeemContent();
      default:
        return _buildEarnContent();
    }
  }

  Widget _buildEarnContent() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Earn Points',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _earnRewards.length,
            itemBuilder: (context, index) {
              final reward = _earnRewards[index];
              return _buildRewardItem(reward);
            },
          ),
        ),
      ],
    );

  Widget _buildRedeemContent() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Redeem Rewards',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _redeemRewards.length,
            itemBuilder: (context, index) {
              final reward = _redeemRewards[index];
              return _buildRewardItem(reward);
            },
          ),
        ),
      ],
    );

  Widget _buildRewardItem(RewardItem reward) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: reward.isCompleted ? Colors.green : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: reward.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              reward.icon,
              color: reward.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reward.description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${reward.points} pts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: reward.isCompleted ? Colors.green : const Color(0xFF00B14F),
                ),
              ),
              const SizedBox(height: 4),
              if (reward.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B14F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    _selectedTab == 'Earn' ? 'Start' : 'Redeem',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
}

class RewardItem {

  RewardItem({
    required this.name,
    required this.description,
    required this.points,
    required this.icon,
    required this.color,
    required this.isCompleted,
  });
  final String name;
  final String description;
  final int points;
  final IconData icon;
  final Color color;
  final bool isCompleted;
}