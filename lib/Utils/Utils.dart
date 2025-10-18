import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showTextDialog(BuildContext context, String titleOfAlert, String bodyOfAlert) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Center(child: Text(titleOfAlert, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green,))),
              SizedBox(height: 10,),
              Text(bodyOfAlert, textDirection: TextDirection.rtl, style: TextStyle(color: Colors.black),),
              SizedBox(height: 10,),
            ],
          ),
        ),


        actions: <Widget>[
          Center(
            child:
            Container(
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green,
                ),
                borderRadius: BorderRadius.circular(14),
                color: Colors.green,
              ),
              child:
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(120, 45),
                  elevation: 2,
                ),
                child: Text(
                  "אישור",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),


          ),
          // )
        ],


      );
    },
  );
}
