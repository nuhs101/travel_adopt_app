import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  void _createPlan() {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        String description = '';
        DateTime selectedDate = DateTime.now();

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
              ElevatedButton(
                child: Text("Pick Date"),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
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

  void _editPlan(int index) {
    _createPlan();
  }

  void _toggleComplete(int index) {
    setState(() {
      plans[index].isCompleted = !plans[index].isCompleted;
    });
  }

  void _deletePlan(int index) {
    setState(() {
      plans.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Plan Manager')),
      body: ListView.builder(
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return Dismissible(
            key: Key(plan.name),
            background: Container(
              color: Colors.green,
              child: Icon(Icons.check),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              child: Icon(Icons.delete),
            ),
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                _toggleComplete(index);
              } else {
                _deletePlan(index);
              }
            },
            child: ListTile(
              title: Text(
                plan.name,
                style: TextStyle(
                  decoration:
                      plan.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                ),
              ),
              subtitle: Text(
                "${plan.description} | ${DateFormat.yMMMd().format(plan.date)}",
              ),
              onLongPress: () => _editPlan(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPlan,
        child: Icon(Icons.add),
      ),
    );
  }
}
