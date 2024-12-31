class Movie {
  final int id;
  final String title;
  final String posterPath;
  final double rating;
  final String overview;
  final String releaseDate;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.rating,
    required this.overview,
    required this.releaseDate,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'] ?? '',
      rating: (json['vote_average'] as num).toDouble(),
      overview: json['overview'],
      releaseDate: json['release_date'],
    );
  }
}