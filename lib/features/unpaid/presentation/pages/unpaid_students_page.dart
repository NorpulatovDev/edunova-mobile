import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/unpaid_models.dart';
import '../bloc/unpaid_bloc.dart';
import '../widgets/month_year_picker.dart';

class UnpaidStudentsPage extends StatelessWidget {
  const UnpaidStudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<UnpaidBloc>(),
      child: const UnpaidStudentsView(),
    );
  }
}

class UnpaidStudentsView extends StatefulWidget {
  const UnpaidStudentsView({super.key});

  @override
  State<UnpaidStudentsView> createState() => _UnpaidStudentsViewState();
}

class _UnpaidStudentsViewState extends State<UnpaidStudentsView> {
  String selectedMonth = '';
  UnpaidViewType selectedViewType = UnpaidViewType.complete;

  @override
  void initState() {
    super.initState();
    // Set current month as default
    final now = DateTime.now();
    selectedMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUnpaidData();
    });
  }

  void _loadUnpaidData() {
    switch (selectedViewType) {
      case UnpaidViewType.complete:
        context.read<UnpaidBloc>().add(
          LoadCompleteUnpaidSummaryEvent(month: selectedMonth),
        );
        break;
      case UnpaidViewType.unpaidOnly:
        context.read<UnpaidBloc>().add(
          LoadUnpaidStudentsByMonthEvent(month: selectedMonth),
        );
        break;
      case UnpaidViewType.missingOnly:
        context.read<UnpaidBloc>().add(
          LoadStudentsWithMissingPaymentsEvent(month: selectedMonth),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<UnpaidBloc, UnpaidState>(
        listener: (context, state) {
          if (state is UnpaidErrorState) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Unpaid Students',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Month Year Picker
                  MonthYearPicker(
                    initialDate: DateTime.now(),
                    selectedMonth: selectedMonth,
                    onMonthYearSelected: (month) {
                      setState(() {
                        selectedMonth = month;
                      });
                      _loadUnpaidData();
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // View Type Selector
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'View Type:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildViewTypeButton(
                                'Complete',
                                'All unpaid & missing',
                                UnpaidViewType.complete,
                                Icons.assignment_late,
                              ),
                            ),
                            Expanded(
                              child: _buildViewTypeButton(
                                'Unpaid Only',
                                'Registered but unpaid',
                                UnpaidViewType.unpaidOnly,
                                Icons.money_off,
                              ),
                            ),
                            Expanded(
                              child: _buildViewTypeButton(
                                'Missing Only',
                                'No payment registered',
                                UnpaidViewType.missingOnly,
                                Icons.warning,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: BlocBuilder<UnpaidBloc, UnpaidState>(
                builder: (context, state) {
                  if (state is UnpaidLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UnpaidStudentsLoadedState) {
                    if (state.unpaidStudents.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildUnpaidStudentsList(state.unpaidStudents);
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewTypeButton(
    String title,
    String subtitle,
    UnpaidViewType type,
    IconData icon,
  ) {
    final isSelected = selectedViewType == type;
    
    return InkWell(
      onTap: () {
        setState(() {
          selectedViewType = type;
        });
        _loadUnpaidData();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : null,
          border: isSelected 
              ? Border.all(color: Colors.blue, width: 2)
              : Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isSelected ? Colors.blue : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.blue.shade700 : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message = '';
    IconData icon = Icons.check_circle_outline;
    
    switch (selectedViewType) {
      case UnpaidViewType.complete:
        message = 'No unpaid or missing payments found';
        break;
      case UnpaidViewType.unpaidOnly:
        message = 'No unpaid payments found';
        break;
      case UnpaidViewType.missingOnly:
        message = 'No missing payments found';
        break;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All payments are up to date for $selectedMonth',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnpaidStudentsList(List<UnpaidStudent> unpaidStudents) {
    double totalUnpaid = unpaidStudents.fold(
      0.0,
      (sum, student) => sum + student.totalUnpaidAmount,
    );

    return Column(
      children: [
        // Summary header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.red.shade50,
          child: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${unpaidStudents.length} students with unpaid amounts',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Total unpaid: \$${totalUnpaid.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Students list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: unpaidStudents.length,
            itemBuilder: (context, index) {
              final student = unpaidStudents[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Text(
                      student.studentName.isNotEmpty 
                          ? student.studentName[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    student.studentName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Unpaid: \$${student.totalUnpaidAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${student.unpaidPaymentsCount} unpaid payment(s)',
                      ),
                    ],
                  ),
                  children: [
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Unpaid Payments:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...student.unpaidPayments.map((payment) => Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: payment.paymentId == null 
                                  ? Colors.orange.shade50 
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: payment.paymentId == null 
                                    ? Colors.orange.shade200 
                                    : Colors.red.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  payment.paymentId == null 
                                      ? Icons.warning 
                                      : Icons.money_off,
                                  color: payment.paymentId == null 
                                      ? Colors.orange 
                                      : Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${payment.courseName} - ${payment.teacherName}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        payment.paymentId == null 
                                            ? 'Missing payment for ${payment.month}'
                                            : 'Unpaid for ${payment.month}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\${payment.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: payment.paymentId == null 
                                        ? Colors.orange.shade700 
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

enum UnpaidViewType {
  complete,
  unpaidOnly,
  missingOnly,
}