import 'package:first_version/SharedPreferencesManager.dart';
import 'package:first_version/main.dart';
import 'package:first_version/screens/busniess/busniess_details.dart';
import 'package:first_version/screens/employee/employee_details.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EmplyeeBusniess(),
    );
  }
}

class EmplyeeBusniess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose"),
        backgroundColor: Colors.deepPurple,
      ),
      bottomNavigationBar: NavigationBar(destinations: [NavigationDestination(icon:Icon(Icons.search),
          label:'type'),NavigationDestination(icon: Icon(Icons.person),
          label: '')
      ]),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 140,child:

            ElevatedButton( // Employee Button
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Employee_details()),
                );
                SharedPreferencesManager.setValue("type", "employee");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                elevation: 20, // Shadow effect
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 30, color: Colors.white),
                  SizedBox(height: 5),
                  Text(
                    "Employee",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            ),
            SizedBox(width: 20),
            SizedBox(width: 140,child:
            // Business Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Busniess_details()),
                );
                SharedPreferencesManager.setValue("type", "busniess");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                elevation: 5,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.business, size: 30, color: Colors.white),
                  SizedBox(height: 5),
                  Text(
                    "Business",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
