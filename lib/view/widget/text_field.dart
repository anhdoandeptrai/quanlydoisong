import 'package:flutter/material.dart';

class TextFieldInpute extends StatelessWidget{
  const TextFieldInpute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Padding
    (
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Email",
          hintStyle: const TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
          border:InputBorder.none,
          filled: true,
          fillColor: Color(0xFFedf0f8),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            borderSide: BorderSide(color: Color(0xFFedf0f8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            borderSide:const BorderSide(width: 2, color: Colors.blue),
          ),
        ),
      ),
    );
  }
}