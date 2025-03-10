import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(PlanManagerApp());
}

class PlanManagerApp extends StatelessWidget {
  const PlanManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PlanManagerScreen(),
    );
  }
}

class Plan {
  String name;
  String description;
  DateTime date;
  bool isCompleted;

  Plan({
    required this.name,
    required this.description,
    required this.date,
    this.isCompleted = false,
  });
}

class PlanManagerScreen extends StatefulWidget {
  const PlanManagerScreen({super.key});

  @override
  State<PlanManagerScreen> createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = [];
  Plan? draggedPlan;
  DateTime selectedDate = DateTime.now();

  void _createPlan() {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        String description = '';

        return AlertDialog(
          title: Text('Create Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Plan Name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                if (name.isNotEmpty) {
                  setState(() {
                    plans.add(
                      Plan(
                        name: name,
                        description: description,
                        date: selectedDate,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _markCompleted(Plan plan) {
    setState(() {
      plan.isCompleted = !plan.isCompleted;
    });
  }

  void _deletePlan(int index) {
    setState(() {
      plans.removeAt(index);
    });
  }

  void _editPlan(int index) {
    showDialog(
      context: context,
      builder: (context) {
        String name = plans[index].name;
        String description = plans[index].description;

        return AlertDialog(
          title: Text('Edit Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Plan Name'),
                controller: TextEditingController(text: name),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                controller: TextEditingController(text: description),
                onChanged: (value) => description = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  plans[index] = Plan(
                    name: name,
                    description: description,
                    date: plans[index].date,
                    isCompleted: plans[index].isCompleted,
                  );
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      focusedDay: selectedDate,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),
      selectedDayPredicate: (day) => isSameDay(day, selectedDate),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          selectedDate = selectedDay;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Plan Manager')),
      body: Column(
        children: [
          _buildCalendar(),
          Expanded(
            child: ListView.builder(
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return GestureDetector(
                  onLongPress: () => _editPlan(index),
                  onHorizontalDragEnd: (_) => _markCompleted(plan),
                  onDoubleTap: () => _deletePlan(index),
                  child: ListTile(
                    tileColor:
                        plan.isCompleted
                            ? Colors.green.shade200
                            : Colors.grey.shade200,
                    title: Text(
                      plan.name,
                      style: TextStyle(
                        decoration:
                            plan.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
                    subtitle: Text(
                      "${plan.description} | ${DateFormat.yMMMd().format(plan.date)}",
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPlan,
        child: Icon(Icons.add),
      ),
    );
  }
}
