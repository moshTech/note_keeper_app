import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:note_keeper_app/model/note.dart';
import 'package:note_keeper_app/utils/database_helper.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  var _priorities = ['Low', 'High'];

  final _formKey = GlobalKey<FormState>();

  String _priority = 'Low';

  DatabaseHelper databaseHelper = DatabaseHelper();

  String appBarTitle;
  Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descripController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descripController.text = note.description;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: ListView(
            // First element
            children: <Widget>[
              ListTile(
                title: DropdownButton<String>(
                  value: getPriorityAsString(note.priority),
                  onChanged: (String valueSelectedByUser) {
                    setState(() {
                      debugPrint('User Selected $valueSelectedByUser');
//                    debugPrint((note.priority).toString());
                      updatePriorityAsInt(valueSelectedByUser);
//                    _priority = valueSelectedByUser;
                    });
                  },
                  items:
                      _priorities.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: textStyle,
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Second element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextFormField(
                  validator: (String value) {
                    if (value.isEmpty) return 'Please enter note title';
                  },
                  controller: titleController,
                  style: textStyle,
//                  onChanged: (value) {
//                    debugPrint('Something changed in Title TextField');
//                    updateTitle();
//                  },
                  decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )),
                ),
              ),

              // Third element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: descripController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('Something changed in Description TextField');
                    updateDescription();
                  },
                  decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    // Forth element
                    Expanded(
                      child: RaisedButton(
                          elevation: 20.0,
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Save',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_formKey.currentState.validate()) {
                                debugPrint('Save button clicked');
                                updateTitle();
                                _save();
                              }
                            });
                          }),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),

                    // Fifth element
                    Expanded(
                      child: RaisedButton(
                          elevation: 20.0,
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint('Delete button clicked');
                              _delete();
                            });
                          }),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Convert the String priority in the form of integer before saving it to the database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'Low':
        note.priority = 1;
        break;

      case 'High':
        note.priority = 2;
        break;
    }
  }

  // Convert the int priority to String priority and display it to user in dropdown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; // Low
        break;

      case 2:
        priority = _priorities[1]; // High
        break;
    }
    return priority;
  }

  // Update the title of the Note object
  void updateTitle() {
    note.title = titleController.text;
  }

  // Update the description of the Note object
  void updateDescription() {
    note.description = descripController.text;
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;

    if (note.id != null) // Case 1: Update operation
      result = await databaseHelper.updateNote(note);
    else // Case 2: Insert operation
      result = await databaseHelper.insertNote(note);

    if (result != 0) // Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    else
      _showAlertDialog('Status', 'Problem Saving Note');
  }

  void _delete() async {
    moveToLastScreen();

    // Case 1: User is trying to delete a new note i.e comes to the detail page with FAB
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    // Case 2: Deleting the old note that already has a valid ID
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) // Success
      _showAlertDialog('Status', 'Note Deleted Successfully');
    else
      _showAlertDialog('Status', 'Error Occured while Deleting the note');
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
