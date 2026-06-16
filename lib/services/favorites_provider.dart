import 'package:flutter/foundation.dart';
import '../models/movie.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<Movie> _favorites = [];

  List<Movie> get favorites => _favorites;

  bool isFavorite(int movieId) {
    return _favorites.any((m) => m.id == movieId);
  }

  void toggleFavorite(Movie movie) {
    if (isFavorite(movie.id)) {
      _favorites.removeWhere((m) => m.id == movie.id);
    } else {
      _favorites.add(movie);
    }
    notifyListeners();
  }
}
