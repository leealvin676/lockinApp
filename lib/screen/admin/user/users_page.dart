import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  List<Map<String, dynamic>> users = [
    {'name': 'Alex'},
    {'name': 'Ben'},
    {'name': 'Chris'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Padding(
        padding: EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              'Users',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {

                  final user = users[index];

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF444444),
                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: Row(
                      children: [

                        Icon(Icons.person, color: Colors.red),

                        SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            user['name'],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),


                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.white),
                          onPressed: () => _editUser(index),
                        ),

                        // 🗑 Delete
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUser(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _addUser,
        child: Icon(Icons.add),
      ),
    );
  }


  void _addUser() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add User'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  users.add({'name': controller.text});
                });
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }


  void _editUser(int index) {
    TextEditingController controller =
    TextEditingController(text: users[index]['name']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: TextField(
            controller: controller,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  users[index]['name'] = controller.text;
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }


  void _deleteUser(int index) {
    setState(() {
      users.removeAt(index);
    });
  }
}