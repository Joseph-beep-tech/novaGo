import 'package:flutter/material.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  final List<MoreService> _services = [
    MoreService(
      name: 'Travel',
      description: 'Book flights and hotels',
      icon: Icons.flight,
      color: const Color(0xFF00B14F),
      onTap: () {},
    ),
    MoreService(
      name: 'Events',
      description: 'Discover local events',
      icon: Icons.event,
      color: const Color(0xFF4A90E2),
      onTap: () {},
    ),
    MoreService(
      name: 'Real Estate',
      description: 'Find your dream home',
      icon: Icons.home,
      color: const Color(0xFFFF6B35),
      onTap: () {},
    ),
    MoreService(
      name: 'Education',
      description: 'Online courses and tutoring',
      icon: Icons.school,
      color: const Color(0xFF9B59B6),
      onTap: () {},
    ),
    MoreService(
      name: 'Beauty',
      description: 'Salon and spa services',
      icon: Icons.face,
      color: const Color(0xFFE91E63),
      onTap: () {},
    ),
    MoreService(
      name: 'Auto',
      description: 'Car services and maintenance',
      icon: Icons.directions_car,
      color: const Color(0xFF795548),
      onTap: () {},
    ),
    MoreService(
      name: 'Pet Care',
      description: 'Veterinary and pet services',
      icon: Icons.pets,
      color: const Color(0xFF607D8B),
      onTap: () {},
    ),
    MoreService(
      name: 'Legal',
      description: 'Legal consultation services',
      icon: Icons.gavel,
      color: const Color(0xFF3F51B5),
      onTap: () {},
    ),
    MoreService(
      name: 'Cleaning',
      description: 'Home and office cleaning',
      icon: Icons.cleaning_services,
      color: const Color(0xFF009688),
      onTap: () {},
    ),
    MoreService(
      name: 'Photography',
      description: 'Professional photography',
      icon: Icons.camera_alt,
      color: const Color(0xFFFF9800),
      onTap: () {},
    ),
    MoreService(
      name: 'Fitness',
      description: 'Personal training and gym',
      icon: Icons.fitness_center,
      color: const Color(0xFF4CAF50),
      onTap: () {},
    ),
    MoreService(
      name: 'Consulting',
      description: 'Business and career consulting',
      icon: Icons.business,
      color: const Color(0xFF9C27B0),
      onTap: () {},
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
        title: const Text('More Services'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF00B14F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Discover More Services',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Everything you need, all in one app',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb,
                        color: Color(0xFF00B14F),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'New services added regularly!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B14F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Explore',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Services Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final service = _services[index];
                return _buildServiceCard(service);
              },
            ),
          ),
        ],
      ),
    );

  Widget _buildServiceCard(MoreService service) => Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: service.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
}

class MoreService {

  MoreService({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}