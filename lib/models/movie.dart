class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String releaseDate;
  final List<int> genreIds;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.genreIds,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? 'Unknown',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '',
      genreIds: json['genre_ids'] != null
          ? List<int>.from(json['genre_ids'])
          : [],
    );
  }

  String get posterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : 'https://via.placeholder.com/500x750?text=No+Image';

  String get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : 'https://via.placeholder.com/780x439?text=No+Image';

  String get year => releaseDate.isNotEmpty ? releaseDate.split('-')[0] : 'N/A';
}

class MovieDetail extends Movie {
  final int runtime;
  final List<Genre> genres;
  final String tagline;
  final int voteCount;
  final List<CastMember> cast;

  MovieDetail({
    required super.id,
    required super.title,
    required super.overview,
    super.posterPath,
    super.backdropPath,
    required super.voteAverage,
    required super.releaseDate,
    required super.genreIds,
    required this.runtime,
    required this.genres,
    required this.tagline,
    required this.voteCount,
    required this.cast,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json, List<CastMember> cast) {
    return MovieDetail(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      releaseDate: json['release_date'] ?? '',
      genreIds: [],
      runtime: json['runtime'] ?? 0,
      genres: json['genres'] != null
          ? (json['genres'] as List).map((g) => Genre.fromJson(g)).toList()
          : [],
      tagline: json['tagline'] ?? '',
      voteCount: json['vote_count'] ?? 0,
      cast: cast,
    );
  }
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(id: json['id'], name: json['name']);
  }
}

class CastMember {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      character: json['character'] ?? '',
      profilePath: json['profile_path'],
    );
  }

  String get profileUrl => profilePath != null
      ? 'https://image.tmdb.org/t/p/w185$profilePath'
      : 'https://via.placeholder.com/185x278?text=No+Photo';
}

class Person {
  final int id;
  final String name;
  final String? profilePath;
  final String knownForDepartment;
  final double popularity;
  final List<Movie> knownFor;

  Person({
    required this.id,
    required this.name,
    this.profilePath,
    required this.knownForDepartment,
    required this.popularity,
    required this.knownFor,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePath: json['profile_path'],
      knownForDepartment: json['known_for_department'] ?? '',
      popularity: (json['popularity'] ?? 0).toDouble(),
      knownFor: json['known_for'] != null
          ? (json['known_for'] as List).map((m) => Movie.fromJson(m)).toList()
          : [],
    );
  }

  String get profileUrl => profilePath != null
      ? 'https://image.tmdb.org/t/p/w300$profilePath'
      : 'https://via.placeholder.com/300x450?text=No+Photo';
}

class PersonDetail extends Person {
  final String biography;
  final String birthday;
  final String? deathday;
  final String placeOfBirth;
  final List<Movie> credits;

  PersonDetail({
    required super.id,
    required super.name,
    super.profilePath,
    required super.knownForDepartment,
    required super.popularity,
    required this.biography,
    required this.birthday,
    this.deathday,
    required this.placeOfBirth,
    required this.credits,
  }) : super(knownFor: const []);

  factory PersonDetail.fromJson(Map<String, dynamic> json, List<Movie> credits) {
    return PersonDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePath: json['profile_path'],
      knownForDepartment: json['known_for_department'] ?? '',
      popularity: (json['popularity'] ?? 0).toDouble(),
      biography: json['biography'] ?? '',
      birthday: json['birthday'] ?? '',
      deathday: json['deathday'],
      placeOfBirth: json['place_of_birth'] ?? '',
      credits: credits,
    );
  }
}
