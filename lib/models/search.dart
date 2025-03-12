import 'package:cloud_firestore/cloud_firestore.dart';

class SearchRecord {
  final String id;
  final String userId;
  final String query;
  final DateTime timestamp;

  SearchRecord({
    required this.id,
    required this.userId,
    required this.query,
    required this.timestamp,
  });

  // Convert SearchRecord to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'query': query,
      'timestamp': timestamp,
    };
  }

  // Create SearchRecord from Firestore document
  factory SearchRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SearchRecord(
      id: doc.id,
      userId: data['userId'],
      query: data['query'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
