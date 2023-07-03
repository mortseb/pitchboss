import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_page.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

void signUp(BuildContext context, String username, String email, String password) async {
  try {
    await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String userId = auth.currentUser!.uid;

    // Check if the user already exists in the 'users' collection
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
    await firestore.collection('users').doc(userId).get();

    if (!userSnapshot.exists) {
      // User does not exist, create fields with default values
      await firestore.collection('users').doc(userId).set({
        'credits': 10000,
        'username': username,
        'numberOfPacks': 0,
      });
    }

    // Show a success dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Up Successful'),
          content: Text('You have successfully registered. You have been credited with 10,000 credits.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Redirect to the home page here
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
          ],
        );
      },
    );
  } catch (e) {
    print(e);
  }
}

void signIn(BuildContext context, String email, String password) async {
  try {
    await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // User logged in successfully, you can show a success dialog here
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign In Successful'),
          content: Text('You have successfully signed in.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Redirect to the home page here
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
          ],
        );
      },
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Sign In Failed'),
            content: Text('No user found for that email.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    } else if (e.code == 'wrong-password') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Sign In Failed'),
            content: Text('Wrong password provided for that user.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    }
  } catch (e) {
    print(e);
  }
}