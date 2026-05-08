import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/food/presentation/pages/restaurant_list_page.dart';
import '../../features/food/presentation/pages/restaurant_detail_page.dart';
import '../../features/food/presentation/pages/cart_page.dart';
import '../../features/food/presentation/pages/checkout_page.dart';
import '../../features/food/presentation/pages/order_tracking_page.dart';
import '../../features/ride/presentation/pages/ride_booking_page.dart';
import '../../features/ride/presentation/pages/ride_tracking_page.dart';
import '../../features/ride/presentation/pages/ride_confirmation_page.dart';
import '../../features/wallet/presentation/pages/wallet_page.dart';
import '../../features/wallet/presentation/pages/add_money_page.dart';
import '../../features/wallet/presentation/pages/transaction_history_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/grocery/presentation/pages/grocery_page.dart';
import '../../features/grocery/presentation/pages/grocery_cart_page.dart';
import '../../features/courier/presentation/pages/courier_page.dart';
import '../../features/mart/presentation/pages/mart_page.dart';
import '../../features/fresh/presentation/pages/fresh_page.dart';
import '../../features/health/presentation/pages/health_page.dart';
import '../../features/finance/presentation/pages/finance_page.dart';
import '../../features/rewards/presentation/pages/rewards_page.dart';
import '../../features/bills/presentation/pages/bills_page.dart';
import '../../features/games/presentation/pages/games_page.dart';
import '../../features/more/presentation/pages/more_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/address_book_page.dart';
import '../../features/profile/presentation/pages/order_history_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/search/presentation/pages/search_page.dart';

final routerProvider = Provider<GoRouter>((ref) => GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/restaurants',
        builder: (context, state) => const RestaurantListPage(),
      ),
      GoRoute(
        path: '/restaurant/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return RestaurantDetailPage(restaurantId: id);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: '/order-tracking/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OrderTrackingPage(orderId: id);
        },
      ),
      GoRoute(
        path: '/ride-booking',
        builder: (context, state) => const RideBookingPage(),
      ),
      GoRoute(
        path: '/ride-confirmation',
        builder: (context, state) {
          final rideType = Uri.decodeComponent(state.uri.queryParameters['rideType'] ?? 'GrabCar');
          final passengers = int.tryParse(state.uri.queryParameters['passengers'] ?? '1') ?? 1;
          final pickup = Uri.decodeComponent(state.uri.queryParameters['pickup'] ?? '');
          final destination = Uri.decodeComponent(state.uri.queryParameters['destination'] ?? '');
          final price = Uri.decodeComponent(state.uri.queryParameters['price'] ?? r'$8.50');
          final estimatedTime = Uri.decodeComponent(state.uri.queryParameters['estimatedTime'] ?? '5-8 min');
          
          return RideConfirmationPage(
            rideType: rideType,
            passengers: passengers,
            pickup: pickup,
            destination: destination,
            price: price,
            estimatedTime: estimatedTime,
          );
        },
      ),
      GoRoute(
        path: '/ride-tracking/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return RideTrackingPage(rideId: id);
        },
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletPage(),
      ),
      GoRoute(
        path: '/add-money',
        builder: (context, state) => const AddMoneyPage(),
      ),
      GoRoute(
        path: '/transaction-history',
        builder: (context, state) => const TransactionHistoryPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/grocery',
        builder: (context, state) => const GroceryPage(),
      ),
      GoRoute(
        path: '/grocery-cart',
        builder: (context, state) => const GroceryCartPage(),
      ),
      GoRoute(
        path: '/courier',
        builder: (context, state) => const CourierPage(),
      ),
      GoRoute(
        path: '/mart',
        builder: (context, state) => const MartPage(),
      ),
      GoRoute(
        path: '/fresh',
        builder: (context, state) => const FreshPage(),
      ),
      GoRoute(
        path: '/health',
        builder: (context, state) => const HealthPage(),
      ),
      GoRoute(
        path: '/finance',
        builder: (context, state) => const FinancePage(),
      ),
      GoRoute(
        path: '/rewards',
        builder: (context, state) => const RewardsPage(),
      ),
      GoRoute(
        path: '/bills',
        builder: (context, state) => const BillsPage(),
      ),
      GoRoute(
        path: '/games',
        builder: (context, state) => const GamesPage(),
      ),
      GoRoute(
        path: '/more-services',
        builder: (context, state) => const MorePage(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/address-book',
        builder: (context, state) => const AddressBookPage(),
      ),
      GoRoute(
        path: '/order-history',
        builder: (context, state) => const OrderHistoryPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  ));