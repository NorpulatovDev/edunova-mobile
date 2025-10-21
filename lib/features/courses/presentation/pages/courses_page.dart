import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../teachers/data/models/teacher_models.dart';
import '../../../teachers/presentation/bloc/teacher_bloc.dart';
import '../../data/models/course_models.dart';
import '../bloc/course_bloc.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<CourseBloc>()..add(LoadCourses()),
        ),
        BlocProvider(
          create: (context) => getIt<TeacherBloc>()..add(LoadTeachersEvent()),
        ),
      ],
      child: const CoursesView(),
    );
  }
}

class CoursesView extends StatelessWidget {
  const CoursesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state is CourseError) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is CourseOperationSuccess) {
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
                    'Courses',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCourseDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Course'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Courses List
            Expanded(
              child: BlocBuilder<CourseBloc, CourseState>(
                builder: (context, state) {
                  if (state is CourseLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CourseLoaded) {
                    if (state.courses.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.book_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No Courses Found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add your first course to get started',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return _buildCoursesList(state.courses);
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

  Widget _buildCoursesList(List<Course> courses) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.book, color: Colors.blue),
            ),
            title: Text(
              course.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Teacher: ${course.teacherName ?? 'Unknown'}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  'Monthly Fee: \$${course.monthlyFee.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${course.studentCount} student(s) enrolled',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _showEditCourseDialog(context, course),
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Edit Course',
                ),
                IconButton(
                  onPressed: () => _showDeleteConfirmation(context, course),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete Course',
                ),
              ],
            ),
            children: [
              if (course.hasStudents) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Enrolled Students (${course.studentCount})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: course.students!.map((student) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.blue,
                                child: Text(
                                  student.name.isNotEmpty 
                                      ? student.name[0].toUpperCase()
                                      : 'S',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                student.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
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
                        Icons.people_outline,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No Students Enrolled',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Students will appear here when they enroll',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showAddCourseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: BlocProvider.of<CourseBloc>(context),
          ),
          BlocProvider.value(
            value: BlocProvider.of<TeacherBloc>(context),
          ),
        ],
        child: CourseFormDialog(
          title: 'Add Course',
          onSubmit: (name, teacherId, monthlyFee) {
            context.read<CourseBloc>().add(
                  CreateCourse(
                    name: name,
                    teacherId: teacherId,
                    monthlyFee: monthlyFee,
                  ),
                );
          },
        ),
      ),
    );
  }

  void _showEditCourseDialog(BuildContext context, Course course) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: BlocProvider.of<CourseBloc>(context),
          ),
          BlocProvider.value(
            value: BlocProvider.of<TeacherBloc>(context),
          ),
        ],
        child: CourseFormDialog(
          title: 'Edit Course',
          initialName: course.name,
          initialTeacherId: course.teacherId,
          initialMonthlyFee: course.monthlyFee,
          onSubmit: (name, teacherId, monthlyFee) {
            context.read<CourseBloc>().add(
                  UpdateCourse(
                    id: course.id!,
                    name: name,
                    teacherId: teacherId,
                    monthlyFee: monthlyFee,
                  ),
                );
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CourseBloc>().add(DeleteCourse(id: course.id!));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class CourseFormDialog extends StatefulWidget {
  final String title;
  final String? initialName;
  final int? initialTeacherId;
  final double? initialMonthlyFee;
  final Function(String name, int teacherId, double monthlyFee) onSubmit;

  const CourseFormDialog({
    super.key,
    required this.title,
    this.initialName,
    this.initialTeacherId,
    this.initialMonthlyFee,
    required this.onSubmit,
  });

  @override
  State<CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _feeController;
  int? _selectedTeacherId;
  List<Teacher> _teachers = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _feeController = TextEditingController(
      text: widget.initialMonthlyFee?.toString() ?? '',
    );
    _selectedTeacherId = widget.initialTeacherId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _feeController.dispose();
    super.dispose();
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
                Icon(Icons.book, color: Colors.blue),
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
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Course Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.book_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter course name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Teacher Dropdown
                  BlocBuilder<TeacherBloc, TeacherState>(
                    builder: (context, state) {
                      if (state is TeacherLoadedState) {
                        _teachers = state.teachers;
                      }
                      
                      return DropdownButtonFormField<int>(
                        value: _selectedTeacherId,
                        decoration: const InputDecoration(
                          labelText: 'Select Teacher',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: _teachers.map((teacher) {
                          return DropdownMenuItem<int>(
                            value: teacher.id,
                            child: Text(teacher.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTeacherId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a teacher';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _feeController,
                    decoration: const InputDecoration(
                      labelText: 'Monthly Fee',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                      suffixText: 'USD',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter monthly fee';
                      }
                      final fee = double.tryParse(value);
                      if (fee == null) {
                        return 'Please enter a valid number';
                      }
                      if (fee < 0) {
                        return 'Fee must be greater than or equal to 0';
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
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final teacherId = _selectedTeacherId!;
      final monthlyFee = double.parse(_feeController.text.trim());
      
      Navigator.pop(context);
      widget.onSubmit(name, teacherId, monthlyFee);
    }
  }
}