import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:todo/view/todoaddingscreen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List items = [];
  @override
  void initState() {
    fetchTodo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: const Color.fromARGB(137, 109, 108, 108),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "TODO",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => TodoAdding(),
          ));
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchTodo,
        child: Center(
            child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (ctx, index) {
            final item = items[index] as Map;
            final id = item['_id'] as String;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: ListTile(
                  onTap: () {},
                  leading: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )),
                  title: Text(
                    item['title'],
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    item['description'],
                    style: const TextStyle(fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          navigationEdit(item);
                        },
                        icon: const Icon(Icons.edit,
                            color: Color.fromARGB(255, 81, 142, 83)),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            deleteTodo(id);
                          });
                        },
                        icon: const Icon(Icons.delete,
                            color: Color.fromARGB(255, 175, 62, 54)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        )),
      ),
    ));
  }

  Future<void> deleteTodo(String id) async {
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      showDeletMessage("Deletion Faild");
    }
  }

  Future<void> fetchTodo() async {
    final url = 'https://api.nstack.in/v1/todos?page=1&limit=20';
    final uri = Uri.parse(url);
    final respones = await http.get(uri);
    if (respones.statusCode == 200) {
      final json = jsonDecode(respones.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }
  }
// ----------------------------
void navigationEdit( Map item){
  final route=MaterialPageRoute(builder: (context) => TodoAdding(todo: item,),);
  Navigator.push(context, route);
}
// ----------------------------------------
  void showDeletMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
