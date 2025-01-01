import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final databaseRef = FirebaseDatabase.instance.ref();
  final auth = FirebaseAuth.instance;

  Future<void> toggleWatchlist(int movieId) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) return;

    final movieRef = databaseRef.child('watchlist').child(movieId.toString());
    final snapshot = await movieRef.get();

    if (snapshot.exists) {
      await movieRef.remove();
    } else {
      await movieRef.set({
        'userId': userId,
        'timestamp': ServerValue.timestamp,
      });
    }
  }

  Future<bool> isInWatchlist(int movieId) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) return false;

    final snapshot = await databaseRef
        .child('watchlist')
        .child(movieId.toString())
        .child('userId')
        .get();

    return snapshot.exists && snapshot.value == userId;
  }

  Future<List<int>> getWatchlist() async {
    final userId = auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await databaseRef.child('watchlist').get();
    if (!snapshot.exists) return [];

    final watchlist = <int>[];
    final data = snapshot.value as Map;

    data.forEach((key, value) {
      if (value['userId'] == userId) {
        watchlist.add(int.parse(key.toString()));
      }
    });

    return watchlist;
  }
}