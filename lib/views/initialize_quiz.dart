import 'package:flutter/material.dart';
import 'package:quizme/utils/categories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './quiz_creator.dart';
import '../model/quiz.dart';

class InitializeQuiz extends StatefulWidget {
  const InitializeQuiz({
    Key? key,
    required this.quizID,
    required this.quizName,
    required this.prevTopic,
  }) : super(key: key);

  final String quizID;
  final String quizName;
  final String prevTopic;

  @override
  _InitializeQuizState createState() => _InitializeQuizState(
        quizID: this.quizID,
        quizName: this.quizName,
        prevTopic: this.prevTopic,
      );
}

class _InitializeQuizState extends State<InitializeQuiz> {
  final _formKey = GlobalKey<FormState>();
  final String quizID;
  final String quizName;
  final String prevTopic;

  CollectionReference quizzesDB =
      FirebaseFirestore.instance.collection('quizzes');

  final List<String> _items = CATEGORIES;
  String topic = CATEGORIES[0];

  _InitializeQuizState({
    required this.quizID,
    required this.quizName,
    required this.prevTopic,
  });

  TextEditingController quizNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    quizNameController.text = quizName;
    if (prevTopic != "") topic = prevTopic;
  }

  renameQuiz() async {
    await quizzesDB
        .doc(quizID)
        .update({'Name': quizNameController.text, 'Category': topic});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFf85f6a),
          title: quizID == "none"
              ? const Text("Create Quiz")
              : const Text("Rename Quiz")),
        resizeToAvoidBottomInset: false,
        body: Center(
            child: SafeArea(
                child: Container(
                    width: 350,
                    height: 300,
                    child: Form(
                        key: _formKey,
                        child: Card(
                          elevation: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                  width: 300,
                                  child: TextFormField(
                                      decoration: const InputDecoration(
                                          labelText: "Quiz Name",
                                          icon: Icon(Icons.help)),
                                      controller: quizNameController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Give your quiz a name.";
                                        }
                                        return null;
                                      })),
                              Container(
                                  width: 300,
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                        labelText: 'Topic',
                                        icon: Icon(Icons.school)),
                                    isExpanded: true,
                                    value: topic,
                                    items: _items.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? value) {
                                      setState(() {
                                        topic = value!;
                                      });
                                    },
                                  )),
                              ElevatedButton(
                                  style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => const Color(0xFFf85f6a))),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      quizID == "none"
                                          ? Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      QuizCreator(
                                                        questionNumber: 1,
                                                        chosenQuiz: Quiz(
                                                            quizNameController
                                                                .text,
                                                            topic,
                                                            []),
                                                        quizID: "none",
                                                      )),
                                            )
                                          : renameQuiz();
                                    }
                                  },
                                  child: quizID == "none"
                                      ? const Text("Continue")
                                      : const Text("Rename"))
                            ],
                          ),
                        ))))));
  }
}
