import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../students/data/models/student_models.dart';
import '../../../students/presentation/bloc/student_bloc.dart';
import '../../../courses/data/models/course_models.dart';
import '../../../courses/presentation/bloc/course_bloc.dart';
import '../../data/models/payment_models.dart';
import '../bloc/payment_bloc.dart';
import '../widgets/payment_form_dialog.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<PaymentBloc>()..add(LoadPayments()),
        ),
        BlocProvider(
          create: (context) => getIt<StudentBloc>()..add(LoadStudentsEvent()),
        ),
        BlocProvider(
          create: (context) => getIt<CourseBloc>()..add(LoadCourses()),
        ),
      ],
      child: const PaymentsView(),
    );
  }
}

class PaymentsView extends StatefulWidget {
  const PaymentsView({super.key});

  @override
  State<PaymentsView> createState() => _PaymentsViewState();
}

class _PaymentsViewState extends State<PaymentsView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      body: BlocListener<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentError) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is PaymentOperationSuccess) {
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
            // Header with filters
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
                        'Payments',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddPaymentDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Payment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Month Filter
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Filter by Month:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: _showMonthPicker,
                        child: Text(
                          _selectedMonth != null
                              ? _formatMonth(_selectedMonth!)
                              : 'Select Month',
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_selectedMonth != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedMonth = null;
                            });
                            context.read<PaymentBloc>().add(LoadPayments());
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
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.list),
                        SizedBox(width: 8),
                        Text('All Payments'),
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
                children: [_buildPaymentsList(), _buildPaymentsSummary()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsList() {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        if (state is PaymentLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PaymentLoaded) {
          if (state.payments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No Payments Found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add your first payment to get started',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return _buildPaymentsListView(state.payments);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildPaymentsListView(List<Payment> payments) {
    final paidPayments = payments.where((p) => p.paid).toList();
    final unpaidPayments = payments.where((p) => !p.paid).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (unpaidPayments.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  '${unpaidPayments.length} Unpaid Payment(s)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...unpaidPayments.map((payment) => _buildPaymentCard(payment)),
          const SizedBox(height: 16),
        ],

        if (paidPayments.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  '${paidPayments.length} Paid Payment(s)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...paidPayments.map((payment) => _buildPaymentCard(payment)),
        ],
      ],
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: payment.paid ? Colors.green : Colors.red,
          child: Icon(
            payment.paid ? Icons.check : Icons.close,
            color: Colors.white,
          ),
        ),
        title: Text(
          payment.studentName ?? 'Student ${payment.studentId}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course: ${payment.courseName ?? 'Course ${payment.courseId}'}',
            ),
            Text('Month: ${payment.formattedMonth}'),
            Text(
              'Status: ${payment.statusText}',
              style: TextStyle(
                color: payment.paid ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\$${payment.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) => _handlePaymentAction(value, payment),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        payment.paid ? Icons.money_off : Icons.check_circle,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(payment.paid ? 'Mark Unpaid' : 'Mark Paid'),
                    ],
                  ),
                ),
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
          ],
        ),
      ),
    );
  }

  void _handlePaymentAction(String action, Payment payment) {
    switch (action) {
      case 'toggle':
        context.read<PaymentBloc>().add(TogglePaymentStatus(payment: payment));
        break;
      case 'edit':
        _showEditPaymentDialog(context, payment);
        break;
      case 'delete':
        _showDeleteConfirmation(context, payment);
        break;
    }
  }

  Widget _buildPaymentsSummary() {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        if (state is PaymentLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PaymentLoaded) {
          return _buildSummaryView(state.payments);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildSummaryView(List<Payment> payments) {
    final paidPayments = payments.where((p) => p.paid).toList();
    final unpaidPayments = payments.where((p) => !p.paid).toList();

    final totalAmount = payments.fold(0.0, (sum, p) => sum + p.amount);
    final paidAmount = paidPayments.fold(0.0, (sum, p) => sum + p.amount);
    final unpaidAmount = unpaidPayments.fold(0.0, (sum, p) => sum + p.amount);

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
                  'Total Payments',
                  payments.length.toString(),
                  '\$${totalAmount.toStringAsFixed(2)}',
                  Colors.blue,
                  Icons.payment,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Paid',
                  paidPayments.length.toString(),
                  '\$${paidAmount.toStringAsFixed(2)}',
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Unpaid',
                  unpaidPayments.length.toString(),
                  '\$${unpaidAmount.toStringAsFixed(2)}',
                  Colors.red,
                  Icons.warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            'Monthly Breakdown',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildMonthlyBreakdown(payments),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String count,
    String amount,
    Color color,
    IconData icon,
  ) {
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
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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

  Widget _buildMonthlyBreakdown(List<Payment> payments) {
    final Map<String, List<Payment>> paymentsByMonth = {};
    for (final payment in payments) {
      paymentsByMonth.putIfAbsent(payment.month, () => []).add(payment);
    }

    final sortedMonths = paymentsByMonth.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      children: sortedMonths.map((month) {
        final monthPayments = paymentsByMonth[month]!;
        final paidCount = monthPayments.where((p) => p.paid).length;
        final unpaidCount = monthPayments.where((p) => !p.paid).length;
        final totalAmount = monthPayments.fold(0.0, (sum, p) => sum + p.amount);
        final paidAmount = monthPayments
            .where((p) => p.paid)
            .fold(0.0, (sum, p) => sum + p.amount);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text(
              _formatMonth(month),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${monthPayments.length} payments • \$${totalAmount.toStringAsFixed(2)} total',
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$paidCount',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Text('Paid'),
                            Text(
                              '\$${paidAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$unpaidCount',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const Text('Unpaid'),
                            Text(
                              '\$${(totalAmount - paidAmount).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
        '',
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
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
          setState(() => _selectedMonth = month);
          if (month != null) {
            context.read<PaymentBloc>().add(LoadPaymentsByMonth(month: month));
          } else {
            context.read<PaymentBloc>().add(LoadPayments());
          }
        },
      ),
    );
  }

  void _showAddPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: BlocProvider.of<PaymentBloc>(context)),
          BlocProvider.value(value: BlocProvider.of<StudentBloc>(context)),
          BlocProvider.value(value: BlocProvider.of<CourseBloc>(context)),
        ],
        child: PaymentFormDialog(
          title: 'Add Payment',
          onSubmit: (studentId, courseId, amount, month, paid) {
            context.read<PaymentBloc>().add(
              CreatePayment(
                studentId: studentId,
                courseId: courseId,
                amount: amount,
                month: month,
                paid: paid,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showEditPaymentDialog(BuildContext context, Payment payment) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: BlocProvider.of<PaymentBloc>(context)),
          BlocProvider.value(value: BlocProvider.of<StudentBloc>(context)),
          BlocProvider.value(value: BlocProvider.of<CourseBloc>(context)),
        ],
        child: PaymentFormDialog(
          title: 'Edit Payment',
          initialStudentId: payment.studentId,
          initialCourseId: payment.courseId,
          initialAmount: payment.amount,
          initialMonth: payment.month,
          initialPaid: payment.paid,
          onSubmit: (studentId, courseId, amount, month, paid) {
            context.read<PaymentBloc>().add(
              UpdatePayment(
                id: payment.id!,
                studentId: studentId,
                courseId: courseId,
                amount: amount,
                month: month,
                paid: paid,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Payment payment) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Payment'),
        content: Text(
          'Are you sure you want to delete this payment for ${payment.studentName ?? 'Student ${payment.studentId}'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<PaymentBloc>().add(DeletePayment(id: payment.id!));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
                    '',
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec',
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
                          color: isSelected
                              ? Colors.blue
                              : Colors.grey.shade300,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        monthNames[month],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
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
            final monthStr =
                '${selectedYear}-${selectedMonth.toString().padLeft(2, '0')}';
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
