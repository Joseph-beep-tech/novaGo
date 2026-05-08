import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/restaurant.dart';
import '../../../../core/models/menu_item.dart';
import '../../../../core/api/services/restaurant_service.dart';
import '../../../../core/api/services/menu_service.dart';
import '../../../../core/api/services/order_service.dart';

class RestaurantDetailPage extends StatefulWidget {
  
  const RestaurantDetailPage({
    required this.restaurantId, super.key,
  });
  final String restaurantId;

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'Popular';
  
  final RestaurantService _restaurantService = RestaurantService();
  final MenuService _menuService = MenuService();
  final OrderService _orderService = OrderService();
  
  Restaurant? _restaurant;
  List<MenuItem> _menuItems = [];
  final Map<String, int> _cart = {};
  bool _isPlacingOrder = false;
  bool _isLoading = true;
  bool _isLoadingMenu = true;
  String? _errorMessage;
  List<String> _categories = ['Popular'];

  // Reviews placeholder - will be replaced with API data when available
  final List<Map<String, dynamic>> _reviews = [
    {
      'userName': 'John Doe',
      'rating': 5,
      'date': '2 days ago',
      'comment': 'Amazing pizza! The crust was perfect and the toppings were fresh.',
      'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=40&h=40&fit=crop&crop=face',
    },
    {
      'userName': 'Sarah Wilson',
      'rating': 4,
      'date': '1 week ago',
      'comment': 'Great food and fast delivery. The Caesar salad was delicious.',
      'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=40&h=40&fit=crop&crop=face',
    },
    {
      'userName': 'Mike Johnson',
      'rating': 5,
      'date': '2 weeks ago',
      'comment': 'Best Italian restaurant in the area. Highly recommended!',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=40&h=40&fit=crop&crop=face',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRestaurantData();
    _loadMenuData();
  }
  
  Future<void> _loadRestaurantData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      print('Loading restaurant ${widget.restaurantId} from API...');
      final restaurant = await _restaurantService.getRestaurant(widget.restaurantId);
      print('✅ Loaded restaurant: ${restaurant.name}');
      
      setState(() {
        _restaurant = restaurant;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading restaurant: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadMenuData() async {
    setState(() {
      _isLoadingMenu = true;
    });
    
    try {
      print('Loading menu for restaurant ${widget.restaurantId}...');
      final menuItems = await _menuService.getRestaurantMenu(widget.restaurantId);
      print('✅ Loaded ${menuItems.length} menu items');
      
      // Extract unique categories from menu items
      final categories = menuItems.map((item) => item.category).toSet().toList();
      categories.insert(0, 'Popular'); // Add Popular at the beginning
      
      setState(() {
        _menuItems = menuItems;
        _categories = categories;
        _isLoadingMenu = false;
      });
    } catch (e) {
      print('❌ Error loading menu: $e');
      setState(() {
        _isLoadingMenu = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<MenuItem> get _filteredMenuItems {
    if (_selectedCategory == 'Popular') {
      // Show items with highest rating or price as popular
      final popular = _menuItems.toList();
      popular.sort((a, b) {
        final aRating = a.rating ?? 0.0;
        final bRating = b.rating ?? 0.0;
        return bRating.compareTo(aRating);
      });
      return popular.take(5).toList();
    }
    return _menuItems.where((item) => item.category == _selectedCategory).toList();
  }

  double get _cartSubtotal {
    double total = 0;
    _cart.forEach((id, qty) {
      final item = _menuItems.firstWhere(
        (m) => m.id == id,
        orElse: () => MenuItem(
          id: id,
          restaurantId: _restaurant?.id ?? '',
          name: 'Item',
          price: 0,
          imageUrl: '',
          category: 'Unknown',
        ),
      );
      total += item.price * qty;
    });
    return total;
  }

  double get _deliveryFee => _restaurant?.deliveryFee ?? 0;

  double get _estimatedTax => _cartSubtotal * 0.08;

  double get _cartTotal => _cartSubtotal + _deliveryFee + _estimatedTax;

  String get _estimatedEtaText {
    // Use restaurant delivery time text if available; otherwise fallback
    if (_restaurant?.deliveryTime.isNotEmpty == true) {
      return _restaurant!.deliveryTime;
    }
    return '25-35 min';
  }

  String get _currencySymbol => _restaurant?.currencySymbol?.isNotEmpty == true ? _restaurant!.currencySymbol! : 'KSh';

  @override
  Widget build(BuildContext context) {
    // Show loading or error state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_errorMessage != null || _restaurant == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Error loading restaurant',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Restaurant not found',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadRestaurantData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      bottomNavigationBar: _cart.isEmpty ? null : _buildCartBar(),
      body: CustomScrollView(
        slivers: [
          // App Bar with Restaurant Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  // If no route to pop, navigate to restaurant list
                  context.go('/restaurants');
                }
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: _toggleFavorite,
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: _shareRestaurant,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _restaurant!.fullImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.restaurant, size: 64, color: Colors.grey),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _restaurant!.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _restaurant!.cuisine,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${_restaurant!.rating} (${_restaurant!.reviewCount} reviews)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time, color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _restaurant!.deliveryTime,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Restaurant Info Card
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'Delivery Fee',
                          '$_currencySymbol${_restaurant!.deliveryFee.toStringAsFixed(2)}',
                          Icons.delivery_dining,
                          const Color(0xFF00B14F),
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'Min Order',
                          '$_currencySymbol${_restaurant!.minOrder.toStringAsFixed(2)}',
                          Icons.shopping_cart,
                          const Color(0xFF4A90E2),
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'Rating',
                          '${_restaurant!.rating}',
                          Icons.star,
                          const Color(0xFFFF6B35),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _restaurant!.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _restaurant!.address,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_restaurant!.phone.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.grey, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _restaurant!.phone,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_restaurant!.hours.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.grey, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _restaurant!.hours,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Features
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _restaurant!.features.map<Widget>((feature) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B14F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    feature,
                    style: const TextStyle(
                      color: Color(0xFF00B14F),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Tab Bar
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF00B14F),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF00B14F),
                tabs: const [
                  Tab(text: 'Menu'),
                  Tab(text: 'Reviews'),
                  Tab(text: 'Info'),
                ],
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMenuTab(),
                _buildReviewsTab(),
                _buildInfoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) => Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );

  Widget _buildMenuTab() => Column(
      children: [
        // Category Filter
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
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

        // Menu Items
        Expanded(
          child: _isLoadingMenu
              ? const Center(child: CircularProgressIndicator())
              : _filteredMenuItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No menu items found',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try selecting a different category',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredMenuItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredMenuItems[index];
                        return _buildMenuItem(item);
                      },
                    ),
        ),
      ],
    );

  Widget _buildCartBar() => SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(20, 0, 0, 0),
              blurRadius: 6,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_cart.values.fold<int>(0, (sum, qty) => sum + qty)} item(s) · $_currencySymbol${_cartTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Est. delivery $_estimatedEtaText',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isPlacingOrder ? null : _showCheckoutSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B14F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isPlacingOrder
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Checkout',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );

  Widget _buildMenuItem(MenuItem item) => Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.fullImageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant_menu, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (item.isVegetarian ?? false)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'V',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_currencySymbol${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00B14F),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _addToCart(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B14F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

  Widget _buildReviewsTab() => ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(review['avatar']),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review['userName'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ...List.generate(5, (index) => Icon(
                              index < review['rating'] ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            )),
                            const SizedBox(width: 8),
                            Text(
                              review['date'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                review['comment'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        );
      },
    );

  Widget _buildInfoTab() => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('Restaurant Information', [
            _buildInfoRow('Name', _restaurant!.name),
            _buildInfoRow('Cuisine', _restaurant!.cuisine),
            _buildInfoRow('Address', _restaurant!.address),
            if (_restaurant!.phone.isNotEmpty)
              _buildInfoRow('Phone', _restaurant!.phone),
            if (_restaurant!.hours.isNotEmpty)
              _buildInfoRow('Hours', _restaurant!.hours),
          ]),
          const SizedBox(height: 20),
          _buildInfoSection('Delivery Information', [
            _buildInfoRow('Delivery Time', _restaurant!.deliveryTime),
            _buildInfoRow('Delivery Fee', '$_currencySymbol${_restaurant!.deliveryFee.toStringAsFixed(2)}'),
            _buildInfoRow('Minimum Order', '$_currencySymbol${_restaurant!.minOrder.toStringAsFixed(2)}'),
          ]),
          if (_restaurant!.features.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildInfoSection('Features', [
              ..._restaurant!.features.map<Widget>((feature) => _buildInfoRow('•', feature)),
            ]),
          ],
        ],
      ),
    );

  Widget _buildInfoSection(String title, List<Widget> children) => Container(
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );

  Widget _buildInfoRow(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
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

  void _addToCart(MenuItem item) {
    setState(() {
      _cart.update(item.id, (qty) => qty + 1, ifAbsent: () => 1);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to cart'),
        backgroundColor: const Color(0xFF00B14F),
      ),
    );
  }

  void _updateQuantity(String itemId, int delta) {
    setState(() {
      final current = _cart[itemId] ?? 0;
      final next = current + delta;
      if (next <= 0) {
        _cart.remove(itemId);
      } else {
        _cart[itemId] = next;
      }
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
    });
  }

  Future<void> _showCheckoutSheet() async {
    if (_restaurant == null || _cart.isEmpty) return;

    final nameController = TextEditingController(text: 'Guest');
    final phoneController = TextEditingController(text: '+1 (555) 123-4567');
    final addressController = TextEditingController(text: _restaurant!.address);

    try {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (sheetContext) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Checkout',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._cart.entries.map((entry) {
                  final item = _menuItems.firstWhere(
                    (m) => m.id == entry.key,
                    orElse: () => MenuItem(
                      id: entry.key,
                      restaurantId: _restaurant!.id,
                      name: 'Item',
                      price: 0,
                      imageUrl: '',
                      category: 'Unknown',
                    ),
                  );
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$_currencySymbol${item.price.toStringAsFixed(2)} each',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _updateQuantity(item.id, -1),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text(
                              '${entry.value}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: () => _updateQuantity(item.id, 1),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(),
                _summaryRow('Items', _cartSubtotal),
                _summaryRow('Delivery', _deliveryFee),
                _summaryRow('Tax (est.)', _estimatedTax),
                _summaryRow('Total due', _cartTotal, isBold: true),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Estimated delivery $_estimatedEtaText',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Transparent pricing: items + delivery + tax shown above',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Customer name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Delivery address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isPlacingOrder
                        ? null
                        : () async {
                            await _submitOrder(
                              name: nameController.text.trim(),
                              phone: phoneController.text.trim(),
                              address: addressController.text.trim(),
                              onSuccess: () {
                                Navigator.of(sheetContext).pop();
                              },
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B14F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isPlacingOrder
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Column(
                            children: [
                              Text(
                                'One-tap checkout',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '$_currencySymbol${_cartTotal.toStringAsFixed(2)} · $_estimatedEtaText',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } finally {
      nameController.dispose();
      phoneController.dispose();
      addressController.dispose();
    }
  }

  Widget _summaryRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const Spacer(),
          Text(
            '$_currencySymbol${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitOrder({
    required String name,
    required String phone,
    required String address,
    required VoidCallback onSuccess,
  }) async {
    if (_restaurant == null || _cart.isEmpty) return;

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final items = _cart.entries
          .map((entry) => {
                'menuItemId': entry.key,
                'quantity': entry.value,
              })
          .toList();

      final order = await _orderService.createOrder(
        restaurantId: _restaurant!.id,
        customerName: name.isEmpty ? 'Guest' : name,
        customerPhone: phone.isEmpty ? null : phone,
        deliveryAddress: address.isEmpty ? _restaurant!.address : address,
        items: items,
      );

      if (!mounted) return;
      onSuccess();
      _clearCart();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order ${order.id} placed successfully'),
          backgroundColor: const Color(0xFF00B14F),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  void _toggleFavorite() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to favorites'),
        backgroundColor: Color(0xFF00B14F),
      ),
    );
  }

  void _shareRestaurant() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Restaurant details shared!'),
        backgroundColor: Color(0xFF00B14F),
      ),
    );
  }
}
