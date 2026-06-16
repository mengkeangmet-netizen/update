import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../services/favorites_provider.dart';
import '../widgets/movie_section.dart';
import 'person_detail_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final TMDBService _service = TMDBService();
  MovieDetail? _movie;
  List<Movie> _recommendations = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final detail = await _service.getMovieDetail(widget.movieId);
      final recs = await _service.getRecommendations(widget.movieId);
      setState(() {
        _movie = detail;
        _recommendations = recs;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _movie == null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }

    final movie = _movie!;
    final favorites = context.watch<FavoritesProvider>();
    final isFav = favorites.isFavorite(movie.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : null,
                ),
                onPressed: () => favorites.toggleFavorite(movie),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: movie.backdropUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(color: Colors.grey[800]),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (movie.tagline.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        movie.tagline,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text('${movie.voteAverage.toStringAsFixed(1)} (${movie.voteCount})'),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 18),
                      const SizedBox(width: 4),
                      Text('${movie.runtime} min'),
                      const SizedBox(width: 16),
                      Text(movie.year),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: movie.genres
                        .map((g) => Chip(label: Text(g.name)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.overview.isNotEmpty
                        ? movie.overview
                        : 'No overview available.',
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  if (movie.cast.isNotEmpty) ...[
                    const Text(
                      'Cast',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: movie.cast.length,
                        itemBuilder: (context, index) {
                          final actor = movie.cast[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PersonDetailScreen(personId: actor.id),
                                ),
                              );
                            },
                            child: Container(
                            width: 90,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(45),
                                  child: CachedNetworkImage(
                                    imageUrl: actor.profileUrl,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.person),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  actor.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  actor.character,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_recommendations.isNotEmpty)
            SliverToBoxAdapter(
              child: MovieSection(title: 'You Might Also Like', movies: _recommendations),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
