part of 'expense_bloc.dart';

sealed class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object> get props => [];
}

class LoadExpenses extends ExpenseEvent {}

class LoadExpensesByMonth extends ExpenseEvent {
  final String month;

  LoadExpensesByMonth({required this.month});

  @override
  List<Object> get props => [month];
}

class CreateExpense extends ExpenseEvent {
  final String description;
  final double amount;
  final String month;

  CreateExpense({
    required this.description,
    required this.amount,
    required this.month,
  });

  @override
  List<Object> get props => [description, amount, month];
}

class UpdateExpense extends ExpenseEvent {
  final int id;
  final String description;
  final double amount;
  final String month;

  UpdateExpense({
    required this.id,
    required this.description,
    required this.amount,
    required this.month,
  });

  @override
  List<Object> get props => [id, description, amount, month];
}

class DeleteExpense extends ExpenseEvent {
  final int id;

  DeleteExpense({required this.id});

  @override
  List<Object> get props => [id];
}