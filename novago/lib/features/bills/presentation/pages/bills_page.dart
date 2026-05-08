import 'package:flutter/material.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Electricity',
    'Water',
    'Internet',
    'Mobile',
    'Insurance',
    'Credit Card',
  ];

  final List<BillItem> _bills = [
    BillItem(
      name: 'Electricity Bill',
      provider: 'Power Company',
      amount: 125.50,
      dueDate: '2024-01-15',
      category: 'Electricity',
      isPaid: false,
      icon: Icons.electrical_services,
      color: const Color(0xFFFF6B35),
    ),
    BillItem(
      name: 'Water Bill',
      provider: 'Water Authority',
      amount: 45.20,
      dueDate: '2024-01-20',
      category: 'Water',
      isPaid: false,
      icon: Icons.water_drop,
      color: const Color(0xFF4A90E2),
    ),
    BillItem(
      name: 'Internet Bill',
      provider: 'Broadband Inc',
      amount: 89.99,
      dueDate: '2024-01-25',
      category: 'Internet',
      isPaid: false,
      icon: Icons.wifi,
      color: const Color(0xFF00B14F),
    ),
    BillItem(
      name: 'Mobile Bill',
      provider: 'Mobile Network',
      amount: 35,
      dueDate: '2024-01-10',
      category: 'Mobile',
      isPaid: true,
      icon: Icons.phone_android,
      color: const Color(0xFF9B59B6),
    ),
    BillItem(
      name: 'Insurance Premium',
      provider: 'Insurance Co',
      amount: 250,
      dueDate: '2024-01-30',
      category: 'Insurance',
      isPaid: false,
      icon: Icons.security,
      color: const Color(0xFFE74C3C),
    ),
    BillItem(
      name: 'Credit Card',
      provider: 'Bank Credit',
      amount: 450.75,
      dueDate: '2024-01-12',
      category: 'Credit Card',
      isPaid: false,
      icon: Icons.credit_card,
      color: const Color(0xFFF39C12),
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
        title: const Text('Bills & Payments'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: const Color(0xFF00B14F),
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search bills',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),

          // Categories
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF00B14F) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF00B14F) : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bills List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bills.length,
              itemBuilder: (context, index) {
                final bill = _bills[index];
                return _buildBillCard(bill);
              },
            ),
          ),
        ],
      ),
    );

  Widget _buildBillCard(BillItem bill) => Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bill.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            bill.icon,
            color: bill.color,
            size: 24,
          ),
        ),
        title: Text(
          bill.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bill.provider,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Due: ${bill.dueDate}',
              style: TextStyle(
                color: bill.isPaid ? Colors.green : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${bill.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: bill.isPaid ? Colors.green : const Color(0xFF00B14F),
              ),
            ),
            const SizedBox(height: 4),
            if (bill.isPaid)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Paid',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              ElevatedButton(
                onPressed: () {
                  _showPaymentDialog(bill);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B14F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  'Pay Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

  void _showPaymentDialog(BillItem bill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pay ${bill.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Provider: ${bill.provider}'),
            Text('Amount: \$${bill.amount.toStringAsFixed(2)}'),
            Text('Due Date: ${bill.dueDate}'),
            const SizedBox(height: 16),
            const Text(
              'Payment Method:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const ListTile(
              leading: Icon(Icons.account_balance_wallet, color: Color(0xFF00B14F)),
              title: Text('NovaGo Wallet'),
              trailing: Radio(value: 'wallet', groupValue: 'wallet', onChanged: null),
            ),
            const ListTile(
              leading: Icon(Icons.credit_card, color: Colors.grey),
              title: Text('Credit Card'),
              trailing: Radio(value: 'card', groupValue: 'wallet', onChanged: null),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                bill.isPaid = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${bill.name} paid successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B14F),
            ),
            child: const Text('Pay Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class BillItem {

  BillItem({
    required this.name,
    required this.provider,
    required this.amount,
    required this.dueDate,
    required this.category,
    required this.isPaid,
    required this.icon,
    required this.color,
  });
  final String name;
  final String provider;
  final double amount;
  final String dueDate;
  final String category;
  bool isPaid;
  final IconData icon;
  final Color color;
}