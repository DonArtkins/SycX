import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String fullName;
  final String userName;
  final String email;
  final String userProfile;
  final DateTime createdAt;
  final DateTime updatedAt;
  String? resetToken;
  DateTime? resetTokenExpiration;

  User({
    required this.id,
    required this.fullName,
    required this.userName,
    required this.email,
    required this.userProfile,
    required this.createdAt,
    required this.updatedAt,
    this.resetToken,
    this.resetTokenExpiration,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      userName: data['userName'] ?? '',
      email: data['email'] ?? '',
      userProfile: data['userProfile'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      resetToken: data['resetToken'],
      resetTokenExpiration: data['resetTokenExpiration'] != null
          ? (data['resetTokenExpiration'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'userName': userName,
      'email': email,
      'userProfile': userProfile,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'resetToken': resetToken,
      'resetTokenExpiration': resetTokenExpiration != null
          ? Timestamp.fromDate(resetTokenExpiration!)
          : null,
    };
  }

  // Add getters for compatibility
  String get name => fullName;
  String? get profileImage => userProfile;
}