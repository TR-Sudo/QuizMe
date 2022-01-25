import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:quizme/widgets/app_drawer.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_size_text/auto_size_text.dart';

class FactScreen extends StatefulWidget {
  const FactScreen({Key? key}) : super(key: key);

  @override
  _FactScreenState createState() => _FactScreenState();
}

class _FactScreenState extends State<FactScreen> {
  String fact = '';
  String apiKey = dotenv.env['FACT_KEY'] as String;

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Interesting Facts'),
          backgroundColor: const Color(0xFFf85f6a),
        ),
        drawer: const AppDrawer(),
        body: FutureBuilder(
            future: getData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return Container(
                margin: const EdgeInsets.only(
                    top: 30, left: 30, right: 30, bottom: 80),
                height: (MediaQuery.of(context).size.height -
                        appBar.preferredSize.height) /
                    1.1,
                width: MediaQuery.of(context).size.width,
                child: Card(
                  shadowColor: Colors.black,
                  elevation: 10,
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        const Text(
                          'Did you know?',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 28),
                        ),
                        SizedBox(
                          height: (MediaQuery.of(context).size.height - appBar.preferredSize.height) / 2,
                          child: Center(
                            child: AutoSizeText(
                              fact,
                              style: const TextStyle(
                                  fontSize: 20, overflow: TextOverflow.clip),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              setState(() {
                getData();
              });
            },
            backgroundColor: const Color(0xFFf85f6a),
            label: const Text("New Fact"),
            icon: const Icon(Icons.refresh)));
  }

  Future<String> getData() async {
    Map<String, String> _headers = {
      "content-type": "application/json",
      "x-rapidapi-host": "facts-by-api-ninjas.p.rapidapi.com",
      "x-rapidapi-key": apiKey,
    };

    var url = Uri.https('facts-by-api-ninjas.p.rapidapi.com', '/v1/facts');

    //Await the http get response, then decode the json-formatted response
    var response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      fact = jsonResponse[0]['fact'];
      return fact;
    } else {
      return 'Error: ${response.statusCode}';
    }
  }
}
