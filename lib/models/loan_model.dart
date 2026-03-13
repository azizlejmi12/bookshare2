import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum LoanStatus { active, returned, overdue, extended }

class LoanModel {
  final String id;
  final String userId;
  final String bookId;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate;
  final LoanStatus status;
  final int renewalCount; // Nombre de prolongations

  LoanModel({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
    required this.status,
    this.renewalCount = 0,
  });

  factory LoanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Convertir le statut depuis String
    LoanStatus status = LoanStatus.active;
    if (data['status'] == 'returned') status = LoanStatus.returned;
    if (data['status'] == 'overdue') status = LoanStatus.overdue;
    if (data['status'] == 'extended') status = LoanStatus.extended;

    return LoanModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      bookId: data['bookId'] ?? '',
      borrowDate: (data['borrowDate'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      returnDate: data['returnDate'] != null
          ? (data['returnDate'] as Timestamp).toDate()
          : null,
      status: status,
      renewalCount: data['renewalCount'] ?? 0,
    );
  }

  factory LoanModel.fromMap(Map<String, dynamic> data) {
    LoanStatus status = LoanStatus.active;
    if (data['status'] == 'returned') status = LoanStatus.returned;
    if (data['status'] == 'overdue') status = LoanStatus.overdue;
    if (data['status'] == 'extended') status = LoanStatus.extended;

    return LoanModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      bookId: data['bookId'] ?? '',
      borrowDate: (data['borrowDate'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      returnDate: data['returnDate'] != null
          ? (data['returnDate'] as Timestamp).toDate()
          : null,
      status: status,
      renewalCount: data['renewalCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'bookId': bookId,
      'borrowDate': Timestamp.fromDate(borrowDate),
      'dueDate': Timestamp.fromDate(dueDate),
      'returnDate': returnDate != null ? Timestamp.fromDate(returnDate!) : null,
      'status': status.toString().split('.').last,
      'renewalCount': renewalCount,
    };
  }

  // Vérifier si l'emprunt est en retard
  bool get isOverdue {
    return status == LoanStatus.active && DateTime.now().isAfter(dueDate);
  }

  // Jours restants avant la date de retour
  int get daysRemaining {
    if (status != LoanStatus.active) return 0;
    return dueDate.difference(DateTime.now()).inDays;
  }

  // Couleur selon l'urgence
  Color get statusColor {
    if (status != LoanStatus.active) return Colors.grey;
    if (daysRemaining < 0) return Colors.red;
    if (daysRemaining <= 3) return Colors.orange;
    return Colors.green;
  }

  // Texte de statut
  String get statusText {
    switch (status) {
      case LoanStatus.active:
        if (isOverdue) return 'En retard';
        return 'En cours';
      case LoanStatus.returned:
        return 'Retourné';
      case LoanStatus.overdue:
        return 'En retard';
      case LoanStatus.extended:
        return 'Prolongé';
    }
  }
}
