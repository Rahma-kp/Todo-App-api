import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:todo/view/homescreen.dart';
import 'package:http/http.dart' as http;

class TodoAdding extends StatefulWidget {
  final Map? todo;
  TodoAdding({super.key, this.todo});
  @override
  State<TodoAdding> createState() => _TodoAddingState();
}

class _TodoAddingState extends State<TodoAdding> {
  TextEditingController titilecontroller = TextEditingController();
  TextEditingController descriptiocontroller = TextEditingController();
  bool isEdit = false;
  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (widget.todo != null) {
      isEdit = true;
      final title = todo!['title'];
      final dec = todo['description'];
      titilecontroller.text = title;
      descriptiocontroller.text = dec;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(isEdit ? "Edit Todo" : "Todo Add",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Card(
          color: Colors.black26,
          child: SizedBox(
            height: 350,
            width: 350,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 40, left: 40),
                  child: TextFormField(
                    controller: titilecontroller,
                    decoration: const InputDecoration(
                      hintText: "Todo Titile",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40, right: 40),
                  child: TextFormField(
                    controller: descriptiocontroller,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Content",
                      prefixStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ));
                    setState(() {
                      submitData();
                    });
                  },
                  child: Container(
                    height: 35,
                    width: 65,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        isEdit ? "Update" : "Add",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> submitData() async {
    final title = titilecontroller.text;
    final dec = descriptiocontroller.text;
    final body = {"title": title, "description": dec, "is_completed": false};
// submit data to server
    final url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 201) {
      titilecontroller.text = '';
      descriptiocontroller.text = '';
      showSuccessMessage("Success");
    } else {
      showErrorMessage("Failed");
    }
  }

  //------------------------ udating data -------------------------------------------------------

  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print("you can not update data");
      return;
    }
    final id = todo["_id"];
    final title = titilecontroller.text;
    final dec = descriptiocontroller.text;
    final body = {"title": title, "description": dec, "is_completed": false};
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.post(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 201) {
      titilecontroller.text = '';
      descriptiocontroller.text = '';
      showUpdationMessage("UPdation success");
    } else {
      showErrorMessage("Failed");
    }
  }
// ======================================

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
        content: Text(
      message,
      style: TextStyle(color: Colors.white),
    ),backgroundColor:Color.fromARGB(255, 81, 254, 147),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  // ======================================================

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // =================================================
  void showUpdationMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
