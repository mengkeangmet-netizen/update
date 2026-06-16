import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../widgets/movie_section.dart';
import 'search_screen.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TMDBService _service = TMDBService();

  List<Movie> _trending = [];
  List<Movie> _popular = [];
  List<Movie> _topRated = [];
  List<Movie> _nowPlaying = [];
  List<Movie> _upcoming = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _service.getTrending(),
        _service.getPopular(),
        _service.getTopRated(),
        _service.getNowPlaying(),
        _service.getUpcoming(),
      ]);
      setState(() {
        _trending = results[0];
        _popular = results[1];
        _topRated = results[2];
        _nowPlaying = results[3];
        _upcoming = results[4];
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('CineHub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    children: [
                      _buildFeatured(),
                      const SizedBox(height: 8),
                      MovieSection(title: 'Trending This Week', movies: _trending),
                      MovieSection(title: 'Now Playing', movies: _nowPlaying),
                      MovieSection(title: 'Popular', movies: _popular),
                      MovieSection(title: 'Top Rated', movies: _topRated),
                      MovieSection(title: 'Upcoming', movies: _upcoming),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildFeatured() {
    if (_trending.isEmpty) return const SizedBox.shrink();
    final featured = _trending.first;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailScreen(movieId: featured.id),
          ),
        );
      },
      child: Stack(
        children: [
          SizedBox(
            height: 220,
            width: double.infinity,
            child: Image.network(
              featured.backdropUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]),
            ),
          ),
          Container(
            height: 220,
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
          Positioned(
            bottom: 12,
            left: 16,
            right: 16,
            child: Text(
              featured.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
