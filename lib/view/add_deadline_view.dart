import 'package:flutter/material.dart';
import 'package:choice/choice.dart';
import 'package:bottom_picker/bottom_picker.dart';

import '../model/task.dart';
import '../controller/schedule_service.dart';


class AddDeadlineView extends StatefulWidget {
  const AddDeadlineView({super.key});

  @override
  State<AddDeadlineView> createState() => _AddDeadlineViewState();
}

class _AddDeadlineViewState extends State<AddDeadlineView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScheduleService scheduleService = ScheduleService();

  String name = '';
  String course = '';
  DateTime dueDate = DateTime(2023, 1, 15);
  String description = '';

  List<String> priorityTags = ['low', 'medium', 'high'];

  String? selectedPriorityValue = 'low';

  void setSelectedPriorityValue(String? value) {
    setState(() => selectedPriorityValue = value);
  }

  Future<void> _addDeadline() async {
    // ignore: unused_local_variable
    final FormState form = _formKey.currentState!;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newDeadline = DeadlineTask(name: name, course: course, dueDate: dueDate,
        description: description, priority: selectedPriorityValue!, isComplete: false,
      );

      await scheduleService.addDeadline(newDeadline);

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();

    }
    else {
      print("Form is invalid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(
            'Add Deadline',
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              SizedBox(height: 20,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 10,),
                  Text('Name: ', style: TextStyle(fontSize: 16)),
                  SizedBox(
                    height: 70,
                    width: 250,
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        setState(() => name = value!);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 10,),
                  Text('Course: ', style: TextStyle(fontSize: 16)),
                  SizedBox(
                    height: 70,
                    width: 250,
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Course'),
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length != 8) {
                          return 'Please enter a Course in the ABCD1234 format';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        setState(() => course = value!);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Row(
                children: [
                  SizedBox(width: 10,),
                  Text('Due Date: ', style: TextStyle(fontSize: 16)),
                  // date time picker widget
                  SizedBox(
                    width: 70,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () {
                        BottomPicker.dateTime(
                          title: 'Set the event exact time and date',
                          titleStyle:  TextStyle(
                            fontWeight:  FontWeight.bold,
                            fontSize:  15,
                            color:  Colors.black,
                          ),
                          onSubmit: (date) {
                            //dueDate = date;
                            setState(() {
                              dueDate = date;
                            });
                            print(date);},
                          onClose: () {
                            print('Picker closed');},
                          iconColor:  Colors.black,
                          minDateTime:  DateTime(2024, 1, 1),
                          maxDateTime:  DateTime(2024, 4, 30),
                          initialDateTime:  DateTime(2024, 1, 15),
                          gradientColors: [Color(0xfffdcbf1), Color(0xffe6dee9)],
                        ).show(context);
                      },
                      child: Text('Date')//const Icon(Icons.date_range),'
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(dueDate.toString(), style: TextStyle(fontSize: 16)),
                ],
              ),
              SizedBox(height: 20,),
              Row(
                children: [
                  SizedBox(width: 10,),
                  Text('Description: ', style: TextStyle(fontSize: 16)),
                  SizedBox(
                    height: 70,
                    width: 250,
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Description'),
                      onSaved: (value) {
                        setState(() => description = value!);
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(width: 10,),
                  Text('Priority: ', style: TextStyle(fontSize: 16)),
                  InlineChoice<String>.single(
                    clearable: true,
                    value: selectedPriorityValue,
                    onChanged: setSelectedPriorityValue,
                    itemCount: priorityTags.length,
                    itemBuilder: (state, i) {
                      return ChoiceChip(
                        selected: state.selected(priorityTags[i]),
                        selectedColor: Colors.blue,
                        onSelected: state.onSelected(priorityTags[i]),
                        label: Text(priorityTags[i]),
                      );
                    },
                    listBuilder: ChoiceList.createScrollable(
                      spacing: 10,
                      runSpacing: 10,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30,),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _addDeadline();
                    //Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}