// lib/features/teachers/presentation/widgets/teacher_salary_dialog.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/teacher_models.dart';
import '../../data/models/teacher_salary_models.dart';

class TeacherSalaryDialog extends StatefulWidget {
  final Teacher teacher;

  const TeacherSalaryDialog({super.key, required this.teacher});

  @override
  State<TeacherSalaryDialog> createState() => _TeacherSalaryDialogState();
}

class _TeacherSalaryDialogState extends State<TeacherSalaryDialog> {
  String selectedMonth = '';
  TeacherSalary? salary;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    _loadSalary();
  }

  Future<void> _loadSalary() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final apiClient = getIt<ApiClient>();
      final response = await apiClient.get('/salaries/teacher/${widget.teacher.id}/month/$selectedMonth');
      setState(() {
        salary = TeacherSalary.fromJson(response.data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(
                    widget.teacher.name.isNotEmpty 
                        ? widget.teacher.name[0].toUpperCase()
                        : 'T',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.teacher.name} - Salary',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Salary Percentage: ${widget.teacher.salaryPercentage}%',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Month Picker
            _buildMonthPicker(),
            
            const SizedBox(height: 24),
            
            // Content
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? _buildErrorContent()
                      : salary != null
                          ? _buildSalaryContent()
                          : const Center(child: Text('No data available')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthPicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Select Month & Year:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _showMonthYearDialog,
                icon: const Icon(Icons.edit_calendar),
                label: Text(_getDisplayMonthYear()),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickButton('This Month', DateTime.now()),
              _buildQuickButton('Last Month', DateTime.now().subtract(const Duration(days: 30))),
              _buildQuickButton('Next Month', DateTime.now().add(const Duration(days: 30))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String label, DateTime date) {
    final monthYear = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    final isSelected = selectedMonth == monthYear;
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          onPressed: () => _selectMonth(monthYear),
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? Colors.blue : null,
            foregroundColor: isSelected ? Colors.white : Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          child: Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Widget _buildSalaryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Cards
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Payments',
                '\$${salary!.totalPaymentsReceived.toStringAsFixed(2)}',
                Icons.payment,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Calculated Salary',
                '\$${salary!.calculatedSalary.toStringAsFixed(2)}',
                Icons.account_balance_wallet,
                Colors.green,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        const Text(
          'Payment Details:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        
        const SizedBox(height: 12),
        
        Expanded(
          child: salary!.payments.isEmpty
              ? _buildNoPayments()
              : ListView.builder(
                  itemCount: salary!.payments.length,
                  itemBuilder: (context, index) {
                    final payment = salary!.payments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        ),
                        title: Text(payment.courseName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Student: ${payment.studentName}'),
                        trailing: Text(
                          '\$${payment.amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
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
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPayments() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Payments Found',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'No paid payments found for ${_getDisplayMonthYear()}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(fontSize: 18, color: Colors.red.shade700, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            style: TextStyle(fontSize: 14, color: Colors.red.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSalary,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _getDisplayMonthYear() {
    final parts = selectedMonth.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${monthNames[month - 1]} $year';
  }

  void _selectMonth(String month) {
    setState(() {
      selectedMonth = month;
    });
    _loadSalary();
  }

  void _showMonthYearDialog() {
    final parts = selectedMonth.split('-');
    int selectedYear = int.parse(parts[0]);
    int selectedMonthInt = int.parse(parts[1]);

    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Month & Year'),
          content: SizedBox(
            width: 300,
            height: 400,
            child: Column(
              children: [
                // Year selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => setDialogState(() => selectedYear--),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      selectedYear.toString(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => setDialogState(() => selectedYear++),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Month grid
                Expanded(
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
                      final isSelected = month == selectedMonthInt;
                      
                      return InkWell(
                        onTap: () => setDialogState(() => selectedMonthInt = month),
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
                            monthNames[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
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
                Navigator.pop(context);
                final newMonth = '$selectedYear-${selectedMonthInt.toString().padLeft(2, '0')}';
                _selectMonth(newMonth);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Select'),
            ),
          ],
        ),
      ),
    );
  }
}