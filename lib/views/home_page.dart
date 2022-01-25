// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:quizme/views/fact_screen.dart';
import 'package:quizme/views/my_quizzes.dart';
import 'package:quizme/views/peers_screen.dart';
import 'package:quizme/views/quiz_creator.dart';
import 'package:quizme/views/quiz_picker.dart';
import 'package:quizme/views/explore_screen.dart';
import 'package:quizme/views/tutor_screen.dart';
import 'package:quizme/widgets/app_drawer.dart';
import 'package:quizme/views/quiz_creator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final views = [
    MyQuizzes(peerID: "", peerName: ""),
    ExploreScreen(),
    TutorScreen(),
    PeersScreen(),
    FactScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: views[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFFf85f6a),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            label: "My Quizzes",
            icon: Icon(Icons.help_center),
          ),
          BottomNavigationBarItem(
            label: "Explore",
            icon: Icon(Icons.explore),
          ),
          BottomNavigationBarItem(
            label: "Tutors",
            icon: Icon(Icons.school),
          ),
          BottomNavigationBarItem(
            label: "Peers",
            icon: Icon(Icons.people),
          ),
          BottomNavigationBarItem(
            label: "Facts",
            icon: Icon(Icons.lightbulb),
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
