import 'package:cloud_firestore/cloud_firestore.dart';

class Summary {
  final String id;
  final String userId;
  final List<OriginalDocument> originalDocuments;
  final String? pdfUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isPinned;
  String? title;
  String? imageUrl;

  Summary({
    this.id = '',
    required this.userId,
    required this.originalDocuments,
    this.pdfUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.title,
    this.imageUrl,
  });

  factory Summary.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<OriginalDocument> documents = [];
    if (data['originalDocuments'] != null) {
      documents = (data['originalDocuments'] as List<dynamic>)
          .map((doc) => OriginalDocument.fromMap(doc as Map<String, dynamic>))
          .toList();
    }

    DateTime created = (data['createdAt'] as Timestamp).toDate();
    DateTime updated = (data['updatedAt'] as Timestamp).toDate();

    return Summary(
      id: doc.id,
      userId: data['userId'] ?? '',
      originalDocuments: documents,
      pdfUrl: data['pdfUrl'],
      createdAt: created,
      updatedAt: updated,
      isPinned: data['isPinned'] ?? false,
      title: data['title'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'originalDocuments': originalDocuments.map((doc) => doc.toMap()).toList(),
      'pdfUrl': pdfUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPinned': isPinned,
      'title': title,
      'imageUrl': imageUrl,
    };
  }

  Map<String, dynamic> toCardFormat() {
    return {
      'id': id,
      'title': title ?? 'Untitled',
      'originalDocuments': originalDocuments.map((doc) => doc.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
      'pdfUrl': pdfUrl,
      'imageUrl': imageUrl,
    };
  }

  Summary copyWith({
    String? id,
    String? userId,
    List<OriginalDocument>? originalDocuments,
    String? pdfUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    String? title,
    String? imageUrl,
  }) {
    return Summary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      originalDocuments: originalDocuments ?? this.originalDocuments,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class OriginalDocument {
  final String title;
  final String? fileUrl; // Changed from content to fileUrl
  final String? type;

  OriginalDocument({
    required this.title,
    this.fileUrl,
    this.type,
  });

  factory OriginalDocument.fromMap(Map<String, dynamic> map) {
    return OriginalDocument(
      title: map['title'] ?? '',
      fileUrl: map['fileUrl'],
      type: map['type'],
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
    };
    
    if (fileUrl != null) map['fileUrl'] = fileUrl;
    if (type != null) map['type'] = type;
    
    return map;
  }
}
