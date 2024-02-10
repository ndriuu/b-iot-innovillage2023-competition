import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeApp extends StatefulWidget{
  HomeApp({super.key});
  @override
  State<HomeApp> createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp>{
  bool gasValve = true;
  var cowGas,dirtHeight;
  final dataBase = FirebaseDatabase.instance.ref();
  _HomeAppState(){
    dataBase.child('b-iot/').once().then((snap) {
      gasValve = snap.snapshot.child('controller').child("gasValve").value == 1;
      cowGas = snap.snapshot.child('monitoring').child("cowGas").value;
      dirtHeight = snap.snapshot.child('monitoring').child("dirtHeight").value;
      print(gasValve);
    }).then((value) {
      setState(() {});
    });
    dataBase.child('b-iot/monitoring/').onChildChanged.listen((event) {
      DataSnapshot snap = event.snapshot;
      if (snap.key == 'cowGas') {
        cowGas = snap.value;
        print(cowGas);
        setState(() {});
      }
      if (snap.key == 'dirtHeight') {
        dirtHeight = snap.value;
        print(dirtHeight);
        setState(() {});
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade800,
              Colors.blue.shade400
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 50,),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInUp(duration: Duration(milliseconds: 1000),
                      child: Text("B-IoT", style: TextStyle(color: Colors.white, fontSize: 40),)),
                  SizedBox(height: 10,),
                  FadeInUp(duration: Duration(milliseconds: 1000),
                      child:Text("Transform your environment into energy", style: TextStyle(color: Colors.white,fontSize: 18),)),
                ],
              ),
            ),
            SizedBox(height: 20,),
            Expanded(
                child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: <Widget>[
                      //List Sensor Data
                      FadeInUp(duration: Duration(milliseconds: 1400),child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(
                                color: Color.fromRGBO(65, 125, 255, .3),
                                blurRadius: 20,
                                offset: Offset(0, 10)
                            )]
                        ),
                        child: Row( children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: EdgeInsets.all(7),
                              color: Colors.blue,
                              child: Icon(
                                Icons.local_fire_department_rounded,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status : $cowGas',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'The Information of Gas',
                                // 'Tingkat Tekanan: 0%pa',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                        ),
                      )),
                      SizedBox(
                        height: 10,
                      ),
                      FadeInUp(duration: Duration(milliseconds: 1400),child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(
                                color: Color.fromRGBO(65, 125, 255, .3),
                                blurRadius: 20,
                                offset: Offset(0, 10)
                            )]
                        ),
                        child: Row( children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: EdgeInsets.all(7),
                              color: Colors.blue,
                              child: Icon(
                                Icons.gas_meter_rounded,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status : $dirtHeight',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'The Information of Dirt Height',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                        ),
                      )),

                      SizedBox(height: 30,),

                      FadeInUp(duration: Duration(milliseconds: 1400),child:Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(
                                color: Color.fromRGBO(65, 125, 255, .3),
                                blurRadius: 20,
                                offset: Offset(0, 10)
                            )]
                        ),
                        height: 200,
                        width: 200,
                        child : LiquidCircularProgressIndicator(
                          value: dirtHeight, // Defaults to 0.5.
                          valueColor: AlwaysStoppedAnimation(Colors.blue.shade400), // Defaults to the current Theme's accentColor.
                          backgroundColor: Colors.white, // Defaults to the current Theme's backgroundColor.
                          borderColor: Colors.blue,
                          borderWidth: 5.0,
                          direction: Axis.vertical, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                          center: Text("$dirtHeight%", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade900),),
                        ),
                      )),
                      SizedBox(height: 50,),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: FadeInUp(duration: Duration(milliseconds: 1900), child: MaterialButton(
                              onPressed: () {
                                gasValve = !gasValve;
                                final child = dataBase.child('b-iot/controller/');
                                int boolString = gasValve? 1 : 0;
                                child.update({'gasValve':boolString});
                                setState(() {});
                              },
                              child: Text(gasValve ? "Gas: ON" : "Gas: OFF", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                              height: 50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              color: Colors.blue,
                            )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}