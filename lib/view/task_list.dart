import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controller/schedule_service.dart';
import '../model/task.dart';

class TaskList extends StatefulWidget {
  final List<DeadlineTask> userDeadlines;
  const TaskList({super.key, required this.userDeadlines});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {

  final ScheduleService scheduleService = ScheduleService();
  late List<DeadlineTask> deadlines = getDeadlines();

  int lastDate = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Deadlines'), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Add Task',
          iconSize: 35.0,
          onPressed: ()  {/* will direct to "Add Task" page */},
        ),
      ]),
      body: SingleChildScrollView(
        child: Column(
        children: [
          for (var i = 0; i < deadlines.length; i++) ...[
            checkDate(deadlines[i]),
            createTask(deadlines[i]),
            const Divider(height: 0),
          ]
        ],
      )),
    );
  }

  Container checkDate(DeadlineTask task) {
    String date = DateFormat('MMddyyyy').format(task.dueDate);
    if (lastDate != int.parse(date)) {
      lastDate = int.parse(date);
      // ignore: avoid_unnecessary_containers
      return Container(
          child: ListTile(
        tileColor: Colors.grey.shade300,
        title: Text(
          "${DateFormat('LLLL').format(task.dueDate)} ${task.dueDate.day}, ${task.dueDate.year}",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ));
    } else {
      return Container();
    } // return empty container and move onto next task
  }

  ListTile createTask(DeadlineTask task) {
    Color priorityColor = Colors.green;
    Color backgroundColor = Colors.white;
    if (task.priority == "medium" ) { priorityColor = Colors.amber; }
    if (task.priority == "high") { priorityColor = Colors.red; }

    if (task.status == "complete") { backgroundColor = Colors.grey.shade400; }

    Text titleText = Text.rich(TextSpan(children: <TextSpan>[

      // add flag for assignments due in < 24 hours
      if (0 < task.dueDate.difference(DateTime.now()).inHours && task.dueDate.difference(DateTime.now()).inHours < 24 && !(task.status=="complete"))
        TextSpan(text: "DUE SOON!\n", style: TextStyle(color: Colors.red)),
      
      // add flag for overdue assignments
      if (task.dueDate.isBefore(DateTime.now()) && !(task.status=="complete"))
        TextSpan(text: "LATE!\n", style: TextStyle(color: Colors.red)),

      // task name and course 
      TextSpan(text: "${task.name} - ${task.course}", style: TextStyle(fontWeight: FontWeight.bold))]
    ),);

    // the "body" text - includes task due date and descrption 
    Text taskText = Text.rich(TextSpan(
      children: <TextSpan>[
        TextSpan(text: "Due: ${DateFormat('LLLL').format(task.dueDate)} ${task.dueDate.day}, ${task.dueDate.year} at ${task.dueDate.hour}:${task.dueDate.minute}"),
        if (task.description.isNotEmpty) 
          TextSpan(text: "\n${task.description}"),]
    ));

    // highlight missed deadlines/overdue tasks  
    if (DateTime.now().isAfter(task.dueDate) && !(task.status=="complete")) {
      backgroundColor = Colors.red.shade100;
    }

    return ListTile(
      tileColor: backgroundColor,
      title: titleText,
      subtitle: taskText,
      
      leading: Icon(Icons.warning, color: priorityColor), // priority icon
      
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [ // checkbox
        Checkbox(
          value: (task.status=="complete"),
          onChanged: (bool? value) {
            setState(() {
              if(task.status=="complete"){ task.status = "incomplete";}
              else {task.status = "complete";}
            });
          },
        )
      ]),
    );
  }

  List<DeadlineTask> getDeadlines()  {
    List<DeadlineTask> deadlines = [];

    for (var element in widget.userDeadlines) {
      deadlines.add(element);
    }
    deadlines.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return deadlines;
  }
}