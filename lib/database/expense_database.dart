import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/expense.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  List<Expense> _allExpenses = [];

  /*
  Setup
  */
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);

    // Add hardcoded expenses after the database is initialized
    await _addHardcodedExpenses();
  }

  List<Expense> get allexpense => _allExpenses;

  /*
  Operations
  */
  Future<void> createNewExpense(Expense newExpense) async {
    await isar.writeTxn(() => isar.expenses.put(newExpense));
    await readExpense();
  }

  Future<void> readExpense() async {
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();

    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);

    notifyListeners();
  }

  Future<void> updateExpense(int id, Expense updatedExpense) async {
    updatedExpense.id = id;
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));
    await readExpense();
  }

  Future<void> deleteExpense(int id) async {
    await isar.writeTxn(() => isar.expenses.delete(id));
    await readExpense();
  }

  /*
  Helper
  */
  Future<Map<String, double>> calculateMonthlyTotals() async {
    await readExpense();
    Map<String, double> monthlyTotals = {};
    for (var expense in _allExpenses) {
      String yearMonth = '${expense.date.year}-${expense.date.month}';
      if (!monthlyTotals.containsKey(yearMonth)) {
        monthlyTotals[yearMonth] = 0;
      }
      monthlyTotals[yearMonth] = monthlyTotals[yearMonth]! + expense.amount;
    }
    return monthlyTotals;
  }

  Future<double> calculateCurrentMonthTotal() async {
    await readExpense();
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;
    List<Expense> currentMonthExpense = _allExpenses.where((expense){
      return expense.date.month == currentMonth && expense.date.year == currentYear;
    }).toList();
    double total = currentMonthExpense.fold(0, (sum, expense) => sum + expense.amount);
    return total;
  }

  int getStartMonth() {
    if (_allExpenses.isNotEmpty) {
      _allExpenses.sort((a, b) => a.date.compareTo(b.date));
      return _allExpenses.first.date.month;
    }
    return DateTime.now().month;
  }

  int getStartYear() {
    if (_allExpenses.isNotEmpty) {
      _allExpenses.sort((a, b) => a.date.compareTo(b.date));
      return _allExpenses.first.date.year;
    }
    return DateTime.now().year;
  }

  // Hardcoded expenses
  static Future<void> _addHardcodedExpenses() async {
    final hardcodedExpenses = [
      Expense(name: "Groceries", amount: 0.0, date: DateTime(2024, 1, 15)),
      Expense(name: "Rent", amount: 0.0, date: DateTime(2024, 1, 1)),
      Expense(name: "Internet", amount: 0.0, date: DateTime(2024, 2, 10)),
      Expense(name: "Electricity", amount: 0.0, date: DateTime(2024, 2, 20)),
      Expense(name: "Gym", amount: 0.0, date: DateTime(2024, 3, 5)),
      Expense(name: "Movie Night", amount: 0.0, date: DateTime(2025, 3, 25)),
    ];

    for (var expense in hardcodedExpenses) {
      await isar.writeTxn(() => isar.expenses.put(expense));
    }
  }
}
