import 'package:first_version/SharedPreferencesManager.dart';
import 'package:flutter/material.dart';
import 'package:first_version/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Employee_details(),
    );
  }
}

class Employee_details extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About You"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: () async {
                   dynamic gender =SharedPreferencesManager.init();
                   SharedPreferencesManager.setValue('gender', 0);// 0 is male , 1 is female

                   Navigator.push(
                       context, MaterialPageRoute(builder: (context) => age()));
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    backgroundColor: Colors.blue,
                    elevation: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.male, color: Colors.white, size: 25),
                    SizedBox(height: 5),
                    Text(
                      "Male",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(width: 20),
            SizedBox(
              width: 140,
              child: ElevatedButton(onPressed: () async {
                dynamic gender =SharedPreferencesManager.init();
                SharedPreferencesManager.setValue('gender', 1); // 0 is male , 1 is female
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => age()));
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  backgroundColor: Colors.pink,
                  elevation: 5,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.female, color: Colors.white, size: 25),
                    SizedBox(height: 5),
                    Text(
                      "Female",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    )
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

class age extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('age'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child:Column(
          children: [
            ElevatedButton(
              onPressed: () {
                print(SharedPreferencesManager.getValue('gender'));
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Check Gender'), // Single child for the button
            ),
          ],
        ),
     ),
    );
  }
}
