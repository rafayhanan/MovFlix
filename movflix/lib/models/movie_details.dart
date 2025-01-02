class MovieDetails {
  final int id;
  final String title;
  final String posterPath;
  final String backdropPath;
  final double rating;
  final String overview;
  final String releaseDate;
  final List<String> genres;
  final String runtime;
  final String? trailerKey;

  MovieDetails({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.backdropPath,
    required this.rating,
    required this.overview,
    required this.releaseDate,
    required this.genres,
    required this.runtime,
    this.trailerKey,
  });

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    String? trailerKey;
    if (json['videos'] != null && json['videos']['results'] != null) {
      final videos = json['videos']['results'] as List;
      final trailer = videos.firstWhere(
            (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
        orElse: () => null,
      );
      if (trailer != null) {
        trailerKey = trailer['key'];
      }
    }

    final genresList = (json['genres'] as List?)?.map((genre) => genre['name'] as String).toList() ?? [];

    final int totalMinutes = json['runtime'] ?? 0;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    final runtimeStr = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    return MovieDetails(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      rating: (json['vote_average'] as num).toDouble(),
      overview: json['overview'],
      releaseDate: json['release_date'],
      genres: genresList,
      runtime: runtimeStr,
      trailerKey: trailerKey,
    );
  }
}