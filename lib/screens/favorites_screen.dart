import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/favorites_provider.dart';
import '../widgets/movie_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: favorites.isEmpty
          ? Center(
              child: Text(
                'No favorites yet.\nTap the heart icon on a movie to save it.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500]),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.55,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                return MovieCard(movie: favorites[index]);
              },
            ),
    );
  }
}
