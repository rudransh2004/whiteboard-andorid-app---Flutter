import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:animated_floatactionbuttons/animated_floatactionbuttons.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
void main() {


    runApp(new MaterialApp(
      debugShowCheckedModeBanner: false,
      home:drawing(),
    ),
    );
  }

class drawing extends StatefulWidget {
  @override
  _drawingState createState() => _drawingState();
}
class _drawingState extends State<drawing> {
  GlobalKey globalKey = GlobalKey();
  List<DrawingPoints> points = List();
  double opacity = 1.0;
  StrokeCap strokeType = StrokeCap.round;
  double strokeWidth = 3.0;
  ui.Color selectedColor = Colors.black;
  SelectedMode selectedMode = SelectedMode.Storkewidth;

  File _imageFile;
  File _image;
  var sliderValue = 0;


Future<void> _change_in_stroke_width (context) async{
  return Alert(
    context:  context,
    title:  " Adjust stroke width",
    content: Column(
      children: [
        IconButton(
          icon: Icon(Icons.brush),
          iconSize: 6.0,
          color: Colors.deepOrange,
          onPressed: (){
            strokeWidth = 6.0;
          },
        ),
        IconButton(
          icon: Icon(Icons.brush),
          iconSize: 9.0,
          color: Colors.deepOrange,
          onPressed: (){
            strokeWidth= 9.0;
          },
        ),
        IconButton(
          icon: Icon(Icons.brush),
          iconSize: 12.0,
          color: Colors.deepOrange,
          onPressed: (){
            strokeWidth  = 12.0;
          },
        )
      ],
    ),
  ).show();
}
  Random rng = new Random();
  List <Widget> fabOption(){
    return <Widget>[
      FloatingActionButton(
      backgroundColor: Colors.red,
        heroTag: "color_red",
      onPressed: (){
        setState(() {
    selectedColor = Colors.red;
        });

    },
    ),
      FloatingActionButton(
        backgroundColor: Colors.black,
        heroTag: "color_black",
        onPressed: (){
          setState(() {
            selectedColor = Colors.black;
          });
        },
      ),
      FloatingActionButton(
        backgroundColor: Colors.green,
        heroTag: "color_green",
        onPressed: () {
          setState((){
            selectedColor = Colors.green;
          });
        },
      ),
      FloatingActionButton(
        backgroundColor: Colors.blue,
        heroTag: "color_blue",
        onPressed: (){
          setState(() {
            selectedColor = Colors.blue;
          });
        },
      ),
  ];
  }

  Future<void> _captureScreenshot(globalKey) async {
    try {
      RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage();
      final directory = (await getApplicationDocumentsDirectory()).path;
      ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      print(pngBytes);
      File imgFile = new File('$directory/${rng.nextInt(200)}.png');
      setState(()
      {
        _imageFile = imgFile;
      }
      );
      _savefile(
          _imageFile
      ); ;
      imgFile.writeAsBytes(pngBytes);
    } catch(e)
    {
      print(e);
    }
  }

  _savefile(File file) async {
    await _askPermission();
    final result = await ImageGallerySaver.saveImage(Uint8List.fromList(await file.readAsBytes()));
    print(result);
  }
  _askPermission() async {
    Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions(
        [
          PermissionGroup.photos
        ]
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: AnimatedFloatingActionButton(
        fabButtons: fabOption(),
        colorStartAnimation: Colors.greenAccent,
        colorEndAnimation: Colors.greenAccent,
        animatedIconData: AnimatedIcons.menu_close,
      ),



      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      bottomNavigationBar:Container(
       child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        fixedColor: Colors.white,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.blue,

        iconSize: 25,

          items: [
      BottomNavigationBarItem(
      icon: IconButton(
      icon: Icon(Icons.opacity),
      color: Colors.black,

      onPressed: () {
         _change_in_opacity();
      },),
        title: Text('Opacity')
      ),
       BottomNavigationBarItem(
         icon: IconButton(
         icon: Icon(Icons.album),
         color: Colors.black,
         onPressed: () {
           _change_in_stroke_width(context);
           },),
           title: Text('Stroke-width')
            ),
       BottomNavigationBarItem(
         icon: IconButton(
         icon: Icon(Icons.save),
         color: Colors.black,
           onPressed: (){
           _captureScreenshot(globalKey);
           },

         ),
           title: Text('Save')
    ),
            BottomNavigationBarItem(
              icon: IconButton(
                icon : Icon(Icons.delete_forever),
                color: Colors.black,
                onPressed: (){

                },
              ),
          title: Text('Delete')
                 )
    ],
      ),
      ),


      body: GestureDetector(
        onPanUpdate: (details){
          setState((){
            RenderBox renderBox = context.findRenderObject();
            points.add(DrawingPoints(
              points: renderBox.globalToLocal(details.globalPosition),
              paint: Paint()
                ..strokeCap = strokeType
                ..isAntiAlias = true
                ..color = selectedColor.withOpacity(opacity)
                ..strokeWidth = strokeWidth));
          });
        },
        onPanStart: (details){
          setState(() {
            RenderBox renderBox = context.findRenderObject();
            points.add(DrawingPoints(
                points: renderBox.globalToLocal(details.globalPosition),
                paint: Paint()
                  ..strokeCap = strokeType
                  ..isAntiAlias = true
                  ..color = selectedColor.withOpacity(opacity)
                  ..strokeWidth = strokeWidth));

          });
          },


        onPanEnd: (details) {
          setState(() {
            points.add(null);
          });
        },

        child: RepaintBoundary(
          key: globalKey,
          child: CustomPaint(
            size: Size.infinite,
            painter: MyPainter(
              pointsList:points,
            ),

          ),

        ),

      ),
    );

  }
}
class MyPainter extends CustomPainter {
  MyPainter({this.pointsList});

  //Keep track of the points tapped on the screen
  List<DrawingPoints> pointsList;
  List<Offset> offsetPoints = List();

  //This is where we can draw on canvas.
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        //Drawing line when two consecutive points are available
        canvas.drawLine(pointsList[i].points, pointsList[i + 1].points,
            pointsList[i].paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].points);
        offsetPoints.add(Offset(
            pointsList[i].points.dx + 0.1, pointsList[i].points.dy + 0.1));

        //Draw points when two points are not next to each other
        canvas.drawPoints(
            ui.PointMode.points, offsetPoints, pointsList[i].paint);
      }
    }
  }

  //Called when CustomPainter is rebuilt.
  //Returning true because we want canvas to be rebuilt to reflect new changes.
  @override
  bool shouldRepaint(MyPainter oldDelegate) => true;
}
class DrawingPoints {
  Paint paint;
  Offset points;
  DrawingPoints({this.points, this.paint});
}

enum SelectedMode {Colors,Opacity,Storkewidth}