import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/movie_service.dart';
import '../services/database_service.dart';

class MoviePage extends StatefulWidget {
  final int movieId;

  const MoviePage({Key? key, required this.movieId}) : super(key: key);

  @override
  _MoviePageState createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  final MovieService _movieService = MovieService();
  final DatabaseService _dbService = DatabaseService();
  bool isInWatchlist = false;
  Map<String, dynamic>? movieData;
  bool isLoading = true;
  String? trailerKey;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
    _checkWatchlistStatus();
  }

  Future<void> _checkWatchlistStatus() async {
    final status = await _dbService.isInWatchlist(widget.movieId);
    setState(() => isInWatchlist = status);
  }

  Future<void> _loadMovieDetails() async {
    try {
      final data = await _movieService.getMovieDetails(widget.movieId);
      setState(() {
        movieData = data;
        if (data['videos']?['results'] != null) {
          final videos = data['videos']['results'] as List;
          final trailer = videos.firstWhere(
                (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
            orElse: () => null,
          );
          if (trailer != null) {
            trailerKey = trailer['key'];
          }
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading movie details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openTrailer() async {
    if (trailerKey != null) {
      final url = 'https://www.youtube.com/watch?v=$trailerKey';
      if (await canLaunch(url)) {
        await launch(url);
      }
    }
  }

  String _formatRuntime(int? minutes) {
    if (minutes == null) return 'N/A';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return hours > 0 ? '${hours}h ${remainingMinutes}m' : '${remainingMinutes}m';
  }

  Widget _buildInfoChip(IconData icon, String text, {Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade900),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor ?? Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }

    if (movieData == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load movie details',
                style: TextStyle(color: Colors.red.shade100),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadMovieDetails,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade900),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final backdrop = movieData!['backdrop_path'] != null
        ? 'https://image.tmdb.org/t/p/original${movieData!['backdrop_path']}'
        : 'https://image.tmdb.org/t/p/w500${movieData!['poster_path']}';

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
            onPressed: () async {
              await _dbService.toggleWatchlist(widget.movieId);
              await _checkWatchlistStatus();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isInWatchlist ? 'Added to watchlist' : 'Removed from watchlist',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black, Colors.transparent],
                    ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.network(
                    backdrop,
                    height: 400,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 400,
                        color: Colors.grey[900],
                        child: const Icon(Icons.error, color: Colors.white),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                          Colors.black,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movieData!['title'],
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildInfoChip(
                              Icons.star,
                              '${(movieData!['vote_average'] as num).toStringAsFixed(1)}/10',
                              iconColor: Colors.amber,
                            ),
                            _buildInfoChip(
                              Icons.calendar_today,
                              movieData!['release_date'].toString().substring(0, 4),
                            ),
                            _buildInfoChip(
                              Icons.timer,
                              _formatRuntime(movieData!['runtime'] as int?),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.red.shade900,
                    Colors.black,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Genres
                    if (movieData!['genres'] != null) ...[
                      const Text(
                        'Genres',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (movieData!['genres'] as List).map((genre) {
                          return Chip(
                            label: Text(
                              genre['name'],
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red.shade900,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movieData!['overview'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (trailerKey != null)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _openTrailer,
                          icon: const Icon(Icons.play_circle_outline,
                            color: Colors.white,
                          ),
                          label: const Text('Watch Trailer',
                            style:TextStyle(
                              color: Colors.white,
                            )
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}