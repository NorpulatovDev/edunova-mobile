import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/expense_models.dart';
import '../bloc/expense_bloc.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ExpenseBloc>()..add(LoadExpenses()),
      child: const ExpensesView(),
    );
  }
}

class ExpensesView extends StatefulWidget {
  const ExpensesView({super.key});

  @override
  State<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView> with TickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Set current month as default
    final now = DateTime.now();
    _selectedMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseError) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ExpenseOperationSuccess) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Expenses',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddExpenseDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Expense'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Month Filter
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text(
                        'Filter by Month:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: _showMonthPicker,
                        child: Text(_selectedMonth != null 
                            ? _formatMonth(_selectedMonth!)
                            : 'Select Month'),
                      ),
                      const SizedBox(width: 8),
                      if (_selectedMonth != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedMonth = null;
                            });
                            context.read<ExpenseBloc>().add(LoadExpenses());
                          },
                          child: const Text('Clear Filter'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Tabs
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.red,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.red,
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.list),
                        SizedBox(width: 8),
                        Text('All Expenses'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.analytics),
                        SizedBox(width: 8),
                        Text('Summary'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildExpensesList(),
                  _buildExpensesSummary(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesList() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ExpenseLoaded) {
          if (state.expenses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Expenses Found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add your first expense to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }
          return _buildExpensesListView(state.expenses);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildExpensesListView(List<Expense> expenses) {
    // Sort expenses by month (newest first)
    expenses.sort((a, b) => b.month.compareTo(a.month));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return _buildExpenseCard(expense);
      },
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.receipt_long,
            color: Colors.red,
            size: 24,
          ),
        ),
        title: Text(
          expense.description,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Month: ${expense.formattedMonth}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                '\$${expense.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditExpenseDialog(context, expense);
                break;
              case 'delete':
                _showDeleteConfirmation(context, expense);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesSummary() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ExpenseLoaded) {
          return _buildSummaryView(state.expenses);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildSummaryView(List<Expense> expenses) {
    final totalAmount = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final averageAmount = expenses.isNotEmpty ? totalAmount / expenses.length : 0.0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Expenses',
                  expenses.length.toString(),
                  '\$${totalAmount.toStringAsFixed(2)}',
                  Colors.red,
                  Icons.receipt_long,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Average',
                  'Per Expense',
                  '\$${averageAmount.toStringAsFixed(2)}',
                  Colors.orange,
                  Icons.trending_up,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Monthly Breakdown
          const Text(
            'Monthly Breakdown',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildMonthlyBreakdown(expenses),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, String amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                count,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBreakdown(List<Expense> expenses) {
    // Group expenses by month
    final Map<String, List<Expense>> expensesByMonth = {};
    for (final expense in expenses) {
      expensesByMonth.putIfAbsent(expense.month, () => []).add(expense);
    }

    final sortedMonths = expensesByMonth.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      children: sortedMonths.map((month) {
        final monthExpenses = expensesByMonth[month]!;
        final totalAmount = monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text(
              _formatMonth(month),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${monthExpenses.length} expenses • \$${totalAmount.toStringAsFixed(2)} total',
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: monthExpenses.map((expense) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt, color: Colors.red, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            expense.description,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '\$${expense.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatMonth(String month) {
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

  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (context) => _MonthPickerDialog(
        selectedMonth: _selectedMonth,
        onMonthSelected: (month) {
          setState(() {
            _selectedMonth = month;
          });
          if (month != null) {
            context.read<ExpenseBloc>().add(LoadExpensesByMonth(month: month));
          } else {
            context.read<ExpenseBloc>().add(LoadExpenses());
          }
        },
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ExpenseFormDialog(
        title: 'Add Expense',
        onSubmit: (description, amount, month) {
          context.read<ExpenseBloc>().add(
                CreateExpense(
                  description: description,
                  amount: amount,
                  month: month,
                ),
              );
        },
      ),
    );
  }

  void _showEditExpenseDialog(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ExpenseFormDialog(
        title: 'Edit Expense',
        initialDescription: expense.description,
        initialAmount: expense.amount,
        initialMonth: expense.month,
        onSubmit: (description, amount, month) {
          context.read<ExpenseBloc>().add(
                UpdateExpense(
                  id: expense.id!,
                  description: description,
                  amount: amount,
                  month: month,
                ),
              );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text(
          'Are you sure you want to delete "${expense.description}"?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ExpenseBloc>().add(DeleteExpense(id: expense.id!));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class ExpenseFormDialog extends StatefulWidget {
  final String title;
  final String? initialDescription;
  final double? initialAmount;
  final String? initialMonth;
  final Function(String description, double amount, String month) onSubmit;

  const ExpenseFormDialog({
    super.key,
    required this.title,
    this.initialDescription,
    this.initialAmount,
    this.initialMonth,
    required this.onSubmit,
  });

  @override
  State<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends State<ExpenseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late final TextEditingController _monthController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
    _amountController = TextEditingController(
      text: widget.initialAmount?.toString() ?? '',
    );
    _monthController = TextEditingController(
      text: widget.initialMonth ?? _getCurrentMonth(),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  String _getCurrentMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                      hintText: 'e.g., Office Rent, Utilities, Equipment',
                    ),
                    maxLength: 255,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Amount
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                      suffixText: 'USD',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount < 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Month
                  TextFormField(
                    controller: _monthController,
                    decoration: InputDecoration(
                      labelText: 'Month (YYYY-MM)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_month),
                      hintText: '2025-01',
                      helperText: 'Format: Year-Month (e.g., 2025-01)',
                      suffixIcon: IconButton(
                        onPressed: _showMonthPicker,
                        icon: const Icon(Icons.calendar_today),
                        tooltip: 'Pick Month',
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter month';
                      }
                      final monthRegex = RegExp(r'^\d{4}-(0[1-9]|1[0-2])$');
                      if (!monthRegex.hasMatch(value)) {
                        return 'Please enter month in YYYY-MM format';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Expense'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (context) => _MonthPickerDialog(
        selectedMonth: _monthController.text.isNotEmpty ? _monthController.text : null,
        onMonthSelected: (month) {
          if (month != null) {
            setState(() {
              _monthController.text = month;
            });
          }
        },
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final description = _descriptionController.text.trim();
      final amount = double.parse(_amountController.text.trim());
      final month = _monthController.text.trim();
      
      Navigator.pop(context);
      widget.onSubmit(description, amount, month);
    }
  }
}

class _MonthPickerDialog extends StatefulWidget {
  final String? selectedMonth;
  final Function(String?) onMonthSelected;

  const _MonthPickerDialog({
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int selectedYear;
  late int selectedMonth;

  @override
  void initState() {
    super.initState();
    if (widget.selectedMonth != null) {
      final parts = widget.selectedMonth!.split('-');
      selectedYear = int.parse(parts[0]);
      selectedMonth = int.parse(parts[1]);
    } else {
      final now = DateTime.now();
      selectedYear = now.year;
      selectedMonth = now.month;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Month'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Year selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      selectedYear--;
                    });
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  selectedYear.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      selectedYear++;
                    });
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Month selection grid
            SizedBox(
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final isSelected = month == selectedMonth;
                  const monthNames = [
                    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                  ];
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedMonth = month;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey.shade300,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        monthNames[month],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final monthStr = '${selectedYear}-${selectedMonth.toString().padLeft(2, '0')}';
            Navigator.pop(context);
            widget.onMonthSelected(monthStr);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Select'),
        ),
      ],
    );
  }
}