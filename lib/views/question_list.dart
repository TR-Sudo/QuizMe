import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './initialize_quiz.dart';
import 'quiz_creator.dart';
import './quiz_game.dart';
import '../model/quiz.dart';

class QuestionList extends StatefulWidget {
  const QuestionList({Key? key, required this.quizID}) : super(key: key);

  final String quizID;

  @override
  _QuestionListState createState() => _QuestionListState(quizID: this.quizID);
}

class _QuestionListState extends State<QuestionList> {
  final String quizID;
  CollectionReference quizzesDB =
      FirebaseFirestore.instance.collection('quizzes');

  _QuestionListState({required this.quizID});

  @override
  void initState() {
    super.initState();
  }

  _deleteQuiz() async {
    await quizzesDB.doc(quizID).delete();
  }

  _goToQuizCreator(int index, Quiz quiz, {bool add = false}) {
    if (add) quiz.questions.add(Question("", 0, []));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => QuizCreator(
                questionNumber: index + 1,
                chosenQuiz: quiz,
                quizID: quizID,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: const Color(0xFFf85f6a),
            title: StreamBuilder(
                stream: quizzesDB.doc(quizID).snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return const Text("");
                  }
                  return Text(snapshot.data["Name"]);
                }),
            actions: <Widget>[
              StreamBuilder(
                  stream: quizzesDB.doc(quizID).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return IconButton(
                        onPressed: () {
                          areYouSure(context, quizName: snapshot.data["Name"]);
                        },
                        icon: const Icon(Icons.delete));
                  }),
              StreamBuilder(
                  stream: quizzesDB.doc(quizID).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => InitializeQuiz(
                                      quizID: quizID,
                                      quizName: snapshot.hasData
                                          ? snapshot.data["Name"]
                                          : "",
                                      prevTopic: snapshot.hasData
                                          ? snapshot.data["Category"]
                                          : "",
                                    )),
                          );
                        },
                        icon: const Icon(Icons.edit));
                  }),
            ]),
        body: StreamBuilder(
            stream: quizzesDB.doc(quizID).snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else {
                var quiz = snapshot.data;

                if (quiz == null) {
                  return const Center(child: Text("No questions made yet."));
                }

                int questionAmount = quiz["Questions"].length;

                Quiz quizObject = Quiz(
                    quiz['Name'],
                    quiz['Category'],
                    quiz['Questions']
                        .map<Question>((questionDoc) => Question(
                            questionDoc['Question'],
                            questionDoc['CorrectOptionIndex'],
                            questionDoc['Options'].cast<String>()))
                        .toList());

                return ListView.builder(
                    itemCount: questionAmount + 1,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          onTap: () {
                            if (index < questionAmount) {
                              _goToQuizCreator(index, quizObject);
                            }
                          },
                          child: index < questionAmount
                              ? Container(
                                  padding: const EdgeInsets.only(
                                      left: 5, right: 5, top: 1, bottom: 1),
                                  child: Card(
                                      elevation: 1,
                                      child: ListTile(
                                          title: Text(quiz["Questions"][index]
                                              ["Question"]),
                                          subtitle:
                                              Text("Question ${index + 1}"))))
                              : Container(
                                  padding: const EdgeInsets.all(5),
                                  child: ListTile(
                                      title: IconButton(
                                          onPressed: () {
                                            _goToQuizCreator(index, quizObject,
                                                add: true);
                                          },
                                          icon: const Icon(
                                              Icons.add_circle_outline,
                                              color: Color(0xFFf85f6a),
                                              size: 40)),
                                      subtitle: const Center(
                                          child: Text("New Question")))));
                    });
              }
            }),
        floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xFFf85f6a),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/quizgame',
                arguments: QuizScreenArguments(quizID),
              );
            },
            label: const Text("Start Quiz"),
            icon: const Icon(Icons.quiz)));
  }

  areYouSure(BuildContext context, {String quizName = ""}) {
    AlertDialog alert = AlertDialog(
      title: Text("Delete $quizName"),
      content: Text("Are you sure you want to delete $quizName?"),
      actions: [
        TextButton(
          child: const Text("NO"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text("YES"),
          onPressed: () async {
            await _deleteQuiz();
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
