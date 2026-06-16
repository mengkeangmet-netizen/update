import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'movie_card.dart';

class MovieSection extends StatelessWidget {
  final String title;
  final List<Movie> movies;

  const MovieSection({super.key, required this.title, required this.movies});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 130,
                  child: MovieCard(movie: movies[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
