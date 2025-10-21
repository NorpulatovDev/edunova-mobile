import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../courses/data/models/course_models.dart';
import '../../../courses/presentation/bloc/course_bloc.dart';
import '../../../students/data/models/student_models.dart';
import '../../../students/presentation/bloc/student_bloc.dart';

class PaymentFormDialog extends StatefulWidget {
  final String title;
  final int? initialStudentId;
  final int? initialCourseId;
  final double? initialAmount;
  final String? initialMonth;
  final bool? initialPaid;
  final Function(int studentId, int courseId, double amount, String month, bool paid) onSubmit;

  const PaymentFormDialog({
    super.key,
    required this.title,
    this.initialStudentId,
    this.initialCourseId,
    this.initialAmount,
    this.initialMonth,
    this.initialPaid,
    required this.onSubmit,
  });

  @override
  State<PaymentFormDialog> createState() => _PaymentFormDialogState();
}

class _PaymentFormDialogState extends State<PaymentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _monthController;
  int? _selectedStudentId;
  int? _selectedCourseId;
  bool _isPaid = false;
  List<Student> _students = [];
  List<Course> _courses = [];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount?.toString() ?? '',
    );
    _monthController = TextEditingController(
      text: widget.initialMonth ?? _getCurrentMonth(),
    );
    _selectedStudentId = widget.initialStudentId;
    _selectedCourseId = widget.initialCourseId;
    _isPaid = widget.initialPaid ?? false;
  }

  @override
  void dispose() {
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
                const Icon(Icons.payment, color: Colors.blue),
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
                  // Student Dropdown
                  BlocBuilder<StudentBloc, StudentState>(
                    builder: (context, state) {
                      if (state is StudentLoadedState) {
                        _students = state.students;
                      }
                      
                      return DropdownButtonFormField<int>(
                        value: _selectedStudentId,
                        decoration: const InputDecoration(
                          labelText: 'Select Student',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: _students.map((student) {
                          return DropdownMenuItem<int>(
                            value: student.id,
                            child: Text(student.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStudentId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a student';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Course Dropdown
                  BlocBuilder<CourseBloc, CourseState>(
                    builder: (context, state) {
                      if (state is CourseLoaded) {
                        _courses = state.courses;
                      }
                      
                      return DropdownButtonFormField<int>(
                        value: _selectedCourseId,
                        decoration: const InputDecoration(
                          labelText: 'Select Course',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.book),
                        ),
                        items: _courses.map((course) {
                          return DropdownMenuItem<int>(
                            value: course.id,
                            child: Text('${course.name} - \$${course.monthlyFee.toStringAsFixed(2)}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCourseId = value;
                            // Auto-fill amount with course fee
                            final selectedCourse = _courses.firstWhere((c) => c.id == value);
                            _amountController.text = selectedCourse.monthlyFee.toString();
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a course';
                          }
                          return null;
                        },
                      );
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
                      helperText: 'Amount will auto-fill when course is selected',
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
                  
                  const SizedBox(height: 16),
                  
                  // Paid Status
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        'Payment Status',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        _isPaid ? 'Paid ✓' : 'Unpaid ✗',
                        style: TextStyle(
                          color: _isPaid ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      value: _isPaid,
                      onChanged: (value) {
                        setState(() {
                          _isPaid = value;
                        });
                      },
                      activeColor: Colors.green,
                      secondary: Icon(
                        _isPaid ? Icons.check_circle : Icons.cancel,
                        color: _isPaid ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                // Auto-fill button for convenience
                OutlinedButton.icon(
                  onPressed: _selectedCourseId != null ? _autoFillFromCourse : null,
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Auto-fill'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Payment'),
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

  void _autoFillFromCourse() {
    if (_selectedCourseId != null) {
      final selectedCourse = _courses.firstWhere((c) => c.id == _selectedCourseId);
      setState(() {
        _amountController.text = selectedCourse.monthlyFee.toString();
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final studentId = _selectedStudentId!;
      final courseId = _selectedCourseId!;
      final amount = double.parse(_amountController.text.trim());
      final month = _monthController.text.trim();
      
      Navigator.pop(context);
      widget.onSubmit(studentId, courseId, amount, month, _isPaid);
    }
  }
}

// Simple Month Picker Dialog (reuse from previous implementation)
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