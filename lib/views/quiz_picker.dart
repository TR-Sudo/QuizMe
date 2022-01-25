// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

enum Subjects { Math, Science, Literature, Geography, Music }

class QuizPicker extends StatefulWidget {
  const QuizPicker({Key? key}) : super(key: key);

  @override
  _QuizPickerState createState() => _QuizPickerState();
}

// replace temp_padding with a preferred value
class _QuizPickerState extends State<QuizPicker> {
  Subjects? subject = Subjects.Math;

  // delete this later
  double temp_padding = 15;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container(
              //   color: Colors.red,
              //   child: Transform.scale(
              //     scale: 0.75,
              //     child: RadioListTile(
              //       title: const Text('Math'),
              //       value: Subjects.Math,
              //       groupValue: subject,
              //       onChanged: (Subjects? value) {
              //         setState(() {
              //           subject = value;
              //         });
              //       },
              //     ),
              //   ),
              // ),
              RadioListTile(
                title: const Text('Math'),
                value: Subjects.Math,
                groupValue: subject,
                onChanged: (Subjects? value) {
                  setState(() {
                    subject = value;
                  });
                },
              ),
              Text(
                "Performance",
                style: TextStyle(fontSize: 24),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircularPercentIndicator(
                    circularStrokeCap: CircularStrokeCap.round,
                    radius: 90.0,
                    lineWidth: 7.5,
                    percent: 0.64,
                    backgroundColor: Color(0xFFeef0f2),
                    header: Padding(
                      padding: EdgeInsets.symmetric(vertical: temp_padding),
                      child: Text(
                        "Current Week",
                        style: TextStyle(
                          color: Color(0xFFd9d9d9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    center: Text(
                      "64%",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF81e1ae),
                      ),
                    ),
                    progressColor: Color(0xFF81e1ae),
                  ),
                  CircularPercentIndicator(
                    circularStrokeCap: CircularStrokeCap.round,
                    radius: 90.0,
                    lineWidth: 7.5,
                    percent: 0.40,
                    backgroundColor: Color(0xFFeef0f2),
                    header: Padding(
                      padding: EdgeInsets.symmetric(vertical: temp_padding),
                      child: Text(
                        "Last Week",
                        style: TextStyle(
                          color: Color(0xFFd9d9d9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    center: Text(
                      "40%",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF85f6a),
                      ),
                    ),
                    progressColor: Color(0xFFf85f6a),
                  ),
                  CircularPercentIndicator(
                    circularStrokeCap: CircularStrokeCap.round,
                    radius: 90.0,
                    lineWidth: 7.5,
                    percent: 0.90,
                    backgroundColor: Color(0xFFeef0f2),
                    header: Padding(
                      padding: EdgeInsets.symmetric(vertical: temp_padding),
                      child: Text(
                        "Last Month",
                        style: TextStyle(
                          color: Color(0xFFd9d9d9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    center: Text(
                      "90%",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5e69f8),
                      ),
                    ),
                    progressColor: Color(0xFF5e69f8),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              Text('Score Board')
            ],
          ),
        ),
      ),
    );
  }
}
