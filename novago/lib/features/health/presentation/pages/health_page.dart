import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  int _cartItemCount = 0;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.apps, 'color': const Color(0xFF3498DB)},
    {'name': 'Pharmacy', 'icon': Icons.local_pharmacy, 'color': const Color(0xFFE74C3C)},
    {'name': 'Doctors', 'icon': Icons.medical_services, 'color': const Color(0xFF3498DB)},
    {'name': 'Lab Tests', 'icon': Icons.science, 'color': const Color(0xFF9B59B6)},
    {'name': 'Emergency', 'icon': Icons.emergency, 'color': const Color(0xFFE74C3C)},
    {'name': 'Wellness', 'icon': Icons.favorite, 'color': const Color(0xFFE91E63)},
  ];

  final List<Map<String, dynamic>> _services = [
    {
      'name': 'Dr. Sarah Johnson',
      'specialty': 'General Physician',
      'rating': 4.8,
      'reviews': 156,
      'price': 120,
      'image': '👩‍⚕️',
      'category': 'Doctors',
      'available': true,
      'nextAvailable': 'Today 2:00 PM',
      'experience': '8 years',
    },
    {
      'name': 'MediCare Pharmacy',
      'specialty': '24/7 Pharmacy',
      'rating': 4.6,
      'reviews': 89,
      'price': 0,
      'image': '💊',
      'category': 'Pharmacy',
      'available': true,
      'nextAvailable': 'Open Now',
      'experience': 'Delivery in 30 min',
    },
    {
      'name': 'Blood Test Package',
      'specialty': 'Complete Blood Count',
      'rating': 4.7,
      'reviews': 203,
      'price': 45,
      'image': '🩸',
      'category': 'Lab Tests',
      'available': true,
      'nextAvailable': 'Tomorrow 9:00 AM',
      'experience': 'Home collection',
    },
    {
      'name': 'Emergency Care',
      'specialty': '24/7 Emergency',
      'rating': 4.9,
      'reviews': 67,
      'price': 0,
      'image': '🚑',
      'category': 'Emergency',
      'available': true,
      'nextAvailable': 'Immediate',
      'experience': 'Ambulance service',
    },
    {
      'name': 'Dr. Michael Chen',
      'specialty': 'Cardiologist',
      'rating': 4.9,
      'reviews': 134,
      'price': 200,
      'image': '👨‍⚕️',
      'category': 'Doctors',
      'available': false,
      'nextAvailable': 'Monday 10:00 AM',
      'experience': '15 years',
    },
    {
      'name': 'Wellness Checkup',
      'specialty': 'Annual Health Check',
      'rating': 4.5,
      'reviews': 78,
      'price': 150,
      'image': '💚',
      'category': 'Wellness',
      'available': true,
      'nextAvailable': 'This week',
      'experience': 'Comprehensive',
    },
    {
      'name': 'HealthMart Pharmacy',
      'specialty': 'Prescription Drugs',
      'rating': 4.4,
      'reviews': 92,
      'price': 0,
      'image': '🏥',
      'category': 'Pharmacy',
      'available': true,
      'nextAvailable': 'Open Now',
      'experience': 'Discounts available',
    },
    {
      'name': 'COVID-19 Test',
      'specialty': 'RT-PCR Test',
      'rating': 4.6,
      'reviews': 156,
      'price': 80,
      'image': '🦠',
      'category': 'Lab Tests',
      'available': true,
      'nextAvailable': 'Today 3:00 PM',
      'experience': 'Results in 24h',
    },
  ];

  List<Map<String, dynamic>> get _filteredServices {
    if (_selectedCategory == 'All') {
      return _services;
    }
    return _services.where((service) => service['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          'Health',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.black),
                onPressed: () => _showCart(context),
              ),
              if (_cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Emergency Banner
          Container(
            height: 80,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.emergency,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Medical Emergency?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Call 911 or use emergency services',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showEmergencyOptions(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFE74C3C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Emergency',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search doctors, medicines, tests...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.grey),
                  onPressed: () => _showFilters(context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          
          // Categories
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category['name'];
                
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['name'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? category['color'] : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? category['color'] : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category['icon'],
                            color: isSelected ? Colors.white : category['color'],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            category['name'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : category['color'],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Services List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredServices.length,
              itemBuilder: (context, index) {
                final service = _filteredServices[index];
                return _buildServiceCard(service);
              },
            ),
          ),
        ],
      ),
    );

  Widget _buildServiceCard(Map<String, dynamic> service) => Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Service Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getCategoryColor(service['category']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  service['image'],
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Service Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service['specialty'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Rating and Experience
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${service['rating']} (${service['reviews']})',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.work, color: Colors.grey[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        service['experience'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Availability
                  Row(
                    children: [
                      Icon(
                        service['available'] ? Icons.check_circle : Icons.schedule,
                        color: service['available'] ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        service['nextAvailable'],
                        style: TextStyle(
                          color: service['available'] ? Colors.green : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Price and Action
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (service['price'] > 0)
                  Text(
                    '\$${service['price']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF3498DB),
                    ),
                  )
                else
                  const Text(
                    'Free',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF27AE60),
                    ),
                  ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: service['available'] ? () => _bookService(service) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getCategoryColor(service['category']),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    service['category'] == 'Pharmacy' ? 'Order' : 
                    service['category'] == 'Emergency' ? 'Call' : 'Book',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pharmacy':
        return const Color(0xFFE74C3C);
      case 'Doctors':
        return const Color(0xFF3498DB);
      case 'Lab Tests':
        return const Color(0xFF9B59B6);
      case 'Emergency':
        return const Color(0xFFE74C3C);
      case 'Wellness':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF3498DB);
    }
  }

  void _bookService(Map<String, dynamic> service) {
    setState(() {
      _cartItemCount++;
    });
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book ${service['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Specialty: ${service['specialty']}'),
            Text('Price: \$${service['price']}'),
            Text('Next Available: ${service['nextAvailable']}'),
            const SizedBox(height: 16),
            const Text('Would you like to proceed with booking?'),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${service['name']} booked successfully!'),
                  backgroundColor: const Color(0xFF3498DB),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
            ),
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Emergency Services',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildEmergencyOption(
              'Call 911',
              'Emergency Services',
              Icons.phone,
              Colors.red,
              () => Navigator.pop(context),
            ),
            _buildEmergencyOption(
              'Nearest Hospital',
              'Find closest hospital',
              Icons.local_hospital,
              Colors.blue,
              () => Navigator.pop(context),
            ),
            _buildEmergencyOption(
              'Ambulance',
              'Request ambulance',
              Icons.airport_shuttle,
              Colors.orange,
              () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyOption(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) => ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );

  void _showCart(BuildContext context) {
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
                    'Health Cart',
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
              child: _cartItemCount == 0
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.medical_services, size: 64, color: Color(0xFF3498DB)),
                          SizedBox(height: 16),
                          Text(
                            'Your health cart is empty',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Book appointments or order medicines',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _cartItemCount,
                      itemBuilder: (context, index) => ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF3498DB),
                          child: Icon(Icons.medical_services, color: Colors.white),
                        ),
                        title: Text('Health Service ${index + 1}'),
                        subtitle: const Text(r'$120.00'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            setState(() {
                              _cartItemCount--;
                            });
                            Navigator.pop(context);
                            _showCart(context);
                          },
                        ),
                      ),
                    ),
            ),
            if (_cartItemCount > 0)
              Container(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/checkout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498DB),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Health Filters',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const ListTile(
              title: Text('Available Now'),
              subtitle: Text('Show only available services'),
              trailing: Switch(value: true, onChanged: null),
            ),
            const ListTile(
              title: Text('Price Range'),
              subtitle: Text(r'$0 - $500'),
            ),
            const ListTile(
              title: Text('Rating'),
              subtitle: Text('4+ stars'),
            ),
            const ListTile(
              title: Text('Distance'),
              subtitle: Text('Within 10 km'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498DB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
