import 'package:cloud_firestore/cloud_firestore.dart';

class Feedback {
  final String id;
  final String userId;
  final String summaryId;
  final String feedbackText;
  final num rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  Feedback({
    required this.id,
    required this.userId,
    required this.summaryId,
    required this.feedbackText,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Feedback.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Feedback(
      id: doc.id,
      userId: data['userId'] ?? '',
      summaryId: data['summaryId'] ?? '',
      feedbackText: data['feedbackText'] ?? '',
      rating: data['rating'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'summaryId': summaryId,
      'feedbackText': feedbackText,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Utility method to get rating as stars
  String get ratingStars {
    return '★' * rating.toInt() + '☆' * (5 - rating.toInt());
  }

  // Utility method to get a human-readable timestamp
  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${difference.inDays ~/ 365 > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays ~/ 30 > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Method to create a copy of the feedback with optional updates
  Feedback copyWith({
    String? id,
    String? userId,
    String? summaryId,
    String? feedbackText,
    num? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Feedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      summaryId: summaryId ?? this.summaryId,
      feedbackText: feedbackText ?? this.feedbackText,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
