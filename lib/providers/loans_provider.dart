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
  String? _activeError;
  String? _historyError;

  List<LoanModel> get activeLoans => _activeLoans;
  List<LoanModel> get historyLoans => _historyLoans;
  bool get isLoading => _isLoading;
  String? get activeError => _activeError;
  String? get historyError => _historyError;
  String? get error => _activeError ?? _historyError;

  String _formatError(Object error) {
    final message = error.toString();
    const prefix = 'Exception: ';
    return message.startsWith(prefix)
        ? message.substring(prefix.length)
        : message;
  }

  void clearError() {
    _activeError = null;
    _historyError = null;
    notifyListeners();
  }

  void watchUserLoans(String userId) {
    _isLoading = true;
    _activeError = null;
    _historyError = null;
    notifyListeners();

    // Déclenche un check de rappel une fois lors de l'ouverture de l'écran.
    _loanService.sendDueSoonRemindersForUser(userId).catchError((_) {});

    _activeSub?.cancel();
    _historySub?.cancel();

    _activeSub = _loanService
        .getUserActiveLoans(userId)
        .listen(
          (loans) {
            _activeLoans = loans;
            _activeError = null;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _activeError = _formatError(e);
            _isLoading = false;
            notifyListeners();
          },
        );

    _historySub = _loanService
        .getUserLoanHistory(userId)
        .listen(
          (loans) {
            _historyLoans = loans;
            _historyError = null;
            notifyListeners();
          },
          onError: (e) {
            _historyError = _formatError(e);
            notifyListeners();
          },
        );
  }

  Future<bool> borrowBook({
    required String userId,
    required String bookId,
    int durationDays = 7,
  }) async {
    try {
      _activeError = null;
      await _loanService.borrowBook(
        userId: userId,
        bookId: bookId,
        durationDays: durationDays,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _activeError = _formatError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> returnBook(String loanId, String bookId) async {
    try {
      _activeError = null;
      await _loanService.returnBook(loanId, bookId);
      notifyListeners();
      return true;
    } catch (e) {
      final errorMsg = e.toString();

      // Mapper les erreurs Firestore spécifiques
      if (errorMsg.contains('permission-denied')) {
        _activeError =
            'Permission refusée. Vérifiez que vous êtes connecté et que cet emprunt vous appartient.';
      } else if (errorMsg.contains('not-found')) {
        _activeError = 'Cet emprunt n\'existe pas ou a été supprimé.';
      } else {
        _activeError = _formatError(e);
      }

      notifyListeners();
      return false;
    }
  }

  Future<bool> renewLoan(String loanId, {int extraDays = 7}) async {
    try {
      _activeError = null;
      await _loanService.renewLoan(loanId, extraDays: extraDays);
      notifyListeners();
      return true;
    } catch (e) {
      _activeError = _formatError(e);
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
