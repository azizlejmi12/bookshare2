import '../models/loan_model.dart';
import 'firestore_service.dart';

class LoanService {
  final FirestoreService _firestore = FirestoreService();

  Future<void> borrowBook({
    required String userId,
    required String bookId,
    int durationDays = 7,
  }) {
    return _firestore.borrowBook(
      userId: userId,
      bookId: bookId,
      durationDays: durationDays,
    );
  }

  Future<void> returnBook(String loanId, String bookId) {
    return _firestore.returnBook(loanId, bookId);
  }

  Future<void> renewLoan(String loanId, {int extraDays = 7}) {
    return _firestore.renewLoan(loanId, extraDays);
  }

  Stream<List<LoanModel>> getUserActiveLoans(String userId) {
    return _firestore
        .getUserActiveLoans(userId)
        .map((loans) => loans.map(LoanModel.fromMap).toList());
  }

  Stream<List<LoanModel>> getUserLoanHistory(String userId) {
    return _firestore
        .getUserLoanHistory(userId)
        .map((loans) => loans.map(LoanModel.fromMap).toList());
  }
}
