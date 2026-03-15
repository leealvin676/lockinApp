import "package:flutter/material.dart";


class AdminDashBoard extends StatelessWidget{

  const AdminDashBoard({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
     appBar: _buildAppBar(),
      backgroundColor: Colors.black,
    );
  }

}

AppBar _buildAppBar(){
  return AppBar(
    backgroundColor: Colors.grey,
      title: const Text.rich(
        TextSpan(
            children: [
              TextSpan(
                text : 'LockIn',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
              ),
              TextSpan(
                  text : 'Admin',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold
                  )
              )
            ]
        ),
      ),
      actions: [
        IconButton(
            onPressed: () {},
            icon: Icon(Icons.logout,color: Colors.red)
        ),
    ],
  );
}