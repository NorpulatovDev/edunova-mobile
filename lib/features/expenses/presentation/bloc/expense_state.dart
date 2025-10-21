part of 'expense_bloc.dart';

sealed class ExpenseState extends Equatable {
  const ExpenseState();
  
  @override
  List<Object> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;

  ExpenseLoaded({required this.expenses});

  @override
  List<Object> get props => [expenses];
}

class ExpenseError extends ExpenseState {
  final String message;

  ExpenseError({required this.message});

  @override
  List<Object> get props => [message];
}

class ExpenseOperationSuccess extends ExpenseState {
  final String message;

  ExpenseOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}