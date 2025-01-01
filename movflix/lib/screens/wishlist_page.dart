import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import '../services/database_service.dart';
import 'movie_list_screen.dart';

class WatchlistScreen extends StatefulWidget {
  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final MovieService _movieService = MovieService();
  final DatabaseService _dbService = DatabaseService();
  final List<Movie> _movies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    try {
      setState(() => _isLoading = true);

      // Get movieIds from watchlist
      final movieIds = await _dbService.getWatchlist();

      // Get details for each movie
      final movieDetails = await Future.wait(
          movieIds.map((id) => _movieService.getMovieDetails(id))
      );

      setState(() {
        _movies.clear();
        for (var movie in movieDetails) {
          _movies.add(Movie.fromJson(movie));
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load watchlist'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'My Watchlist',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Container(
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
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Colors.red),
        )
            : _movies.isEmpty
            ? Center(
          child: Text(
            'Your watchlist is empty',
            style: TextStyle(
              color: Colors.red.shade100,
              fontSize: 16,
            ),
          ),
        )
            : RefreshIndicator(
          onRefresh: _loadWatchlist,
          color: Colors.red,
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: SizedBox(height: kToolbarHeight + 20),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => MovieCard(movie: _movies[index]),
                    childCount: _movies.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}