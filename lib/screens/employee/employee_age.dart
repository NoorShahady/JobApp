import 'package:flutter/material.dart';

class My_app extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('age'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          'What is your age',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
    );
  }
}

class ExampleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Button Example'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: ElevatedButton(onPressed: (){},

          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.deepPurple,
          ),
          child: Text(
            'Go to New Screen',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ExampleButton(),
  ));
}
