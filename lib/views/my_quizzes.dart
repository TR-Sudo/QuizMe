// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:quizme/utils/auth.dart';
import 'package:quizme/views/initialize_quiz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizme/views/question_list.dart';
import 'package:quizme/widgets/app_drawer.dart';
import 'package:quizme/views/quiz_game.dart';
import '../model/quiz.dart';
import '../model/db_user.dart';

class MyQuizzes extends StatefulWidget {
  const MyQuizzes({Key? key, required this.peerID, required this.peerName})
      : super(key: key);

  final String peerID;
  final String peerName;

  @override
  _MyQuizzesState createState() =>
      _MyQuizzesState(peerID: this.peerID, peerName: this.peerName);
}

// Will list your quizzes that you made
class _MyQuizzesState extends State<MyQuizzes> {
  final String peerID;
  final String peerName;

  _MyQuizzesState({required this.peerID, required this.peerName});

  bool loadedQuizzes = false;

  var quizzesDB;

  @override
  void initState() {
    super.initState();
    setQuizzesDB();
  }

  void setQuizzesDB() async {
    DBUser? user = await getAuthedUser();
    if (user != null) {
      if (peerName == "") {
        setState(() {
          quizzesDB = FirebaseFirestore.instance
              .collection('quizzes')
              .where("User", isEqualTo: user.username);
        });
      } else {
        setState(() {
          quizzesDB = FirebaseFirestore.instance
              .collection('quizzes')
              .where("User", isEqualTo: peerName)
              .where("isComplete", isEqualTo: true);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: peerName == ""
              ? const Text("My Quizzes")
              : Text("${peerName}'s Quizzes"),
          backgroundColor: Color(0xFFf85f6a),
        ),
        drawer: peerID == "" ? const AppDrawer() : null,
        body: getMyQuizzesBody(),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InitializeQuiz(
                        quizID: "none", quizName: "", prevTopic: "")),
              );
            },
            backgroundColor: Color(0xFFf85f6a),
            child: const Icon(Icons.add)));
  }

  Widget getMyQuizzesBody() {
    if (quizzesDB == null) return Center(child: CircularProgressIndicator());

    return StreamBuilder(
        stream: quizzesDB.snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            var docs = snapshot.data.docs;

            if (docs.isEmpty) {
              return Center(child: Text("No quizzes made yet."));
            }

            return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var chosenQuizSnapshot = docs[index];
                  var quizData = chosenQuizSnapshot.data();

                  // Hide unfinished

                  return GestureDetector(
                      onTap: () async {
                        if (peerID == "") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QuestionList(
                                    quizID: chosenQuizSnapshot.id)),
                          );
                        } else {
                          Navigator.pushNamed(context, '/quizgame',
                              arguments:
                                  QuizScreenArguments(chosenQuizSnapshot.id));
                        }
                      },
                      child: Container(
                          padding: const EdgeInsets.only(
                              left: 5, right: 5, top: 1, bottom: 1),
                          child: Card(
                              elevation: 1,
                              child: ListTile(
                                  title: Text(quizData['Name']),
                                  subtitle: Text(quizData['Category']),
                                  trailing: peerID == ""
                                      ? quizData['isComplete']
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Icon(
                                                  Icons.check_circle_outline,
                                                  color: Colors.green,
                                                ),
                                                Text("Live",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey)),
                                                SizedBox(width: 90)
                                              ],
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Icon(Icons.handyman),
                                                Text("Work in progress",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey))
                                              ],
                                            )
                                      : Icon(Icons.arrow_forward)))));
                });
          }
        });
  }
}
