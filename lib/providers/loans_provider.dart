import 'dart:async';

import 'package:flutter/material.dart';

import '../models/loan_model.dart';
import '../services/loan_service.dart';

class LoansProvider extends ChangeNotifier {
  final LoanService _loanService = LoanService();
  StreamSubscription<List<LoanModel>>? _activeSub;
  StreamSubscription<List<LoanModel>>? _historySub;

  List<LoanModel> _activeLoans = [];
  List<LoanModel> _historyLoans = [];
  bool _isLoading = false;
  String? _error;

  List<LoanModel> get activeLoans => _activeLoans;
  List<LoanModel> get historyLoans => _historyLoans;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void watchUserLoans(String userId) {
    _isLoading = true;
    notifyListeners();

    _activeSub?.cancel();
    _historySub?.cancel();

    _activeSub = _loanService
        .getUserActiveLoans(userId)
        .listen(
          (loans) {
            _activeLoans = loans;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            _isLoading = false;
            notifyListeners();
          },
        );

    _historySub = _loanService.getUserLoanHistory(userId).listen((loans) {
      _historyLoans = loans;
      notifyListeners();
    });
  }

  Future<bool> borrowBook({
    required String userId,
    required String bookId,
    int durationDays = 7,
  }) async {
    try {
      _error = null;
      await _loanService.borrowBook(
        userId: userId,
        bookId: bookId,
        durationDays: durationDays,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> returnBook(String loanId, String bookId) async {
    try {
      _error = null;
      await _loanService.returnBook(loanId, bookId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> renewLoan(String loanId, {int extraDays = 7}) async {
    try {
      _error = null;
      await _loanService.renewLoan(loanId, extraDays: extraDays);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _activeSub?.cancel();
    _historySub?.cancel();
    super.dispose();
  }
}
