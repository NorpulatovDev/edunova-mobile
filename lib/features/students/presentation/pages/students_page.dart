import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/student_models.dart';
import '../bloc/student_bloc.dart';
import '../widgets/student_enrollment_dialog.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<StudentBloc>()..add(LoadStudentsEvent()),
      child: const StudentsView(),
    );
  }
}

class StudentsView extends StatefulWidget {
  const StudentsView({super.key});

  @override
  State<StudentsView> createState() => _StudentsViewState();
}

class _StudentsViewState extends State<StudentsView> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<StudentBloc, StudentState>(
        listener: (context, state) {
          if (state is StudentErrorState) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is StudentOperationSuccessState) {
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Students',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddStudentDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Student'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Tabs with dynamic badges
            BlocBuilder<StudentBloc, StudentState>(
              builder: (context, state) {
                List<Student> enrolledStudents = [];
                List<Student> notEnrolledStudents = [];
                
                if (state is StudentLoadedState) {
                  enrolledStudents = state.students.where((s) => s.hasEnrollments).toList();
                  notEnrolledStudents = state.students.where((s) => !s.hasEnrollments).toList();
                }
                
                return Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.school),
                            const SizedBox(width: 8),
                            const Text('Enrolled'),
                            if (enrolledStudents.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${enrolledStudents.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_outlined),
                            const SizedBox(width: 8),
                            const Text('Not Enrolled'),
                            if (notEnrolledStudents.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${notEnrolledStudents.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Enrolled Students Tab
                  _buildStudentsList(enrolled: true),
                  // Not Enrolled Students Tab
                  _buildStudentsList(enrolled: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList({required bool enrolled}) {
    return BlocBuilder<StudentBloc, StudentState>(
      builder: (context, state) {
        if (state is StudentLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StudentLoadedState) {
          final filteredStudents = state.students
              .where((student) => enrolled ? student.hasEnrollments : !student.hasEnrollments)
              .toList();

          if (filteredStudents.isEmpty) {
            return _buildEmptyState(enrolled);
          }

          return Column(
            children: [
              // Revenue Summary for enrolled students
              if (enrolled && filteredStudents.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.green.shade50,
                  child: Row(
                    children: [
                      Icon(Icons.analytics, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${filteredStudents.length} students enrolled',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            Text(
                              'Total monthly revenue: \$${_calculateTotalRevenue(filteredStudents).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Students List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
                    return _buildStudentCard(student, enrolled);
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildEmptyState(bool enrolled) {
    if (enrolled) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Enrolled Students',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Students with course enrollments will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'All Students Enrolled! 🎉',
              style: TextStyle(
                fontSize: 18,
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Every student is enrolled in at least one course',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildStudentCard(Student student, bool isEnrolled) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isEnrolled ? 2 : 1,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isEnrolled ? Colors.green : Colors.orange,
          child: Text(
            student.name.isNotEmpty 
                ? student.name[0].toUpperCase()
                : 'S',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          student.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isEnrolled
              ? '${student.enrollmentCount} course(s) • \$${student.totalMonthlyFee.toStringAsFixed(2)}/month'
              : 'Ready for enrollment',
          style: TextStyle(
            color: isEnrolled ? Colors.green.shade700 : Colors.orange.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _showEnrollmentDialog(context, student),
              icon: Icon(
                isEnrolled ? Icons.edit_note : Icons.school,
                color: isEnrolled ? Colors.blue : Colors.orange,
              ),
              tooltip: isEnrolled ? 'Manage Enrollment' : 'Enroll in Courses',
            ),
            IconButton(
              onPressed: () => _showEditStudentDialog(context, student),
              icon: const Icon(Icons.edit, color: Colors.grey),
              tooltip: 'Edit Student',
            ),
            IconButton(
              onPressed: () => _showDeleteConfirmation(context, student),
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete Student',
            ),
          ],
        ),
        children: [
          if (isEnrolled) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Enrolled Courses:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Total: \$${student.totalMonthlyFee.toStringAsFixed(2)}/month',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...student.courses!.map((course) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.book, size: 16, color: Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Teacher: ${course.teacherName}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${course.monthlyFee.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ] else ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 48,
                    color: Colors.orange.shade300,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No Course Enrollments',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Click the enrollment button to add courses',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showEnrollmentDialog(context, student),
                    icon: const Icon(Icons.add),
                    label: const Text('Enroll in Courses'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _calculateTotalRevenue(List<Student> students) {
    return students.fold(0.0, (sum, student) => sum + student.totalMonthlyFee);
  }

  void _showEnrollmentDialog(BuildContext context, Student student) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: BlocProvider.of<StudentBloc>(context),
        child: StudentEnrollmentDialog(student: student),
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => StudentFormDialog(
        title: 'Add Student',
        onSubmit: (name) {
          context.read<StudentBloc>().add(
                CreateStudentEvent(name: name),
              );
        },
      ),
    );
  }

  void _showEditStudentDialog(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (dialogContext) => StudentFormDialog(
        title: 'Edit Student',
        initialName: student.name,
        onSubmit: (name) {
          context.read<StudentBloc>().add(
                UpdateStudentEvent(id: student.id!, name: name),
              );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<StudentBloc>().add(DeleteStudentEvent(id: student.id!));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class StudentFormDialog extends StatefulWidget {
  final String title;
  final String? initialName;
  final Function(String name) onSubmit;

  const StudentFormDialog({
    super.key,
    required this.title,
    this.initialName,
    required this.onSubmit,
  });

  @override
  State<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<StudentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Student Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter student name';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      Navigator.pop(context);
      widget.onSubmit(name);
    }
  }
}