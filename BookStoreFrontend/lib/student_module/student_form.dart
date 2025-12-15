import 'package:flutter/material.dart';
import 'message_util.dart';
import 'student_model.dart';
import 'student_service.dart';

class StudentForm extends StatefulWidget {
  Student? item;
  StudentForm({this.item});

  @override
  State<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  bool _saved = false;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _studentService = StudentService();

  @override
  void initState() {
    super.initState();
    if (this.widget.item != null) {
      _nameCtrl.text = this.widget.item!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(_saved);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(_saved);
            },
            icon: Icon(Icons.arrow_back_ios_new),
          ),
          title: Text(
            this.widget.item == null ? "Insert Student" : "Update Student",
          ),
          actions: [this.widget.item != null ? _buildDeleteIcon() : SizedBox()],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildDeleteIcon() {
    return IconButton(
      onPressed: () async {
        bool deleted = await showDeleteConfirmation(context) ?? false;
        if (deleted) {
          _deleteStudent();
        }
      },
      icon: Icon(Icons.delete),
    );
  }

  void _deleteStudent() {
    _studentService
        .destroy(this.widget.item!.sid)
        .then((deleted) {
          if (deleted) {
            showMessage(context, "Data Deleted");
            _saved = true;
            Navigator.of(context).pop(_saved);
          }
        })
        .onError((e, s) {
          debugPrint(e.toString());
        });
  }

  Widget _buildBody() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(8),
        children: [_buildNameTextField(), _buildSaveButton()],
      ),
    );
  }

  Widget _buildNameTextField() {
    return TextFormField(
      controller: _nameCtrl,
      decoration: InputDecoration(
        hintText: "Enter Name",
        prefixIcon: Icon(Icons.text_fields),
        border: OutlineInputBorder(),
      ),
      validator: (String? text) {
        if (text!.isEmpty) {
          return "Name is required";
        }
        return null; // no error, return null
      },
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          if (this.widget.item == null) {
            _insertStudent();
          } else {
            _updateStudent();
          }
        }
      },
      child: Text("Save Changes"),
    );
  }

  void _insertStudent() {
    final student = Student(
      sid: 0,
      name: _nameCtrl.text.trim(),
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    _studentService
        .store(context, student)
        .then((stored) {
          if (stored) {
            showMessage(context, "Data Saved");
            _saved = true;
          }
        })
        .onError((e, s) {
          debugPrint(e.toString());
        });
  }

  void _updateStudent() {
    final student = Student(
      sid: this.widget.item!.sid,
      name: _nameCtrl.text.trim(),
      createdAt: this.widget.item!.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );

    _studentService
        .update(context,student)
        .then((updated) {
          if (updated) {
            showMessage(context, "Data Updated");
            _saved = true;
          }
        })
        .onError((e, s) {
          debugPrint(e.toString());
        });
  }
}
