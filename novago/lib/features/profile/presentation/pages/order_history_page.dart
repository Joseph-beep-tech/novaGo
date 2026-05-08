import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD-001',
      'date': '2024-01-15',
      'time': '14:30',
      'status': 'Delivered',
      'total': 45.99,
      'items': 3,
      'service': 'Food',
      'restaurant': 'Pizza Palace',
      'itemsList': ['Margherita Pizza', 'Caesar Salad', 'Coca Cola'],
      'rating': 5,
      'canReorder': true,
    },
    {
      'id': 'ORD-002',
      'date': '2024-01-14',
      'time': '19:45',
      'status': 'Delivered',
      'total': 28.50,
      'items': 2,
      'service': 'Grocery',
      'restaurant': 'FreshMart',
      'itemsList': ['Organic Bananas', 'Whole Milk'],
      'rating': 4,
      'canReorder': true,
    },
    {
      'id': 'ORD-003',
      'date': '2024-01-13',
      'time': '12:15',
      'status': 'Cancelled',
      'total': 15.75,
      'items': 1,
      'service': 'Ride',
      'restaurant': 'NovaGo Ride',
      'itemsList': ['Airport Transfer'],
      'rating': null,
      'canReorder': false,
    },
    {
      'id': 'ORD-004',
      'date': '2024-01-12',
      'time': '16:20',
      'status': 'Delivered',
      'total': 89.99,
      'items': 5,
      'service': 'Mart',
      'restaurant': 'TechStore',
      'itemsList': ['Wireless Headphones', 'Phone Case', 'Screen Protector', 'Charging Cable', 'Bluetooth Speaker'],
      'rating': 5,
      'canReorder': true,
    },
    {
      'id': 'ORD-005',
      'date': '2024-01-11',
      'time': '10:30',
      'status': 'In Transit',
      'total': 32.00,
      'items': 2,
      'service': 'Express',
      'restaurant': 'QuickCourier',
      'itemsList': ['Document Package', 'Gift Box'],
      'rating': null,
      'canReorder': false,
    },
    {
      'id': 'ORD-006',
      'date': '2024-01-10',
      'time': '20:00',
      'status': 'Delivered',
      'total': 67.25,
      'items': 4,
      'service': 'Fresh',
      'restaurant': 'Green Valley Farm',
      'itemsList': ['Organic Avocados', 'Farm Fresh Strawberries', 'Local Honey', 'Seasonal Pumpkins'],
      'rating': 4,
      'canReorder': true,
    },
  ];

  final List<String> _filters = ['All', 'Food', 'Grocery', 'Ride', 'Mart', 'Express', 'Fresh'];

  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedFilter == 'All') {
      return _orders;
    }
    return _orders.where((order) => order['service'] == _selectedFilter).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'In Transit':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      case 'Processing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getServiceIcon(String service) {
    switch (service) {
      case 'Food':
        return Icons.restaurant;
      case 'Grocery':
        return Icons.shopping_cart;
      case 'Ride':
        return Icons.local_taxi;
      case 'Mart':
        return Icons.store;
      case 'Express':
        return Icons.local_shipping;
      case 'Fresh':
        return Icons.eco;
      default:
        return Icons.shopping_bag;
    }
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
          'Order History',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () => _showFilterOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search orders...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: const Color(0xFF00B14F).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF00B14F),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF00B14F) : Colors.grey[600],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          // Orders List
          Expanded(
            child: _filteredOrders.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No orders found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your order history will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];
                      return _buildOrderCard(order);
                    },
                  ),
          ),
        ],
      ),
    );

  Widget _buildOrderCard(Map<String, dynamic> order) => Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getServiceIcon(order['service']),
                        color: _getStatusColor(order['status']),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['id'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${order['date']} at ${order['time']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order['status'],
                    style: TextStyle(
                      color: _getStatusColor(order['status']),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Service and Restaurant
            Row(
              children: [
                Icon(Icons.store, color: Colors.grey[600], size: 16),
                const SizedBox(width: 4),
                Text(
                  order['restaurant'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.category, color: Colors.grey[600], size: 16),
                const SizedBox(width: 4),
                Text(
                  order['service'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Items
            Text(
              '${order['items']} item${order['items'] > 1 ? 's' : ''}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            ...order['itemsList'].take(2).map<Widget>((item) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '• $item',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            )),
            if (order['items'] > 2)
              Text(
                '• +${order['items'] - 2} more items',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            
            const SizedBox(height: 12),
            
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${order['total'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF00B14F),
                  ),
                ),
                Row(
                  children: [
                    if (order['rating'] != null)
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${order['rating']}/5',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    // Show Track Order for active orders
                    if (order['status'] != 'Delivered' && order['status'] != 'Cancelled' && order['service'] == 'Food')
                      ElevatedButton(
                        onPressed: () {
                          context.push('/order-tracking/${order['id']}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B14F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Track Order',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      )
                    else if (order['canReorder'])
                      ElevatedButton(
                        onPressed: () => _reorderItems(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B14F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Reorder',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: () => _viewOrderDetails(order),
                        child: const Text(
                          'View Details',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );

  void _reorderItems(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reorder ${order['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Restaurant: ${order['restaurant']}'),
            Text('Items: ${order['items']}'),
            Text('Total: \$${order['total'].toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text('Add these items to your cart?'),
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
                  content: Text('${order['items']} items added to cart'),
                  backgroundColor: const Color(0xFF00B14F),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B14F),
            ),
            child: const Text('Add to Cart'),
          ),
        ],
      ),
    );
  }

  void _viewOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
                  Text(
                    'Order ${order['id']}',
                    style: const TextStyle(
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Order ID', order['id']),
                    _buildDetailRow('Date & Time', '${order['date']} at ${order['time']}'),
                    _buildDetailRow('Status', order['status']),
                    _buildDetailRow('Service', order['service']),
                    _buildDetailRow('Restaurant', order['restaurant']),
                    _buildDetailRow('Total Items', '${order['items']}'),
                    _buildDetailRow('Total Amount', '\$${order['total'].toStringAsFixed(2)}'),
                    if (order['rating'] != null)
                      _buildDetailRow('Rating', '${order['rating']}/5 stars'),
                    
                    const SizedBox(height: 20),
                    const Text(
                      'Items Ordered:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...order['itemsList'].map<Widget>((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $item'),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

  void _showFilterOptions(BuildContext context) {
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
              'Filter Orders',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ..._filters.map((filter) => ListTile(
              title: Text(filter),
              trailing: _selectedFilter == filter
                  ? const Icon(Icons.check, color: Color(0xFF00B14F))
                  : null,
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }
}
