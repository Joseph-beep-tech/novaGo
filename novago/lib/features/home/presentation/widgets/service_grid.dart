import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ServiceGrid extends StatelessWidget {
  const ServiceGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      ServiceItem(
        icon: Icons.restaurant,
        title: 'Food',
        subtitle: 'Delivery',
        color: const Color(0xFF00B14F),
        onTap: () => context.go('/restaurants'),
      ),
      ServiceItem(
        icon: Icons.local_taxi,
        title: 'Ride',
        subtitle: 'Hailing',
        color: const Color(0xFF4A90E2),
        onTap: () => context.go('/ride-booking'),
      ),
      ServiceItem(
        icon: Icons.shopping_cart,
        title: 'Grocery',
        subtitle: 'Delivery',
        color: const Color(0xFFFF6B35),
        onTap: () => context.go('/grocery'),
      ),
      ServiceItem(
        icon: Icons.local_shipping,
        title: 'Express',
        subtitle: 'Courier',
        color: const Color(0xFF9B59B6),
        onTap: () => context.go('/courier'),
      ),
      ServiceItem(
        icon: Icons.store,
        title: 'Mart',
        subtitle: 'Marketplace',
        color: const Color(0xFFE74C3C),
        onTap: () => context.go('/mart'),
      ),
      ServiceItem(
        icon: Icons.eco,
        title: 'Fresh',
        subtitle: 'Grocery',
        color: const Color(0xFF27AE60),
        onTap: () => context.go('/fresh'),
      ),
      ServiceItem(
        icon: Icons.health_and_safety,
        title: 'Health',
        subtitle: 'Services',
        color: const Color(0xFF3498DB),
        onTap: () => context.go('/health'),
      ),
      ServiceItem(
        icon: Icons.account_balance,
        title: 'Finance',
        subtitle: 'Payments',
        color: const Color(0xFFF39C12),
        onTap: () => context.go('/finance'),
      ),
      ServiceItem(
        icon: Icons.card_giftcard,
        title: 'Rewards',
        subtitle: 'Program',
        color: const Color(0xFFE91E63),
        onTap: () => context.go('/rewards'),
      ),
      ServiceItem(
        icon: Icons.receipt,
        title: 'Bills',
        subtitle: 'Payment',
        color: const Color(0xFF795548),
        onTap: () => context.go('/bills'),
      ),
      ServiceItem(
        icon: Icons.games,
        title: 'Games',
        subtitle: 'Entertainment',
        color: const Color(0xFF607D8B),
        onTap: () => context.go('/games'),
      ),
      ServiceItem(
        icon: Icons.more_horiz,
        title: 'More',
        subtitle: 'Services',
        color: const Color(0xFF9E9E9E),
        onTap: () => context.go('/more-services'),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.8,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return _buildServiceItem(service);
        },
      ),
    );
  }

  Widget _buildServiceItem(ServiceItem service) => GestureDetector(
      onTap: service.onTap,
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: service.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                service.icon,
                color: service.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              service.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              service.subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
}

class ServiceItem {

  ServiceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
}