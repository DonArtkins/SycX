import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:SycX/models/user.dart';
import 'package:SycX/models/summary.dart';
import 'package:SycX/models/feedback.dart';

class Database {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Summary operations
  Future<void> createSummary(Summary summary) async {
    try {
      // Use summary's toFirestore method to get proper data structure
      final data = summary.toFirestore();

      // Create the document with the appropriate ID
      await firestore.collection('summaries').doc(summary.id).set(data);
    } catch (e) {
      print('Error creating summary: $e');
      rethrow;
    }
  }

  // Other methods remain the same
  // ...

  // User operations
  Future<void> createUser(User user) async {
    await firestore.collection('users').doc(user.id).set(user.toFirestore());
  }

  Future<User?> getUser(String userId) async {
    DocumentSnapshot doc =
        await firestore.collection('users').doc(userId).get();
    return doc.exists ? User.fromFirestore(doc) : null;
  }

  Future<User?> getUserByUsername(String username) async {
    QuerySnapshot querySnapshot = await firestore
        .collection('users')
        .where('userName', isEqualTo: username)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return User.fromFirestore(querySnapshot.docs.first);
    }
    return null;
  }

  Future<void> updateUser(User user) async {
    await firestore.collection('users').doc(user.id).update(user.toFirestore());
  }

  Future<void> setResetToken(
      String userId, String token, DateTime expiration) async {
    await firestore.collection('users').doc(userId).update({
      'resetToken': token,
      'resetTokenExpiration': Timestamp.fromDate(expiration),
    });
  }

  Future<void> clearResetToken(String userId) async {
    await firestore.collection('users').doc(userId).update({
      'resetToken': FieldValue.delete(),
      'resetTokenExpiration': FieldValue.delete(),
    });
  }

  Future<User?> getUserByEmail(String email) async {
    QuerySnapshot querySnapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return User.fromFirestore(querySnapshot.docs.first);
    }
    return null;
  }

  Future<User?> getUserByResetToken(String token) async {
    QuerySnapshot querySnapshot = await firestore
        .collection('users')
        .where('resetToken', isEqualTo: token)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return User.fromFirestore(querySnapshot.docs.first);
    }
    return null;
  }

  // Fetch summaries for a specific user
  Stream<List<Summary>> getUserSummaries(String userId) {
    return firestore
        .collection('summaries')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Summary.fromFirestore(doc)).toList());
  }

  // Get a specific summary by ID
  Future<Summary?> getSummaryById(String summaryId) async {
    try {
      final doc = await firestore.collection('summaries').doc(summaryId).get();
      return doc.exists ? Summary.fromFirestore(doc) : null;
    } catch (e) {
      print('Error fetching summary: $e');
      rethrow;
    }
  }

  // Update an existing summary
  Future<void> updateSummary(Summary summary) async {
    try {
      await firestore
          .collection('summaries')
          .doc(summary.id)
          .update(summary.toFirestore());
    } catch (e) {
      print('Error updating summary: $e');
      rethrow;
    }
  }

  // Delete a summary
  Future<void> deleteSummary(String summaryId) async {
    try {
      await firestore.collection('summaries').doc(summaryId).delete();
    } catch (e) {
      print('Error deleting summary: $e');
      rethrow;
    }
  }

  // Feedback operations
  Future<void> createFeedback(Feedback feedback) async {
    try {
      // Add the feedback document to the 'feedback' collection
      await firestore
          .collection('feedback')
          .doc(feedback.id)
          .set(feedback.toFirestore());
    } catch (e) {
      print('Error creating feedback in Firestore: $e');
      rethrow;
    }
  }

  Future<List<Feedback>> getSummaryFeedback(String summaryId) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('feedback')
          .where('summaryId', isEqualTo: summaryId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Feedback.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching summary feedback: $e');
      return [];
    }
  }

  Future<double> calculateAverageSummaryRating(String summaryId) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('feedback')
          .where('summaryId', isEqualTo: summaryId)
          .get();

      // If no feedback exists, return 0
      if (querySnapshot.docs.isEmpty) return 0.0;

      // Calculate total rating
      double totalRating = querySnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['rating'] as num)
          .reduce((a, b) => a + b)
          .toDouble();

      // Calculate average rating
      double averageRating = totalRating / querySnapshot.docs.length;

      // Round to 1 decimal place
      return double.parse(averageRating.toStringAsFixed(1));
    } catch (e) {
      // Log the error and return 0 to prevent breaking the app
      print('Error calculating average summary rating: $e');
      return 0.0;
    }
  }

  // Additional method to get feedback count for a summary
  Future<int> getSummaryFeedbackCount(String summaryId) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('feedback')
          .where('summaryId', isEqualTo: summaryId)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getting summary feedback count: $e');
      return 0;
    }
  }

  Future<void> updateFeedback(Feedback feedback) async {
    await firestore
        .collection('feedback')
        .doc(feedback.id)
        .update(feedback.toFirestore());
  }

  Future<void> saveSearch(String userId, String query) async {
    try {
      await firestore.collection('searches').add({
        'userId': userId,
        'query': query,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving search: $e');
    }
  }

  Future<List<String>> getRecentSearches(String userId, {int limit = 5}) async {
    try {
      QuerySnapshot searchesSnapshot = await firestore
          .collection('searches')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return searchesSnapshot.docs
          .map((doc) => doc['query'] as String)
          .toList();
    } catch (e) {
      print('Error fetching searches: $e');
      return [];
    }
  }

  Future<void> clearAllSearches(String userId) async {
    try {
      // Get all search records for the user
      QuerySnapshot searchesSnapshot = await firestore
          .collection('searches')
          .where('userId', isEqualTo: userId)
          .get();

      // Delete each search record
      for (DocumentSnapshot doc in searchesSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error clearing searches: $e');
    }
  }

  Future<void> removeSearch(String userId, String query) async {
    try {
      // Find and delete the specific search record
      QuerySnapshot searchesSnapshot = await firestore
          .collection('searches')
          .where('userId', isEqualTo: userId)
          .where('query', isEqualTo: query)
          .get();

      for (DocumentSnapshot doc in searchesSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error removing search: $e');
    }
  }
}
