import 'package:flutter/material.dart';

class MonthYearPicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(String) onMonthYearSelected; // Format: YYYY-MM
  final String? selectedMonth;

  const MonthYearPicker({
    super.key,
    required this.initialDate,
    required this.onMonthYearSelected,
    this.selectedMonth,
  });

  @override
  State<MonthYearPicker> createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<MonthYearPicker> {
  late int selectedYear;
  late int selectedMonth;

  static const List<String> monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.selectedMonth != null) {
      final parts = widget.selectedMonth!.split('-');
      selectedYear = int.parse(parts[0]);
      selectedMonth = int.parse(parts[1]);
    } else {
      selectedYear = widget.initialDate.year;
      selectedMonth = widget.initialDate.month;
    }
  }

  String get formattedMonthYear {
    return '${selectedYear.toString()}-${selectedMonth.toString().padLeft(2, '0')}';
  }

  String get displayMonthYear {
    return '${monthNames[selectedMonth - 1]} $selectedYear';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Select Month & Year:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _showMonthYearDialog,
                icon: const Icon(Icons.edit_calendar),
                label: Text(displayMonthYear),
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
              _buildQuickSelectButton('This Month', DateTime.now()),
              _buildQuickSelectButton('Last Month', DateTime.now().subtract(const Duration(days: 30))),
              _buildQuickSelectButton('Next Month', DateTime.now().add(const Duration(days: 30))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSelectButton(String label, DateTime date) {
    final monthYear = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    final isSelected = formattedMonthYear == monthYear;
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              selectedYear = date.year;
              selectedMonth = date.month;
            });
            widget.onMonthYearSelected(formattedMonthYear);
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? Colors.blue : null,
            foregroundColor: isSelected ? Colors.white : Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _showMonthYearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                    final isSelected = month == selectedMonth;
                    
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
              widget.onMonthYearSelected(formattedMonthYear);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Select'),
          ),
        ],
      ),
    ).then((_) {
      // Refresh the parent widget to show updated selection
      setState(() {});
    });
  }
}