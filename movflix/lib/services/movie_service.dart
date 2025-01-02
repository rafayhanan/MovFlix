import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieService {
  final String apiKey = 'a049c678e75c4316fc80707ebec60e25';
  final String baseUrl = 'https://api.themoviedb.org/3';
  final String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  final http.Client _client = http.Client();

  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/movie/popular?api_key=$apiKey&page=$page'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movies = data['results'] as List;
        return movies.map((movie) => Movie.fromJson(movie)).toList();
      } else {
        throw ApiException('Failed to load popular movies', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error occurred', 0);
    }
  }

  Future<List<Movie>> getTrendingMovies({String timeWindow = 'week'}) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/trending/movie/$timeWindow?api_key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movies = data['results'] as List;
        return movies.map((movie) => Movie.fromJson(movie)).toList();
      } else {
        throw ApiException('Failed to load trending movies', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error occurred', 0);
    }
  }

  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/movie/top_rated?api_key=$apiKey&page=$page'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movies = data['results'] as List;
        return movies.map((movie) => Movie.fromJson(movie)).toList();
      } else {
        throw ApiException('Failed to load top rated movies', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error occurred', 0);
    }
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final response = await _client.get(
        Uri.parse(
          '$baseUrl/search/movie?api_key=$apiKey&query=${Uri.encodeComponent(query)}&page=$page',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movies = data['results'] as List;
        return movies.map((movie) => Movie.fromJson(movie)).toList();
      } else {
        throw ApiException('Failed to search movies', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error occurred', 0);
    }
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/$movieId?api_key=$apiKey&append_to_response=videos'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  Future<List<Movie>> getSimilarMovies(int movieId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/movie/$movieId/similar?api_key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movies = data['results'] as List;
        return movies.map((movie) => Movie.fromJson(movie)).take(10).toList();
      } else {
        throw ApiException('Failed to load similar movies', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error occurred', 0);
    }
  }

  Future<List<Movie>> searchMovieByTitle(String title) async {
    try {
      final response = await _client.get(
        Uri.parse(
          '$baseUrl/search/movie?api_key=$apiKey&query=${Uri.encodeComponent(
              title)}&page=1',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movies = data['results'] as List;
        return movies.map((movie) => Movie.fromJson(movie)).take(1).toList();
      } else {
        throw ApiException('Failed to search movies', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error occurred', 0);
    }
  }


  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }
    return '$imageBaseUrl$path';
  }

  void dispose() {
    _client.close();
  }
}



class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status Code: $statusCode)';
}
