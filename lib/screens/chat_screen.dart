import 'package:flash_chat_flutter/components/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat_flutter/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  final _firesotre = FirebaseFirestore.instance;
  late User loggedInUser;
  late String messageText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  //when using .get method we can directly access the messages collection from the firebase database.
  void getMessages() async {
    final messages = await _firesotre.collection('messages').get();
    for (int i = 0; i < messages.size; i++) {
      print(messages.docs[i]['sender']);
    }

    print(messages.docs[2]['text']);
  }

  //when we use the snapshot method we have to use the for each method twice to get to the text in firebase database
  void messageStream() async {
    final messageStreamData =
        await _firesotre.collection('messages').snapshots();

    messageStreamData.forEach((element) {
      element.docs.forEach((messageElement) {
        print(messageElement.data());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ModalProgressHUD(
              inAsyncCall: showSpinner,
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(150.0),
                ),
                child: Text('Sign Out'),
                color: Colors.blueGrey,
                onPressed: () async {
                  //messageStream();
                  getMessages();
                  // setState(() {
                  //   showSpinner = true;
                  // });
                  // try {
                  //   await _auth.signOut();
                  //   Navigator.pop(context);
                  //   setState(() {
                  //     showSpinner = false;
                  //   });
                  // } catch (e) {
                  //   print(e);
                  // }
                },
              ),
            ),
          ),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        messageText = value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      _firesotre.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                      });
                      //Implement send functionality.
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
