import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import 'person_detail_screen.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final TMDBService _service = TMDBService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<Person> _people = [];
  bool _loading = true;
  bool _isSearching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPopular();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadPopular() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final people = await _service.getPopularPeople();
      setState(() {
        _people = people;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _search(query);
    });
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _isSearching = false);
      _loadPopular();
      return;
    }
    setState(() {
      _loading = true;
      _isSearching = true;
      _error = null;
    });
    try {
      final results = await _service.searchPeople(query);
      setState(() {
        _people = results;
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
        title: const Text('People'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search actors, directors...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: $_error'),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _loadPopular,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _people.isEmpty
                        ? Center(
                            child: Text(
                              _isSearching ? 'No people found' : 'No data',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _isSearching
                                ? () => _search(_searchController.text)
                                : _loadPopular,
                            child: GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: _people.length,
                              itemBuilder: (context, index) {
                                return _PersonCard(person: _people[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final Person person;

  const _PersonCard({required this.person});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PersonDetailScreen(personId: person.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: person.profileUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.person, color: Colors.white54, size: 32),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            person.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          Text(
            person.knownForDepartment,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
