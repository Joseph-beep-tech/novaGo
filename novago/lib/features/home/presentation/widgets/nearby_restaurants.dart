import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NearbyRestaurants extends StatelessWidget {
  const NearbyRestaurants({super.key});

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
                'Nearby Restaurants',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/restaurants'),
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
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) => _buildRestaurantCard(index),
            ),
          ),
        ],
      ),
    );

  Widget _buildRestaurantCard(int index) {
    final restaurants = [
      {
        'name': "McDonald's",
        'rating': '4.5',
        'deliveryTime': '15-20 min',
        'image': '🍔',
      },
      {
        'name': 'KFC',
        'rating': '4.3',
        'deliveryTime': '20-25 min',
        'image': '🍗',
      },
      {
        'name': 'Pizza Hut',
        'rating': '4.4',
        'deliveryTime': '25-30 min',
        'image': '🍕',
      },
      {
        'name': 'Subway',
        'rating': '4.2',
        'deliveryTime': '10-15 min',
        'image': '🥪',
      },
      {
        'name': 'Starbucks',
        'rating': '4.6',
        'deliveryTime': '15-20 min',
        'image': '☕',
      },
    ];

    final restaurant = restaurants[index];

    return Container(
      width: 160,
      height: 160,
      margin: const EdgeInsets.only(right: 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF00B14F).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                restaurant['image']!,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    restaurant['name']!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 12,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        restaurant['rating']!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    restaurant['deliveryTime']!,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF00B14F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}