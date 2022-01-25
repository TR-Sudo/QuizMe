import 'package:flutter/material.dart';
import '../model/quiz.dart';

class QuestionCreator extends StatefulWidget {
  const QuestionCreator(
      {Key? key, required this.question, required this.appendQuestionCB})
      : super(key: key);

  final Question question;
  final Function appendQuestionCB;

  @override
  QuestionCreatorState createState() => QuestionCreatorState(
      question: this.question, appendQuestionCB: this.appendQuestionCB);
}

class QuestionCreatorState extends State<QuestionCreator> {
  Question question;
  final Function appendQuestionCB;

  QuestionCreatorState(
      {required this.question, required this.appendQuestionCB});

  int correctOptionIndex = 0;
  TextEditingController questionController = TextEditingController();
  bool deleteMode = false;

  List<TextEditingController> _editOptions = [];

  switchDeleteMode(bool sync) {
    setState(() {
      deleteMode = sync ? false : !deleteMode;
    });
  }

  saveQuestion() {
    List<String> options = [];

    for (TextEditingController editOption in _editOptions) {
      options = [...options, editOption.text];
    }

    appendQuestionCB(
        Question(questionController.text, correctOptionIndex, options));
  }

  @override
  void initState() {
    super.initState();

    int optionsAmount =
        question.options.isNotEmpty ? question.options.length : 2;

    questionController.text = question.question;
    _editOptions = List.generate(optionsAmount, (i) => TextEditingController());

    if (question.options.isNotEmpty) {
      correctOptionIndex = question.correctOptionIndex;
      for (int i = 0; i < _editOptions.length; i++) {
        _editOptions[i].text = question.options[i];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.only(
            top: 20.0,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).size.height / 3),
        itemCount: _editOptions.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return TextFormField(
                decoration: const InputDecoration(
                    labelText: "Question", icon: Icon(Icons.help)),
                maxLines: 6,
                controller: questionController);
          } else if (index <= _editOptions.length) {
            return Row(
              children: [
                Expanded(
                  flex: 8,
                  child: TextFormField(
                      decoration: InputDecoration(
                          labelText: "Option ${index.toString()}",
                          icon: Text("${index.toString()}.")),
                      maxLines: 2,
                      controller: _editOptions[index - 1]),
                ),
                Expanded(
                    flex: 2,
                    child: !deleteMode
                        ? Column(
                            children: [
                              Radio(
                                fillColor: MaterialStateColor.resolveWith(
                                    (states) =>
                                        (index - 1 == correctOptionIndex)
                                            ? Colors.green
                                            : Colors.red),
                                value: index - 1,
                                groupValue: (index - 1 == correctOptionIndex)
                                    ? index - 1
                                    : -1,
                                onChanged: (value) {
                                  setState(() {
                                    correctOptionIndex = index - 1;
                                  });
                                },
                              ),
                              Text(
                                  (index - 1 == correctOptionIndex)
                                      ? "Correct"
                                      : "Incorrect",
                                  style: TextStyle(
                                      color: (index - 1 == correctOptionIndex)
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 12))
                            ],
                          )
                        : IconButton(
                            onPressed: () {
                              if (_editOptions.length > 2) {
                                setState(() {
                                  _editOptions.removeAt(index - 1);
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "You need at least 2 options.")));
                              }
                            },
                            icon: Icon(Icons.delete),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          )),
              ],
            );
          } else {
            return Center(
                child: Container(
                    margin: const EdgeInsets.all(20.0),
                    child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            primary: const Color(0xFFf85f6a)),
                        onPressed: () {
                          setState(() {
                            _editOptions = [
                              ..._editOptions,
                              TextEditingController()
                            ];
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Option"))));
          }
        });
  }
}
