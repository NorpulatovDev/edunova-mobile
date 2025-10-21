import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/expense_models.dart';
import '../../data/repositories/expense_repository.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepositoryImpl _expenseRepository;

  ExpenseBloc(this._expenseRepository) : super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<LoadExpensesByMonth>(_onLoadExpensesByMonth);
    on<CreateExpense>(_onCreateExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
  }

  void _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    try {
      final expenses = await _expenseRepository.getAllExpenses();
      emit(ExpenseLoaded(expenses: expenses));
    } catch (e) {
      emit(ExpenseError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onLoadExpensesByMonth(LoadExpensesByMonth event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    try {
      final expenses = await _expenseRepository.getExpensesByMonth(event.month);
      emit(ExpenseLoaded(expenses: expenses));
    } catch (e) {
      emit(ExpenseError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onCreateExpense(CreateExpense event, Emitter<ExpenseState> emit) async {
    try {
      final request = CreateExpenseRequest(
        description: event.description,
        amount: event.amount,
        month: event.month,
      );
      await _expenseRepository.createExpense(request);
      emit(ExpenseOperationSuccess(message: 'Expense created successfully'));
      // Reload expenses list
      add(LoadExpenses());
    } catch (e) {
      emit(ExpenseError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onUpdateExpense(UpdateExpense event, Emitter<ExpenseState> emit) async {
    try {
      final request = UpdateExpenseRequest(
        description: event.description,
        amount: event.amount,
        month: event.month,
      );
      await _expenseRepository.updateExpense(event.id, request);
      emit(ExpenseOperationSuccess(message: 'Expense updated successfully'));
      // Reload expenses list
      add(LoadExpenses());
    } catch (e) {
      emit(ExpenseError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onDeleteExpense(DeleteExpense event, Emitter<ExpenseState> emit) async {
    try {
      await _expenseRepository.deleteExpense(event.id);
      emit(ExpenseOperationSuccess(message: 'Expense deleted successfully'));
      // Reload expenses list
      add(LoadExpenses());
    } catch (e) {
      emit(ExpenseError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}