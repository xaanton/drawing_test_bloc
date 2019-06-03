import 'package:flutter/material.dart';
import 'ui/temp.dart';
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
      body: DrawingHolder(title: "Test", width: width, height: height,),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}