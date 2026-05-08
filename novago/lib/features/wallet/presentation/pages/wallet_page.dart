import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final double _balance = 125.50;
  String _selectedTab = 'Balance';

  final List<Transaction> _recentTransactions = [
    Transaction(
      title: "Food Delivery - McDonald's",
      subtitle: 'Today, 2:30 PM',
      amount: -12.50,
      type: TransactionType.food,
    ),
    Transaction(
      title: 'Ride - GrabCar',
      subtitle: 'Yesterday, 6:45 PM',
      amount: -8.50,
      type: TransactionType.ride,
    ),
    Transaction(
      title: 'Top Up',
      subtitle: 'Yesterday, 5:20 PM',
      amount: 50,
      type: TransactionType.topup,
    ),
    Transaction(
      title: 'Grocery - FreshMart',
      subtitle: '2 days ago, 10:15 AM',
      amount: -35.20,
      type: TransactionType.grocery,
    ),
    Transaction(
      title: 'Reward Cashback',
      subtitle: '3 days ago, 8:30 PM',
      amount: 5,
      type: TransactionType.reward,
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
        title: const Text('NovaGo Wallet'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: Column(
        children: [
          // Balance Card
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
                  'NovaGo Wallet Balance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${_balance.toStringAsFixed(2)}',
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
                        onPressed: () {
                          context.go('/add-money');
                        },
                        icon: const Icon(Icons.add, color: Color(0xFF00B14F)),
                        label: const Text(
                          'Top Up',
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
                        onPressed: () {
                          context.go('/transaction-history');
                        },
                        icon: const Icon(Icons.history, color: Colors.white),
                        label: const Text(
                          'History',
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

          // Quick Actions
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickAction(
                      icon: Icons.send,
                      title: 'Send Money',
                      onTap: () {},
                    ),
                    _buildQuickAction(
                      icon: Icons.receipt,
                      title: 'Pay Bills',
                      onTap: () {},
                    ),
                    _buildQuickAction(
                      icon: Icons.qr_code,
                      title: 'Scan QR',
                      onTap: () {},
                    ),
                    _buildQuickAction(
                      icon: Icons.card_giftcard,
                      title: 'Rewards',
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

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
                  child: _buildTab('Balance', _selectedTab == 'Balance'),
                ),
                Expanded(
                  child: _buildTab('Cards', _selectedTab == 'Cards'),
                ),
                Expanded(
                  child: _buildTab('Rewards', _selectedTab == 'Rewards'),
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

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) => GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00B14F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF00B14F),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
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
      case 'Balance':
        return _buildBalanceContent();
      case 'Cards':
        return _buildCardsContent();
      case 'Rewards':
        return _buildRewardsContent();
      default:
        return _buildBalanceContent();
    }
  }

  Widget _buildBalanceContent() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _recentTransactions.length,
            itemBuilder: (context, index) {
              final transaction = _recentTransactions[index];
              return _buildTransactionItem(transaction);
            },
          ),
        ),
      ],
    );

  Widget _buildCardsContent() => const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No cards added yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add a card to make payments easier',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );

  Widget _buildRewardsContent() => const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No rewards yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start using NovaGo to earn rewards',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );

  Widget _buildTransactionItem(Transaction transaction) => ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getTransactionColor(transaction.type).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getTransactionIcon(transaction.type),
          color: _getTransactionColor(transaction.type),
          size: 20,
        ),
      ),
      title: Text(
        transaction.title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        transaction.subtitle,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      trailing: Text(
        '${transaction.amount >= 0 ? '+' : ''}\$${transaction.amount.abs().toStringAsFixed(2)}',
        style: TextStyle(
          color: transaction.amount >= 0 ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.food:
        return const Color(0xFFFF6B35);
      case TransactionType.ride:
        return const Color(0xFF4A90E2);
      case TransactionType.grocery:
        return const Color(0xFF9B59B6);
      case TransactionType.topup:
        return const Color(0xFF00B14F);
      case TransactionType.reward:
        return const Color(0xFFE91E63);
    }
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.food:
        return Icons.restaurant;
      case TransactionType.ride:
        return Icons.local_taxi;
      case TransactionType.grocery:
        return Icons.shopping_cart;
      case TransactionType.topup:
        return Icons.add_circle;
      case TransactionType.reward:
        return Icons.card_giftcard;
    }
  }
}

class Transaction {

  Transaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
  });
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
}

enum TransactionType {
  food,
  ride,
  grocery,
  topup,
  reward,
}