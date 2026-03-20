
import 'dart:ffi';
import 'admin_dashboard.dart';
import 'package:flutter/material.dart';


class AdminLogin extends StatelessWidget{
  const AdminLogin({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          height: 600,
          width:350,
          decoration: BoxDecoration(
            color: Color(0xFF333333),
            borderRadius: BorderRadius.circular(20)
          ),
          child: Column(
            children: [
              Image.asset('assets/icons/login_icon.png',
                height: 90,
                fit: BoxFit.contain,
               ),
              SizedBox(height: 20),
              Text("Admin Portal",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text("Sign in to access admin dashboard"),
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Admin Email",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                    TextField(
                      style: TextStyle(
                        color: Colors.white
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email)
                      ),
                    ),
                    SizedBox(height: 20),
                    Text("Password",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      style: TextStyle(
                          color: Colors.white
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock)
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminDashBoard()),
                    );
                  },
                child: Text("Admin Sign In",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold
                ),),
              )
            ],
          ),
        ),
      )
    );
  }

}



