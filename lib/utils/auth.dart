import 'package:quizme/model/db_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<DBUser?> getAuthedUser() async {
  User? user = FirebaseAuth.instance.currentUser;
  var userDB = FirebaseFirestore.instance.collection('users');

  if (user != null) {
    var usersSnapshot = await userDB.where('UID', isEqualTo: user.uid).get();

    if (usersSnapshot.size > 0) {
      var userData = usersSnapshot.docs[0].data();
      DBUser dbUser = DBUser(usersSnapshot.docs[0].id, user.uid,
          userData['Email'], userData['Username']);
      return dbUser;
    }
  }

  return null;
}
