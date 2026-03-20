
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
                height: 80,
               ),
              SizedBox(height: 20),
              Text("Admin Portal",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.only(right: 250),
                child: Column(
                  children: [
                    Text("Email",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                    ),
                    ),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder()
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }

}



