import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../widgets/movie_card.dart';

class PersonDetailScreen extends StatefulWidget {
  final int personId;

  const PersonDetailScreen({super.key, required this.personId});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  final TMDBService _service = TMDBService();
  PersonDetail? _person;
  bool _loading = true;
  String? _error;
  bool _bioExpanded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final detail = await _service.getPersonDetail(widget.personId);
      setState(() {
        _person = detail;
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
    if (_error != null || _person == null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }

    final person = _person!;
    final age = _calculateAge(person.birthday, person.deathday);

    return Scaffold(
      appBar: AppBar(title: Text(person.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: person.profileUrl,
                  width: 120,
                  height: 180,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 120,
                    height: 180,
                    color: Colors.grey[800],
                    child: const Icon(Icons.person, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (person.knownForDepartment.isNotEmpty)
                      _InfoRow(label: 'Known For', value: person.knownForDepartment),
                    if (person.birthday.isNotEmpty)
                      _InfoRow(
                        label: 'Birthday',
                        value: age != null
                            ? '${person.birthday} ($age yrs)'
                            : person.birthday,
                      ),
                    if (person.deathday != null)
                      _InfoRow(label: 'Died', value: person.deathday!),
                    if (person.placeOfBirth.isNotEmpty)
                      _InfoRow(label: 'Birthplace', value: person.placeOfBirth),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (person.biography.isNotEmpty) ...[
            const Text(
              'Biography',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              person.biography,
              maxLines: _bioExpanded ? null : 6,
              overflow: _bioExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            if (person.biography.length > 300)
              TextButton(
                onPressed: () => setState(() => _bioExpanded = !_bioExpanded),
                child: Text(_bioExpanded ? 'Show less' : 'Read more'),
              ),
            const SizedBox(height: 12),
          ],
          if (person.credits.isNotEmpty) ...[
            const Text(
              'Known For',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.55,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: person.credits.length,
              itemBuilder: (context, index) {
                return MovieCard(movie: person.credits[index]);
              },
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  int? _calculateAge(String birthday, String? deathday) {
    if (birthday.isEmpty) return null;
    try {
      final birth = DateTime.parse(birthday);
      final end = deathday != null ? DateTime.parse(deathday) : DateTime.now();
      int age = end.year - birth.year;
      if (end.month < birth.month ||
          (end.month == birth.month && end.day < birth.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return null;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.white),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
