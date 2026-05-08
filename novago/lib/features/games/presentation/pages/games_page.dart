import 'package:flutter/material.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Puzzle',
    'Action',
    'Arcade',
    'Strategy',
    'Sports',
  ];

  final List<GameItem> _games = [
    GameItem(
      name: 'Candy Crush',
      category: 'Puzzle',
      rating: 4.5,
      downloads: '100M+',
      image: 'https://via.placeholder.com/200x200/FF69B4/FFFFFF?text=Candy',
      isFeatured: true,
      points: 50,
    ),
    GameItem(
      name: 'Temple Run',
      category: 'Action',
      rating: 4.3,
      downloads: '50M+',
      image: 'https://via.placeholder.com/200x200/8B4513/FFFFFF?text=Temple',
      isFeatured: false,
      points: 75,
    ),
    GameItem(
      name: 'Angry Birds',
      category: 'Arcade',
      rating: 4.7,
      downloads: '200M+',
      image: 'https://via.placeholder.com/200x200/FF0000/FFFFFF?text=Birds',
      isFeatured: true,
      points: 100,
    ),
    GameItem(
      name: 'Chess Master',
      category: 'Strategy',
      rating: 4.6,
      downloads: '10M+',
      image: 'https://via.placeholder.com/200x200/000000/FFFFFF?text=Chess',
      isFeatured: false,
      points: 150,
    ),
    GameItem(
      name: 'FIFA Mobile',
      category: 'Sports',
      rating: 4.4,
      downloads: '75M+',
      image: 'https://via.placeholder.com/200x200/00FF00/FFFFFF?text=FIFA',
      isFeatured: true,
      points: 200,
    ),
    GameItem(
      name: 'Word Connect',
      category: 'Puzzle',
      rating: 4.2,
      downloads: '25M+',
      image: 'https://via.placeholder.com/200x200/0000FF/FFFFFF?text=Word',
      isFeatured: false,
      points: 60,
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
        title: const Text('Games & Entertainment'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.card_giftcard),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: const Color(0xFF00B14F),
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search games',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),

          // Categories
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF00B14F) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF00B14F) : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Games Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _games.length,
              itemBuilder: (context, index) {
                final game = _games[index];
                return _buildGameCard(game);
              },
            ),
          ),
        ],
      ),
    );

  Widget _buildGameCard(GameItem game) => Container(
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
          // Game Image
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(game.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (game.isFeatured)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'FEATURED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Points badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B14F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${game.points} pts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Game Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    game.category,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.green,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              game.rating.toString(),
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        game.downloads,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Play Button
          Container(
            width: double.infinity,
            height: 32,
            margin: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                _showGameDialog(game);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B14F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 4),
              ),
              child: const Text(
                'Play Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );

  void _showGameDialog(GameItem game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Play ${game.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${game.category}'),
            Text('Rating: ${game.rating} ⭐'),
            Text('Downloads: ${game.downloads}'),
            Text('Points to earn: ${game.points}'),
            const SizedBox(height: 16),
            const Text(
              'Earn points while playing and redeem them for rewards!',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
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
                  content: Text('Starting ${game.name}...'),
                  backgroundColor: const Color(0xFF00B14F),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B14F),
            ),
            child: const Text('Start Game', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class GameItem {

  GameItem({
    required this.name,
    required this.category,
    required this.rating,
    required this.downloads,
    required this.image,
    required this.isFeatured,
    required this.points,
  });
  final String name;
  final String category;
  final double rating;
  final String downloads;
  final String image;
  final bool isFeatured;
  final int points;
}