import 'package:flutter/material.dart';


void main() =>  runApp (const MyApp());
class MyApp extends StatelessWidget{

const MyApp({Key? Key}): super(key: Key);
@override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(

      title: 'Material App',
      home: Scaffold(
        endDrawer:  Drawer(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.all(50),
                  child: Image.network("https://i.postimg.cc/KYDVQ9hP/usuario.png")
                ),
                const Text("User name",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
              Container(
                margin: const EdgeInsets.only(top: 30),
                padding: const EdgeInsets.all(20) ,
                width: double.infinity,
                color: Colors.green,
                child: const Text("Home"),
              ),
                Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.all(20) ,
                width: double.infinity,
                color: Colors.green,
                child: const Text("Setting"),
              ),
              Expanded(child:Container()),
                Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.all(20) ,
                width: double.infinity,
                color: Colors.green,
                alignment: Alignment.center,
                child: const Text("Sing out"),
              )
              ],
            ),
          ),
        ),
      appBar: AppBar(
        title: const Text('Drawer'),
      ),
      body: const Center(
        child: Text('Hello World 2'),
      ),


      ),
    );

}

  }