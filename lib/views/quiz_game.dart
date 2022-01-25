import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/quiz.dart';

class QuizScreenArguments {
  final String quizID;

  QuizScreenArguments(this.quizID);
}

class QuizScreen extends StatelessWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as QuizScreenArguments;

    return QuizGame(args.quizID);
  }
}

class AnswerEntry {
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final bool wasCorrect;

  AnswerEntry(
      this.question, this.userAnswer, this.correctAnswer, this.wasCorrect);
}

class QuizGame extends StatefulWidget {
  final String quizID;

  const QuizGame(this.quizID, {Key? key}) : super(key: key);

  @override
  _QuizGameState createState() => _QuizGameState();
}

class _QuizGameState extends State<QuizGame> {
  final quizzes = FirebaseFirestore.instance.collection("quizzes");
  late Quiz currentQuiz;
  bool loadedQuiz = false;
  int currentQuestionIndex = 0;
  int numCorrect = 0;
  bool currentQuestionDone = false;
  bool wasCorrect = false;

  List<AnswerEntry> answers = [];

  @override
  void initState() {
    super.initState();
  }

  void initQuiz() async {
    var quizDoc = await quizzes.doc(widget.quizID).get();

    String quizName = quizDoc['Name'];
    String quizCategory = quizDoc['Category'];
    // String quizUser = quizDoc['User'];
    List<Question> quizQuestions = quizDoc['Questions']
        .map<Question>((questionDoc) => Question(
            questionDoc['Question'],
            questionDoc['CorrectOptionIndex'],
            questionDoc['Options'].cast<String>()))
        .toList();

    setState(() {
      currentQuiz = Quiz(quizName, quizCategory, quizQuestions);
      loadedQuiz = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!loadedQuiz) {
      initQuiz();
      return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFf85f6a),
            title: const Text("QuizMe"),
            automaticallyImplyLeading: false,
          ),
          body: const Center(child: CircularProgressIndicator()));
    } else {
      return Scaffold(
          appBar: AppBar(
              backgroundColor: const Color(0xFFf85f6a),
              title: const Text("QuizMe"),
              automaticallyImplyLeading: false,
              actions: <Widget>[
                TextButton.icon(
                    label: const Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    icon: Text('Done', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ]),
          body: Container(padding: EdgeInsets.all(18.0), child: getQuizBody()));
    }
  }

  Widget getQuizBody() {
    if (currentQuestionIndex >= currentQuiz.questions.length) {
      return Center(child: getResultsBody());
    } else {
      Question currentQuestion = currentQuiz.questions[currentQuestionIndex];
      List<String> options = currentQuestion.options;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              SizedBox(height: 64.0),
              Text(
                  "Question ${currentQuestionIndex + 1}/${currentQuiz.questions.length}",
                  style: TextStyle(fontSize: 16.0, color: Colors.grey[700])),
              Text(currentQuestion.question,
                  style: const TextStyle(
                      fontSize: 36.0, fontWeight: FontWeight.bold)),
              SizedBox(height: 12.0),
              Container(height: 20.0, child: getResultText())
            ],
          ),
          SizedBox(height: 24.0),
          Flexible(
              child: Container(
            child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      getOptionButton(
                          options[index],
                          currentQuestionDone
                              ? ((index == currentQuestion.correctOptionIndex)
                                  ? Colors.greenAccent[700]
                                  : Colors.red[200])
                              : Colors.white, () {
                        if (!currentQuestionDone) {
                          if (index == currentQuestion.correctOptionIndex) {
                            setState(() {
                              numCorrect++;
                              currentQuestionDone = true;
                              wasCorrect = true;
                            });

                            answers.add(AnswerEntry(
                                currentQuestion.question,
                                currentQuestion.options[index],
                                currentQuestion.options[
                                    currentQuestion.correctOptionIndex],
                                wasCorrect));
                          } else {
                            setState(() {
                              currentQuestionDone = true;
                              wasCorrect = false;
                            });

                            answers.add(AnswerEntry(
                                currentQuestion.question,
                                currentQuestion.options[index],
                                currentQuestion.options[
                                    currentQuestion.correctOptionIndex],
                                wasCorrect));
                          }
                        }
                      }),
                      const SizedBox(
                        height: 16.0,
                      )
                    ],
                  );
                }),
          )),
          currentQuestionDone
              ? ElevatedButton(
                  style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.resolveWith(
                          (states) => Colors.grey[900]),
                      backgroundColor: MaterialStateProperty.resolveWith(
                          (states) => Colors.white)),
                  onPressed: () {
                    setState(() {
                      currentQuestionDone = false;
                      currentQuestionIndex++;
                    });
                  },
                  child: Container(
                      width: 160.0,
                      padding: EdgeInsets.all(4.0),
                      // decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     border: Border.all(color: Colors.grey, width: 0.0),
                      //     borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentQuestionIndex ==
                                    (currentQuiz.questions.length - 1)
                                ? "See Results"
                                : "Next Question",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: 12.0),
                          Icon(Icons.arrow_forward)
                        ],
                      )))
              : SizedBox.shrink()
        ],
      );
    }
  }

  Widget getOptionButton(String question, Color? color, Function onTapHandler) {
    return GestureDetector(
        onTap: () {
          onTapHandler();
        },
        child: AnimatedContainer(
            margin: EdgeInsets.all(2.0),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
                color: color,
                // border: Border.all(color: Colors.grey, width: 0.0),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 0.0),
                      blurRadius: 1.0)
                ],
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            duration: Duration(milliseconds: currentQuestionDone ? 200 : 0),
            child:
                Text(question, style: TextStyle(fontWeight: FontWeight.w700))));
  }

  Widget getResultText() {
    if (currentQuestionDone) {
      if (wasCorrect) {
        return Text("Correct! 🥳",
            style: TextStyle(
                color: Colors.green[700],
                fontSize: 18.0,
                fontWeight: FontWeight.bold));
      } else {
        return Text("Incorrect! 🙁",
            style: TextStyle(
                color: Colors.red[800],
                fontSize: 18.0,
                fontWeight: FontWeight.bold));
      }
    } else {
      return const Text("",
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold));
    }
  }

  Widget getResultsBody() {
    return ListView(children: [
      SizedBox(height: 8.0),
      Center(
          child: Text("Results",
              style: const TextStyle(
                  fontSize: 40.0, fontWeight: FontWeight.bold))),
      SizedBox(height: 16.0),
      Center(child: getScoreBox()),
      SizedBox(height: 24.0),
      Text("Your Answers",
          style: const TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold)),
      SizedBox(height: 8.0),
      ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: answers.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                getAnswerEntryWidget(answers[index]),
                SizedBox(height: 8.0)
              ],
            );
          }),
    ]);
  }

  Widget getAnswerEntryWidget(AnswerEntry answerEntry) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade400,
                offset: Offset(0.0, 0.0),
                blurRadius: 0.5)
          ],
          borderRadius: BorderRadius.all(Radius.circular(4.0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(child: getAnswerEntryHeader(answerEntry.wasCorrect)),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Question",
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400)),
                Text(answerEntry.question,
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600)),
                SizedBox(height: 5.0),
                Text("Your Answer",
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400)),
                Text(answerEntry.userAnswer,
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600)),
                SizedBox(height: 5.0),
                Text("Correct Answer",
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400)),
                Text(answerEntry.correctAnswer,
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getAnswerEntryHeader(bool wasCorrect) {
    return Container(
        padding: EdgeInsets.only(left: 4.0, right: 4.0),
        decoration: BoxDecoration(
            color: wasCorrect ? Colors.greenAccent[700] : Colors.redAccent[700],
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.0), topRight: Radius.circular(4.0))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              wasCorrect ? Icons.check : Icons.close,
              size: 20.0,
              color: Colors.white,
            ),
            SizedBox(width: 6.0),
            Text(
              wasCorrect ? "Correct" : "Incorrect",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            )
          ],
        ));
  }

  Widget getScoreBox() {
    int percentScore =
        min((numCorrect / currentQuiz.questions.length * 100).round(), 100);
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey, offset: Offset(0.0, 0.0), blurRadius: 1.0)
          ],
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: Column(
        children: [
          const Text("Score",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600)),
          Text("$percentScore%",
              style:
                  const TextStyle(fontSize: 56.0, fontWeight: FontWeight.w600)),
          Text("$numCorrect/${currentQuiz.questions.length}",
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// NOTE: for intro quiz screen, show stats maybe? like top scores etc.
// return Scaffold(
//     appBar: AppBar(
//       title: Text("QuizMe"),
//     ),
//     body: Container(
//       padding: EdgeInsets.all(18.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         // mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Text(currentQuiz.name,
//               style: const TextStyle(
//                   fontSize: 36.0, fontWeight: FontWeight.bold)),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Expanded(
//                   child: Text(currentQuiz.user,
//                       style: TextStyle(
//                           color: Colors.grey[700], fontSize: 16.0))),
//               Text("${currentQuiz.questions.length} questions",
//                   style:
//                       TextStyle(color: Colors.grey[700], fontSize: 16.0))
//             ],
//           )
//         ],
//       ),
//     ));
