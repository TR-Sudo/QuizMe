// @dart=2.9
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizme/utils/auth.dart';
import 'package:quizme/model/db_user.dart';
import 'package:quizme/widgets/app_drawer.dart';
import 'package:quizme/views/my_quizzes.dart';
import 'dart:math';

class PeersScreen extends StatefulWidget {
  const PeersScreen({Key key}) : super(key: key);

  @override
  _PeersScreenState createState() => _PeersScreenState();
}

class _PeersScreenState extends State<PeersScreen> {
  var peersDB = FirebaseFirestore.instance.collection('peers');
  TextEditingController _controller = TextEditingController();
  String mainuser = "Admin";
  String _mainDocID;
  String _selectedID;
  int _selectedIndx = -1;
  bool deleteMode = false;

  @override
  void initState() {
    super.initState();
    getdocid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Peers List"),
        actions: [
          TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedIndx = -1;
                  deleteMode = !deleteMode;
                });
              },
              label: deleteMode
                  ? Text("Done", style: TextStyle(color: Colors.white))
                  : Text(""),
              icon: deleteMode
                  ? Icon(Icons.check, color: Colors.white)
                  : Icon(Icons.delete, color: Colors.white)),
        ],
        backgroundColor: const Color(0xFFf85f6a),
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder(
        stream: getData(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data.docs.isEmpty) {
            return const Center(child: Text("No Peers Added"));
          }
          return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext ctxt, int index) {
                final docData = snapshot.data.docs[index];
                return Container(
                    padding: const EdgeInsets.only(
                        left: 5, right: 5, top: 1, bottom: 1),
                    child: Card(
                        color: (_selectedIndx == index && deleteMode)
                            ? Colors.red[100]
                            : Colors.white,
                        child: Column(
                          children: [
                            ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.primaries[Random()
                                      .nextInt(Colors.primaries.length)],
                                  child: Text(
                                    docData['name'][0].toString().toUpperCase(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  docData['name'],
                                ),
                                onTap: () async {
                                  setState(() {
                                    _selectedIndx = index;
                                    _selectedID = docData.id;
                                  });
                                  if (deleteMode) {
                                    deleteUser(_selectedID, docData['name']);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyQuizzes(
                                              peerID: docData.id,
                                              peerName: docData['name'])),
                                    );
                                  }
                                }),
                          ],
                        )));
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFf85f6a),
          child: Icon(Icons.person_add_alt_1),
          onPressed: () async {
            _showDialog(context);
          }),
    );
  }

  _showDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String input;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Form(
            key: _formKey,
            child: SimpleDialog(
                title: const Center(
                  child: Text("ADD FRIEND"),
                ),
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Missing username";
                        }
                        if (value.contains(" ")) {
                          return "invalid username, can't contain spaces";
                        }

                        if (value.length < 6) {
                          return "Username must be longer than 6 characters";
                        }
                      },
                      onSaved: (value) {
                        input = value;
                      },
                      decoration:
                          const InputDecoration(labelText: "Enter Username"),
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      width: 200,
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                                (states) => const Color(0xFFf85f6a))),
                        onPressed: () {
                          setState(() {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              addpeer(input);
                              Navigator.pop(context);
                            }
                          });
                        },
                        icon: Icon(Icons.login),
                        label: Text("Submit"),
                      )),
                ]));
      },
    );
  }

  Future<void> getdocid() async {
    DBUser user = await getAuthedUser();

    if (user != null) {
      setState(() {
        mainuser = user.username;
      });
    }

    bool userdbexists = false;
    var res = await peersDB
        .where('mainuser', isEqualTo: mainuser.toString())
        .get()
        .then((value) {
      value.docs.forEach((result) {
        setState(() {
          userdbexists = true;
          _mainDocID = result.id;
        });
      });
    });

    print(userdbexists);
    if (userdbexists == false) {
      peersDB.add({
        'mainuser': mainuser,
      }).then((value) {
        setState(() {
          _mainDocID = value.id;
          userdbexists = true;
        });
      }).catchError((error) => print("Failed to add user: $error"));
    }
  }

  Future<void> deleteUser(String id, String name) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete ${name}?"),
          actions: [
            TextButton(
              child: const Text("NO"),
              onPressed: () {
                Navigator.pop(context);
                return;
              },
            ),
            TextButton(
              child: const Text("YES"),
              onPressed: () async {
                Navigator.pop(context);
                return peersDB
                    .doc(_mainDocID)
                    .collection('peernames')
                    .doc(id.toString())
                    .delete()
                    .then((value) => print("Peer Deleted"))
                    .catchError(
                        (error) => print("Failed to Delete Peer: $error"));
              },
            )
          ],
        );
      },
    );

    setState(() {
      _selectedIndx = -1;
    });
  }

  Future<void> addpeer(String peer) async {
    var userDB = FirebaseFirestore.instance.collection('users');
    var usersSnapshot = await userDB.where('Username', isEqualTo: peer).get();

    var peers = peersDB.doc(_mainDocID).collection('peernames');
    var peersSnapshot = await peers.where('name', isEqualTo: peer).get();

    if (peersSnapshot.size > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            duration: Duration(seconds: 5),
            content: Text(
              "User already exists",
              textAlign: TextAlign.start,
            ),
            backgroundColor: Colors.red),
      );
      return;
    } else if (usersSnapshot.size == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            duration: Duration(seconds: 5),
            content: Text(
              "The user does not exist",
              textAlign: TextAlign.start,
            ),
            backgroundColor: Colors.red),
      );
      return;
    } else {
      return peersDB
          .doc(_mainDocID.toString())
          .collection('peernames')
          .add({
            'name': peer,
          })
          .then((value) => print("Peer added"))
          .catchError((error) => print("Failed to add Peer: $error"));
    }
  }

  Stream<QuerySnapshot> getData() {
    return peersDB.doc(_mainDocID).collection('peernames').snapshots();
  }
}
