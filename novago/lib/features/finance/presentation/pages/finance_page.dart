import 'package:flutter/material.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  String _selectedTab = 'Payments';

  final List<FinanceService> _paymentServices = [
    FinanceService(
      name: 'Pay Bills',
      description: 'Electricity, water, internet bills',
      icon: Icons.receipt,
      color: const Color(0xFF00B14F),
    ),
    FinanceService(
      name: 'Send Money',
      description: 'Transfer to friends and family',
      icon: Icons.send,
      color: const Color(0xFF4A90E2),
    ),
    FinanceService(
      name: 'Top Up',
      description: 'Add money to your wallet',
      icon: Icons.add_circle,
      color: const Color(0xFFFF6B35),
    ),
    FinanceService(
      name: 'Pay Later',
      description: 'Buy now, pay later',
      icon: Icons.credit_card,
      color: const Color(0xFF9B59B6),
    ),
  ];

  final List<FinanceService> _investmentServices = [
    FinanceService(
      name: 'Savings',
      description: 'High yield savings account',
      icon: Icons.savings,
      color: const Color(0xFF00B14F),
    ),
    FinanceService(
      name: 'Investments',
      description: 'Stocks, bonds, and funds',
      icon: Icons.trending_up,
      color: const Color(0xFF4A90E2),
    ),
    FinanceService(
      name: 'Insurance',
      description: 'Health, life, and travel insurance',
      icon: Icons.security,
      color: const Color(0xFFFF6B35),
    ),
    FinanceService(
      name: 'Loans',
      description: 'Personal and business loans',
      icon: Icons.account_balance,
      color: const Color(0xFF9B59B6),
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
        title: const Text('Finance'),
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
                  'NovaGo Finance Balance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  r'$2,450.00',
                  style: TextStyle(
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
                          'Add Money',
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
                        icon: const Icon(Icons.send, color: Colors.white),
                        label: const Text(
                          'Send',
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
                  child: _buildTab('Payments', _selectedTab == 'Payments'),
                ),
                Expanded(
                  child: _buildTab('Investments', _selectedTab == 'Investments'),
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
      case 'Payments':
        return _buildPaymentsContent();
      case 'Investments':
        return _buildInvestmentsContent();
      default:
        return _buildPaymentsContent();
    }
  }

  Widget _buildPaymentsContent() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Payment Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _paymentServices.length,
            itemBuilder: (context, index) {
              final service = _paymentServices[index];
              return _buildServiceCard(service);
            },
          ),
        ),
      ],
    );

  Widget _buildInvestmentsContent() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Investment Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _investmentServices.length,
            itemBuilder: (context, index) {
              final service = _investmentServices[index];
              return _buildServiceCard(service);
            },
          ),
        ),
      ],
    );

  Widget _buildServiceCard(FinanceService service) => Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: service.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              service.icon,
              color: service.color,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            service.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            service.description,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
}

class FinanceService {

  FinanceService({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
  final String name;
  final String description;
  final IconData icon;
  final Color color;
}