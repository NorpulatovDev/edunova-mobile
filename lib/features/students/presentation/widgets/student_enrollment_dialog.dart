import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/student_models.dart';
import '../bloc/student_bloc.dart';
import '../../../courses/data/models/course_models.dart';
import '../../../courses/presentation/bloc/course_bloc.dart';


class StudentEnrollmentDialog extends StatefulWidget {
  final Student student;

  const StudentEnrollmentDialog({
    super.key,
    required this.student,
  });

  @override
  State<StudentEnrollmentDialog> createState() => _StudentEnrollmentDialogState();
}

class _StudentEnrollmentDialogState extends State<StudentEnrollmentDialog> {
  List<int> selectedCourseIds = [];
  List<Course> availableCourses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize with current enrolled courses
    selectedCourseIds = widget.student.courses?.map((c) => c.id).toList() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CourseBloc>()..add(LoadCourses()),
      child: Dialog(
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
                      widget.student.name.isNotEmpty 
                          ? widget.student.name[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enroll ${widget.student.name}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Select courses to enroll in',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
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
              
              // Course selection
              Expanded(
                child: BlocListener<CourseBloc, CourseState>(
                  listener: (context, state) {
                    if (state is CourseLoaded) {
                      setState(() {
                        availableCourses = state.courses;
                        isLoading = false;
                      });
                    } else if (state is CourseError) {
                      setState(() {
                        isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: BlocBuilder<CourseBloc, CourseState>(
                    builder: (context, state) {
                      if (state is CourseLoading || isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (availableCourses.isEmpty) {
                        return const Center(
                          child: Text('No courses available'),
                        );
                      }
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${selectedCourseIds.length} course(s) selected',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                if (selectedCourseIds.isNotEmpty)
                                  Text(
                                    'Total: \$${_calculateTotalFee().toStringAsFixed(2)}/month',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Course list
                          const Text(
                            'Available Courses:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Expanded(
                            child: ListView.builder(
                              itemCount: availableCourses.length,
                              itemBuilder: (context, index) {
                                final course = availableCourses[index];
                                final isSelected = selectedCourseIds.contains(course.id);
                                
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: CheckboxListTile(
                                    value: isSelected,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          selectedCourseIds.add(course.id!);
                                        } else {
                                          selectedCourseIds.remove(course.id!);
                                        }
                                      });
                                    },
                                    title: Text(
                                      course.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Teacher: ${course.teacherName ?? 'N/A'}'),
                                        Text(
                                          'Fee: \$${course.monthlyFee.toStringAsFixed(2)}/month',
                                          style: TextStyle(
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    secondary: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.book, color: Colors.blue),
                                    ),
                                    controlAffinity: ListTileControlAffinity.trailing,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedCourseIds.clear();
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedCourseIds = availableCourses.map((c) => c.id!).toList();
                      });
                    },
                    child: const Text('Select All'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: selectedCourseIds.isEmpty ? null : _handleEnrollment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Enroll'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTotalFee() {
    return availableCourses
        .where((course) => selectedCourseIds.contains(course.id))
        .fold(0.0, (sum, course) => sum + course.monthlyFee);
  }

  void _handleEnrollment() {
    Navigator.pop(context);
    
    // Trigger enrollment
    context.read<StudentBloc>().add(
      EnrollStudentInCoursesEvent(
        studentId: widget.student.id!,
        courseIds: selectedCourseIds,
      ),
    );
  }
}