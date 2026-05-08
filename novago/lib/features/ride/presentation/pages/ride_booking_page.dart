import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RideBookingPage extends StatefulWidget {
  const RideBookingPage({super.key});

  @override
  State<RideBookingPage> createState() => _RideBookingPageState();
}

class _RideBookingPageState extends State<RideBookingPage> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  String _selectedRideType = 'GrabCar';
  int _selectedPassengers = 1;

  final List<RideType> _rideTypes = [
    RideType(
      name: 'GrabCar',
      description: 'Comfortable ride for up to 4 passengers',
      price: r'$8.50',
      estimatedTime: '5-8 min',
      icon: Icons.directions_car,
      color: const Color(0xFF00B14F),
    ),
    RideType(
      name: 'GrabCar Plus',
      description: 'Premium ride with extra comfort',
      price: r'$12.50',
      estimatedTime: '3-5 min',
      icon: Icons.directions_car,
      color: const Color(0xFF4A90E2),
    ),
    RideType(
      name: 'GrabBike',
      description: 'Fast and affordable motorcycle ride',
      price: r'$3.50',
      estimatedTime: '2-4 min',
      icon: Icons.motorcycle,
      color: const Color(0xFFFF6B35),
    ),
    RideType(
      name: 'GrabShare',
      description: 'Share your ride and save money',
      price: r'$6.50',
      estimatedTime: '8-12 min',
      icon: Icons.people,
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
        title: const Text('Book a Ride'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map placeholder
            Container(
              height: 300,
              color: Colors.grey[300],
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Interactive Map',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Current location button
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.white,
                      onPressed: () {},
                      child: const Icon(
                        Icons.my_location,
                        color: Color(0xFF00B14F),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Location inputs
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Pickup location
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00B14F),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _pickupController,
                            decoration: const InputDecoration(
                              hintText: 'Pickup location',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.my_location, color: Color(0xFF00B14F)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Destination location
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _destinationController,
                            decoration: const InputDecoration(
                              hintText: 'Where to?',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.search, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Passenger count
                  Row(
                    children: [
                      const Text(
                        'Passengers:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _selectedPassengers > 1
                                  ? () {
                                      setState(() {
                                        _selectedPassengers--;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Container(
                              width: 40,
                              alignment: Alignment.center,
                              child: Text(
                                _selectedPassengers.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _selectedPassengers < 4
                                  ? () {
                                      setState(() {
                                        _selectedPassengers++;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Ride types section
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Text(
                      'Choose your ride',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Select the ride option that best fits your needs',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Ride types list
                  ..._rideTypes.map((rideType) {
                    final isSelected = rideType.name == _selectedRideType;
                    return _buildRideTypeCard(rideType, isSelected);
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Book button
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showBookingConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B14F),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Bottom padding for safe scrolling
          ],
        ),
      ),
    );

  Widget _buildRideTypeCard(RideType rideType, bool isSelected) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00B14F).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF00B14F) : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _selectedRideType = rideType.name;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: rideType.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    rideType.icon,
                    color: rideType.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rideType.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isSelected ? const Color(0xFF00B14F) : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rideType.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rideType.estimatedTime,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      rideType.price,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isSelected ? const Color(0xFF00B14F) : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B14F),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'SELECTED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

  void _showBookingConfirmation() {
    // Get selected ride type details
    final selectedRide = _rideTypes.firstWhere((ride) => ride.name == _selectedRideType);
    
    // Navigate to confirmation page with ride details
    final uri = Uri(
      path: '/ride-confirmation',
      queryParameters: {
        'rideType': Uri.encodeComponent(_selectedRideType),
        'passengers': _selectedPassengers.toString(),
        'pickup': Uri.encodeComponent(_pickupController.text),
        'destination': Uri.encodeComponent(_destinationController.text),
        'price': Uri.encodeComponent(selectedRide.price),
        'estimatedTime': Uri.encodeComponent(selectedRide.estimatedTime),
      },
    );
    context.go(uri.toString());
  }
}

class RideType {

  RideType({
    required this.name,
    required this.description,
    required this.price,
    required this.estimatedTime,
    required this.icon,
    required this.color,
  });
  final String name;
  final String description;
  final String price;
  final String estimatedTime;
  final IconData icon;
  final Color color;
}