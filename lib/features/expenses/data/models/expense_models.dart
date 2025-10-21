import 'package:json_annotation/json_annotation.dart';

part 'expense_models.g.dart';

@JsonSerializable()
class Expense {
  final int? id;
  final String description;
  final double amount;
  final String month;

  Expense({
    this.id,
    required this.description,
    required this.amount,
    required this.month,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);

  // Helper getter for formatted month
  String get formattedMonth {
    final parts = month.split('-');
    if (parts.length == 2) {
      final year = parts[0];
      final monthNum = int.parse(parts[1]);
      const monthNames = [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${monthNames[monthNum]} $year';
    }
    return month;
  }
}

@JsonSerializable()
class CreateExpenseRequest {
  final String description;
  final double amount;
  final String month;

  CreateExpenseRequest({
    required this.description,
    required this.amount,
    required this.month,
  });

  factory CreateExpenseRequest.fromJson(Map<String, dynamic> json) => 
      _$CreateExpenseRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateExpenseRequestToJson(this);
}

@JsonSerializable()
class UpdateExpenseRequest {
  final String description;
  final double amount;
  final String month;

  UpdateExpenseRequest({
    required this.description,
    required this.amount,
    required this.month,
  });

  factory UpdateExpenseRequest.fromJson(Map<String, dynamic> json) => 
      _$UpdateExpenseRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateExpenseRequestToJson(this);
}