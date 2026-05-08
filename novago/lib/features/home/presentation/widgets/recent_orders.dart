import 'package:flutter/material.dart';

class RecentOrders extends StatelessWidget {
  const RecentOrders({super.key});

  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to order history
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF00B14F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) => _buildOrderCard(index),
            ),
          ),
        ],
      ),
    );

  Widget _buildOrderCard(int index) {
    final orders = [
      {
        'title': "McDonald's",
        'status': 'Delivered',
        'time': '2 hours ago',
        'icon': Icons.restaurant,
        'color': const Color(0xFF00B14F),
      },
      {
        'title': 'Grab Ride',
        'status': 'Completed',
        'time': 'Yesterday',
        'icon': Icons.local_taxi,
        'color': const Color(0xFF4A90E2),
      },
      {
        'title': 'Grocery Order',
        'status': 'Delivered',
        'time': '2 days ago',
        'icon': Icons.shopping_cart,
        'color': const Color(0xFFFF6B35),
      },
    ];

    final order = orders[index];

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (order['color']! as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              order['icon']! as IconData,
              color: order['color']! as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  order['title']! as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order['status']! as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF00B14F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order['time']! as String,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
