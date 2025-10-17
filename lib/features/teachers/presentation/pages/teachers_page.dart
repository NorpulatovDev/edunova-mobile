import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/teacher_models.dart';
import '../bloc/teacher_bloc.dart';

class TeachersPage extends StatelessWidget {
  const TeachersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TeacherBloc>()..add(LoadTeachersEvent()),
      child: const TeachersView(),
    );
  }
}

class TeachersView extends StatelessWidget {
  const TeachersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<TeacherBloc, TeacherState>(
        listener: (context, state) {
          if (state is TeacherErrorState) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is TeacherOperationSuccessState) {
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Teachers',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddTeacherDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Teacher'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<TeacherBloc, TeacherState>(
                builder: (context, state) {
                  if (state is TeacherLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TeacherLoadedState) {
                    if (state.teachers.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No teachers found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add your first teacher to get started',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.teachers.length,
                      itemBuilder: (context, index) {
                        final teacher = state.teachers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                teacher.name.isNotEmpty 
                                    ? teacher.name[0].toUpperCase()
                                    : 'T',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              teacher.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Salary Percentage: ${teacher.salaryPercentage}%',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _showEditTeacherDialog(context, teacher),
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                ),
                                IconButton(
                                  onPressed: () => _showDeleteConfirmation(context, teacher),
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
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

  void _showAddTeacherDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => TeacherFormDialog(
        title: 'Add Teacher',
        onSubmit: (name, salaryPercentage) {
          context.read<TeacherBloc>().add(
                CreateTeacherEvent(
                  name: name,
                  salaryPercentage: salaryPercentage,
                ),
              );
        },
      ),
    );
  }

  void _showEditTeacherDialog(BuildContext context, Teacher teacher) {
    showDialog(
      context: context,
      builder: (dialogContext) => TeacherFormDialog(
        title: 'Edit Teacher',
        initialName: teacher.name,
        initialSalaryPercentage: teacher.salaryPercentage,
        onSubmit: (name, salaryPercentage) {
          context.read<TeacherBloc>().add(
                UpdateTeacherEvent(
                  id: teacher.id!,
                  name: name,
                  salaryPercentage: salaryPercentage,
                ),
              );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Teacher teacher) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: Text('Are you sure you want to delete ${teacher.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<TeacherBloc>().add(DeleteTeacherEvent(id: teacher.id!));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class TeacherFormDialog extends StatefulWidget {
  final String title;
  final String? initialName;
  final double? initialSalaryPercentage;
  final Function(String name, double salaryPercentage) onSubmit;

  const TeacherFormDialog({
    super.key,
    required this.title,
    this.initialName,
    this.initialSalaryPercentage,
    required this.onSubmit,
  });

  @override
  State<TeacherFormDialog> createState() => _TeacherFormDialogState();
}

class _TeacherFormDialogState extends State<TeacherFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _salaryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _salaryController = TextEditingController(
      text: widget.initialSalaryPercentage?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter teacher name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _salaryController,
              decoration: const InputDecoration(
                labelText: 'Salary Percentage (%)',
                border: OutlineInputBorder(),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter salary percentage';
                }
                final percentage = double.tryParse(value);
                if (percentage == null) {
                  return 'Please enter a valid number';
                }
                if (percentage < 0 || percentage > 100) {
                  return 'Percentage must be between 0 and 100';
                }
                return null;
              },
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
      final salaryPercentage = double.parse(_salaryController.text.trim());
      
      Navigator.pop(context);
      widget.onSubmit(name, salaryPercentage);
    }
  }
}