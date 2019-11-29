import 'package:flutter/material.dart';
//import 'ui/temp.dart';
//import 'ui/drawing_holder.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'ui/drawing_holder.dart';

class FlutterDrawing extends StatelessWidget {
  FlutterDrawing({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
    appBar: AppBar(
      title: Text(title),
    ),
    body: Center(child: MyDrawing(title: "Test", width: width, height: height,)),
     // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}