import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/movie_service.dart';

class MoviePage extends StatefulWidget {
  final int movieId;

  const MoviePage({Key? key, required this.movieId}) : super(key: key);

  @override
  _MoviePageState createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  final MovieService _movieService = MovieService();
  Map<String, dynamic>? movieData;
  bool isLoading = true;
  String? trailerKey;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }

  Future<void> _loadMovieDetails() async {
    try {
      final data = await _movieService.getMovieDetails(widget.movieId);
      setState(() {
        movieData = data;
        // Get the first YouTube trailer
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
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading movie details')),
      );
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Loading...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (movieData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text('Failed to load movie details')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(movieData!['title']),
        backgroundColor: Colors.red[900],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Image
            Image.network(
              'https://image.tmdb.org/t/p/w500${movieData!['poster_path']}',
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating and Year
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      Text(' ${(movieData!['vote_average'] as num).toStringAsFixed(1)}/10'),
                      SizedBox(width: 20),
                      Text(movieData!['release_date'].toString().substring(0, 4)),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Trailer Button
                  if (trailerKey != null)
                    ElevatedButton.icon(
                      onPressed: _openTrailer,
                      icon: Icon(Icons.play_arrow),
                      label: Text('Watch Trailer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  SizedBox(height: 16),

                  // Overview
                  Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(movieData!['overview']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

