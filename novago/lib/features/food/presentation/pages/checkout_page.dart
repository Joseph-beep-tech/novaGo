import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPaymentMethod = 'wallet';
  String _selectedDeliveryTime = 'ASAP';
  final TextEditingController _notesController = TextEditingController();

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'wallet',
      name: 'NovaGo Wallet',
      icon: Icons.account_balance_wallet,
      color: const Color(0xFF00B14F),
      balance: 245.50,
    ),
    PaymentMethod(
      id: 'card',
      name: 'Credit Card',
      icon: Icons.credit_card,
      color: const Color(0xFF4A90E2),
    ),
    PaymentMethod(
      id: 'cash',
      name: 'Cash on Delivery',
      icon: Icons.money,
      color: const Color(0xFFF39C12),
    ),
  ];

  final List<String> _deliveryTimes = [
    'ASAP (30-45 min)',
    '1 hour',
    '2 hours',
    'Schedule for later',
  ];

  final List<OrderItem> _orderItems = [
    OrderItem(
      name: 'Chicken Burger',
      restaurant: 'Burger Palace',
      price: 12.99,
      quantity: 2,
      image: '🍔',
    ),
    OrderItem(
      name: 'Margherita Pizza',
      restaurant: 'Pizza Corner',
      price: 15.99,
      quantity: 1,
      image: '🍕',
    ),
    OrderItem(
      name: 'Caesar Salad',
      restaurant: 'Healthy Bites',
      price: 8.99,
      quantity: 1,
      image: '🥗',
    ),
  ];

  double get _subtotal => _orderItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get _deliveryFee => 2.99;
  double get _tax => _subtotal * 0.08;
  double get _total => _subtotal + _deliveryFee + _tax;

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
            } else {
              // Fallback if checkout was opened with context.go
              context.go('/cart');
            }
          },
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Delivery Address
            _buildSection(
              'Delivery Address',
              Icons.location_on,
              const Color(0xFF00B14F),
              _buildDeliveryAddress(),
            ),

            // Order Items
            _buildSection(
              'Order Items',
              Icons.restaurant,
              const Color(0xFF4A90E2),
              _buildOrderItems(),
            ),

            // Delivery Time
            _buildSection(
              'Delivery Time',
              Icons.access_time,
              const Color(0xFFFF6B35),
              _buildDeliveryTime(),
            ),

            // Payment Method
            _buildSection(
              'Payment Method',
              Icons.payment,
              const Color(0xFF9B59B6),
              _buildPaymentMethods(),
            ),

            // Special Instructions
            _buildSection(
              'Special Instructions',
              Icons.note,
              const Color(0xFFE74C3C),
              _buildSpecialInstructions(),
            ),

            // Order Summary
            _buildSection(
              'Order Summary',
              Icons.receipt,
              const Color(0xFF3498DB),
              _buildOrderSummary(),
            ),

            const SizedBox(height: 20),

            // Place Order Button
            Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B14F),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Place Order',
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

  Widget _buildSection(String title, IconData icon, Color color, Widget content) => Container(
      margin: const EdgeInsets.all(16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          content,
        ],
      ),
    );

  Widget _buildDeliveryAddress() => Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'John Doe',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '123 Main Street, Apt 4B',
            style: TextStyle(fontSize: 14),
          ),
          const Text(
            'New York, NY 10001',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Change Address'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF00B14F),
            ),
          ),
        ],
      ),
    );

  Widget _buildOrderItems() => Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: _orderItems.map(_buildOrderItem).toList(),
      ),
    );

  Widget _buildOrderItem(OrderItem item) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                item.image,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  item.restaurant,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item.quantity}x',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00B14F),
            ),
          ),
        ],
      ),
    );

  Widget _buildDeliveryTime() => Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: _deliveryTimes.map((time) => RadioListTile<String>(
            title: Text(time),
            value: time,
            groupValue: _selectedDeliveryTime,
            onChanged: (value) {
              setState(() {
                _selectedDeliveryTime = value!;
              });
            },
            activeColor: const Color(0xFFFF6B35),
            contentPadding: EdgeInsets.zero,
          )).toList(),
      ),
    );

  Widget _buildPaymentMethods() => Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: _paymentMethods.map((method) => RadioListTile<String>(
            title: Row(
              children: [
                Icon(method.icon, color: method.color, size: 20),
                const SizedBox(width: 8),
                Text(method.name),
                if (method.balance != null) ...[
                  const Spacer(),
                  Text(
                    '\$${method.balance!.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            value: method.id,
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            activeColor: const Color(0xFF9B59B6),
            contentPadding: EdgeInsets.zero,
          )).toList(),
      ),
    );

  Widget _buildSpecialInstructions() => Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: _notesController,
        decoration: const InputDecoration(
          hintText: 'Any special instructions for the restaurant?',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(12),
        ),
        maxLines: 3,
      ),
    );

  Widget _buildOrderSummary() => Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', _subtotal),
          _buildSummaryRow('Delivery Fee', _deliveryFee),
          _buildSummaryRow('Tax', _tax),
          const Divider(),
          _buildSummaryRow('Total', _total, isTotal: true),
        ],
      ),
    );

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? const Color(0xFF00B14F) : Colors.black,
            ),
          ),
        ],
      ),
    );

  void _placeOrder() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Order Placed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text('Your order has been placed successfully!'),
            const SizedBox(height: 8),
            Text(
              'Order ID: #${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF00B14F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Estimated delivery: $_selectedDeliveryTime',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to order tracking page with order ID
              context.push('/order-tracking/ORD-001');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B14F),
            ),
            child: const Text('Track Order', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class PaymentMethod {

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.balance,
  });
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final double? balance;
}

class OrderItem {

  OrderItem({
    required this.name,
    required this.restaurant,
    required this.price,
    required this.quantity,
    required this.image,
  });
  final String name;
  final String restaurant;
  final double price;
  final int quantity;
  final String image;
}