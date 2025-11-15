import 'package:flutter/material.dart';

class ForgetPasswordScreen extends StatelessWidget{
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar:  AppBar(

        title: const Center(
            widthFactor:2,
            child: Text("Forget Password",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),textAlign: TextAlign.center,))
        ,leading: const Icon(Icons.arrow_back_ios ,size: 20,),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
    );
  }


}