// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
// @dart=2.9
import 'package:flutter/material.dart';
import 'package:quizme/utils/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizme/utils/app_colors.dart';
import 'package:quizme/model/db_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key key}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

// wrap this in a SizedBox with width: MediaQuery.of(context).size.width * 0.75 to change drawer width
// use the person's pfp
class _AppDrawerState extends State<AppDrawer> {
  String username = 'Admin';
  String email = 'Admin';
  @override
  void initState() {
    super.initState();
    retUser();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Container(
          margin: EdgeInsets.only(top: 5, bottom: 40, right: 15, left: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close),
                color: QuizAppColors.mainColor,
              ),
              Center(
                child: CircleAvatar(
                  child: Text(
                    username[0].toUpperCase(),
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                  radius: 50,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 2),
                child: Center(
                  child: Text(
                    username,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Center(
                child: Text(
                  email,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Spacer(),
              ListTile(
                leading: Icon(Icons.mail),
                onTap: () {
                  _showUpdateEmailDialog(context);
                },
                title: Text("Change Email"),
              ),
              ListTile(
                leading: Icon(Icons.password),
                onTap: () {
                  _showUpdatePasswordDialog(context);
                },
                title: Text("Change Password"),
              ),
              ListTile(
                leading: Icon(Icons.logout),
                onTap: () {
                  showLogoutConfirmation(context);
                },
                title: Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> retUser() async {
    DBUser user = await getAuthedUser();

    if (user != null) {
      setState(() {
        username = user.username;
        email = user.email;
      });
    }
  }

  showLogoutConfirmation(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget confirmButton = TextButton(
      child: Text("Log out"),
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, '/login');
      },
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Log out?"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            cancelButton,
            confirmButton,
          ],
        );
      },
    );
  }

  _showUpdateEmailDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String newEmail;
    String password;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Form(
            key: _formKey,
            child: SimpleDialog(
                title: Center(
                  child: Text("Change Email"),
                ),
                children: [
                  Container(
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: Column(
                        children: [
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Missing email";
                              }
                              if (!value.contains("@")) {
                                return "invalid email";
                              }
                              if (value.contains(" ")) {
                                return "invalid email, can't contain spaces";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              newEmail = value;
                            },
                            decoration:
                                InputDecoration(labelText: "Enter New Email"),
                          ),
                          SizedBox(height: 8.0),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Missing password";
                              }
                              if (value.length < 7) {
                                return 'Password must contain 7 characters';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              password = value;
                            },
                            obscureText: true,
                            decoration:
                                InputDecoration(labelText: "Enter Password"),
                          ),
                          SizedBox(height: 8.0),
                        ],
                      )),
                  Container(
                      padding: EdgeInsets.only(left: 40, right: 40),
                      width: 200,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            primary: const Color(0xFFf85f6a)),
                        onPressed: () {
                          setState(() {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              updateEmail(newEmail, password).then((value) {
                                if (value) {
                                  Navigator.pop(context);
                                  retUser();
                                }
                              });
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

  _showUpdatePasswordDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String oldPassword;
    String newPassword;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Form(
            key: _formKey,
            child: SimpleDialog(
                title: Center(
                  child: Text("Change Password"),
                ),
                children: [
                  Container(
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: Column(
                        children: [
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Missing password";
                              }
                              if (value.length < 7) {
                                return 'Password must contain 7 characters';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              oldPassword = value;
                            },
                            obscureText: true,
                            decoration: InputDecoration(
                                labelText: "Enter Current Password"),
                          ),
                          SizedBox(height: 8.0),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Missing password";
                              }
                              if (value.length < 7) {
                                return 'Password must contain 7 characters';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              newPassword = value;
                            },
                            obscureText: true,
                            decoration: InputDecoration(
                                labelText: "Enter New Password"),
                          ),
                          SizedBox(height: 8.0),
                        ],
                      )),
                  Container(
                      padding: EdgeInsets.only(left: 40, right: 40),
                      width: 200,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            primary: const Color(0xFFf85f6a)),
                        onPressed: () {
                          setState(() {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              updatePassword(oldPassword, newPassword)
                                  .then((value) {
                                if (value) {
                                  Navigator.pop(context);
                                  retUser();
                                }
                              });
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

  Future<bool> updateEmail(String newEmail, String password) async {
    var userDB = FirebaseFirestore.instance.collection('users');
    DBUser dbUser = await getAuthedUser();
    AuthCredential credential =
        EmailAuthProvider.credential(email: dbUser.email, password: password);

    try {
      await FirebaseAuth.instance.currentUser
          .reauthenticateWithCredential(credential);
      await FirebaseAuth.instance.currentUser.updateEmail(newEmail);
      await userDB.doc(dbUser.docID).update({'Email': newEmail});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            duration: Duration(seconds: 1),
            content: Text(
              "E-mail updated.",
              textAlign: TextAlign.start,
            ),
            backgroundColor: Colors.green),
      );

      return true;
    } catch (e) {
      String errorMessage;
      switch (e.code) {
        case "wrong-password":
          {
            errorMessage = "Password is incorrect.";
            break;
          }
        case "invalid-email":
          {
            errorMessage = "E-mail is invalid.";
            break;
          }
        case "email-already-in-use":
          {
            errorMessage = "E-mail is already in use.";
            break;
          }
        default:
          {
            errorMessage = "Could not update e-mail.";
            break;
          }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            duration: Duration(seconds: 5),
            content: Text(
              errorMessage,
              textAlign: TextAlign.start,
            ),
            backgroundColor: Colors.red),
      );
    }

    return false;
  }

  Future<bool> updatePassword(String oldPassword, String newPassword) async {
    var userDB = FirebaseFirestore.instance.collection('users');
    DBUser dbUser = await getAuthedUser();
    AuthCredential credential = EmailAuthProvider.credential(
        email: dbUser.email, password: oldPassword);

    try {
      await FirebaseAuth.instance.currentUser
          .reauthenticateWithCredential(credential);
      await FirebaseAuth.instance.currentUser.updatePassword(newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            duration: Duration(seconds: 1),
            content: Text(
              "Password updated.",
              textAlign: TextAlign.start,
            ),
            backgroundColor: Colors.green),
      );

      return true;
    } catch (e) {
      String errorMessage;
      switch (e.code) {
        case "wrong-password":
          {
            errorMessage = "Password is incorrect.";
            break;
          }
        case "weak-password":
          {
            errorMessage = "Password is too weak.";
            break;
          }
        default:
          {
            errorMessage = "Could not update password.";
            break;
          }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            duration: Duration(seconds: 5),
            content: Text(
              errorMessage,
              textAlign: TextAlign.start,
            ),
            backgroundColor: Colors.red),
      );
    }

    return false;
  }
}
