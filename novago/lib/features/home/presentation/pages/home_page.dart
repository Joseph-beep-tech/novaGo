import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/home_app_bar.dart';
import '../widgets/nearby_restaurants.dart';
import '../widgets/promotional_banner.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_orders.dart';
import '../widgets/service_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh data
            await Future.delayed(const Duration(seconds: 1));
          },
          child: const CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: HomeAppBar(),
              ),
              SliverToBoxAdapter(
                child: ServiceGrid(),
              ),
              SliverToBoxAdapter(
                child: PromotionalBanner(),
              ),
              SliverToBoxAdapter(
                child: QuickActions(),
              ),
              SliverToBoxAdapter(
                child: RecentOrders(),
              ),
              SliverToBoxAdapter(
                child: NearbyRestaurants(),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 100), // Bottom padding
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              context.go('/restaurants');
              break;
            case 2:
              context.go('/ride-booking');
              break;
            case 3:
              context.go('/wallet');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Food',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_taxi),
            label: 'Ride',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
}