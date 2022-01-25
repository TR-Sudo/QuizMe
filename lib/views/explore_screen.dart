import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quizme/utils/categories.dart';
import 'package:quizme/views/quiz_game.dart';
import 'package:quizme/widgets/app_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final quizzes = FirebaseFirestore.instance.collection('quizzes');
  List<DocumentSnapshot> filterDocs = [];

  int _selectedIndex = -1;
  String _docID = '';

  List<String> options = ['All', ...CATEGORIES];
  String dropdownValue = 'All';

  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore"),
        backgroundColor: const Color(0xFFf85f6a),
      ),
      drawer: const AppDrawer(),
      resizeToAvoidBottomInset: false,
      body: StreamBuilder(
        stream: quizzes.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          filterDocs = snapshot.data!.docs;

          //Filter for completed quizzes
          filterDocs = filterDocs.where((element) {
            return element.get('isComplete') == true;
          }).toList();

          //Filter quizzes by dropdown selection
          if (dropdownValue != 'All') {
            filterDocs = filterDocs.where((element) {
              return element
                  .get('Category')
                  .toString()
                  .toLowerCase()
                  .contains(dropdownValue.toLowerCase());
            }).toList();
          }

          //Filter quizzes by search value
          if (_searchController.text != '') {
            filterDocs = filterDocs.where((element) {
              return element
                  .get('Name')
                  .toString()
                  .toLowerCase()
                  .startsWith(_searchController.text.toLowerCase());
            }).toList();
          }

          return Column(children: [
            Container(
                padding: const EdgeInsets.all(15),
                color: Colors.red[100],
                child: Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (String? newValue) {
                          setState(() {});
                        },
                        decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 0.0),
                            ),
                            border: OutlineInputBorder(),
                            hintText: 'Search',
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: EdgeInsets.all(14)),
                      ),
                    ),
                    ButtonTheme(
                      alignedDropdown: true,
                      child: Container(
                          margin: const EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 0),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4)),
                          child: DropdownButton<String>(
                            value: dropdownValue,
                            icon: const Icon(Icons.arrow_downward),
                            iconEnabledColor: Color(0xFFf85f6a),
                            iconSize: 20,
                            style: const TextStyle(color: Colors.black),
                            underline: Container(
                              height: 0,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                              });
                            },
                            items: options
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Container(
                                  width: 50,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    value,
                                  ),
                                ),
                              );
                            }).toList(),
                          )),
                    ),
                  ],
                )),
            Expanded(
                child: ListView.builder(
                    itemCount: filterDocs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final docData = filterDocs[index].data() as Map;
                      return GestureDetector(
                          onTap: () {
                            String quizID = filterDocs[index].id;
                            print(quizID);
                            Navigator.pushNamed(context, '/quizgame',
                                arguments: QuizScreenArguments(quizID));
                            // setState(() {
                            //   _selectedIndex = index;
                            //   _docID = snapshot.data!.docs[index].id;
                            // });
                          },
                          child: Container(
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 1, bottom: 1),
                              child: Card(
                                elevation: 1,
                                child: ListTile(
                                  title: Text(docData['Name'].toString()),
                                  subtitle: Text(docData['User'].toString()),
                                  trailing: const Icon(Icons.arrow_forward),
                                ),
                              )));
                    }))
          ]);
        },
      ),
    );
  }
}
