import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class TMDBService {
  // Get your free API key at https://www.themoviedb.org/settings/api
  static const String _apiKey = 'c2f7f6b7a44546048211167e8e7f8db1';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> getTrending({String timeWindow = 'week'}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/trending/movie/$timeWindow?api_key=$_apiKey'),
    );
    return _parseMovieList(response);
  }

  Future<List<Movie>> getPopular({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey&page=$page'),
    );
    return _parseMovieList(response);
  }

  Future<List<Movie>> getTopRated({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/top_rated?api_key=$_apiKey&page=$page'),
    );
    return _parseMovieList(response);
  }

  Future<List<Movie>> getNowPlaying({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/now_playing?api_key=$_apiKey&page=$page'),
    );
    return _parseMovieList(response);
  }

  Future<List<Movie>> getUpcoming({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/upcoming?api_key=$_apiKey&page=$page'),
    );
    return _parseMovieList(response);
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/search/movie?api_key=$_apiKey&query=${Uri.encodeComponent(query)}&page=$page',
      ),
    );
    return _parseMovieList(response);
  }

  Future<MovieDetail> getMovieDetail(int movieId) async {
    final detailResponse = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey'),
    );
    final creditsResponse = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId/credits?api_key=$_apiKey'),
    );

    if (detailResponse.statusCode != 200) {
      throw Exception('Failed to load movie details');
    }

    final detailJson = json.decode(detailResponse.body);
    List<CastMember> cast = [];

    if (creditsResponse.statusCode == 200) {
      final creditsJson = json.decode(creditsResponse.body);
      cast = (creditsJson['cast'] as List)
          .take(15)
          .map((c) => CastMember.fromJson(c))
          .toList();
    }

    return MovieDetail.fromJson(detailJson, cast);
  }

  Future<List<Movie>> getRecommendations(int movieId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId/recommendations?api_key=$_apiKey'),
    );
    return _parseMovieList(response);
  }

  Future<List<Genre>> getGenres() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/genre/movie/list?api_key=$_apiKey'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['genres'] as List).map((g) => Genre.fromJson(g)).toList();
    }
    return [];
  }

  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/discover/movie?api_key=$_apiKey&with_genres=$genreId&page=$page',
      ),
    );
    return _parseMovieList(response);
  }

  Future<List<Person>> getPopularPeople({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/person/popular?api_key=$_apiKey&page=$page'),
    );
    return _parsePersonList(response);
  }

  Future<List<Person>> searchPeople(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/search/person?api_key=$_apiKey&query=${Uri.encodeComponent(query)}&page=$page',
      ),
    );
    return _parsePersonList(response);
  }

  Future<PersonDetail> getPersonDetail(int personId) async {
    final detailResponse = await http.get(
      Uri.parse('$_baseUrl/person/$personId?api_key=$_apiKey'),
    );
    final creditsResponse = await http.get(
      Uri.parse('$_baseUrl/person/$personId/movie_credits?api_key=$_apiKey'),
    );

    if (detailResponse.statusCode != 200) {
      throw Exception('Failed to load person details');
    }

    final detailJson = json.decode(detailResponse.body);
    List<Movie> credits = [];

    if (creditsResponse.statusCode == 200) {
      final creditsJson = json.decode(creditsResponse.body);
      final cast = (creditsJson['cast'] as List? ?? [])
          .map((m) => Movie.fromJson(m))
          .toList();
      cast.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
      credits = cast;
    }

    return PersonDetail.fromJson(detailJson, credits);
  }

  List<Person> _parsePersonList(http.Response response) {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((p) => Person.fromJson(p)).toList();
    } else {
      throw Exception('Failed to load people: ${response.statusCode}');
    }
  }

  List<Movie> _parseMovieList(http.Response response) {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((m) => Movie.fromJson(m)).toList();
    } else {
      throw Exception('Failed to load movies: ${response.statusCode}');
    }
  }
}
