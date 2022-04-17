import 'package:flash_chat_flutter/components/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat_flutter/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
User? loggedInUser;
final _auth = FirebaseAuth.instance;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool showSpinner = false;

  late String messageText;
  final messageTextController = TextEditingController();

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
        print(loggedInUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  //when using .get method we can directly access the messages collection from the firebase database.
  void getMessages() async {
    final messages = await _firestore.collection('messages').get();
    for (int i = 0; i < messages.size; i++) {
      print(messages.docs[i]['sender']);
    }

    print(messages.docs[2]['text']);
  }

  //when we use the snapshot method we have to use the for each method twice to get to the text in firebase database
  void messageStream() async {
    final messageStreamData =
        await _firestore.collection('messages').snapshots();

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
                  // getMessages();
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    await _auth.signOut();
                    Navigator.pop(context);
                    setState(() {
                      showSpinner = false;
                    });
                  } catch (e) {
                    print(e);
                  }
                },
              ),
            ),
          ),
        ],
        title: Text('Hossain Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser!.email,
                        'time': FieldValue.serverTimestamp()
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

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('messages')
          .orderBy('time', descending: false) //add this
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        List<MessageBubble> messageBubbles = [];
        final messages = snapshot.data!.docs.reversed;
        int count = 0;
        for (var message in messages) {
          Map<String, dynamic> data = message.data() as Map<String, dynamic>;
          final messageText = data['text'];
          final messageSender = data['sender'];
          final currentUser = loggedInUser!.email;

          if (currentUser == messageSender) {}
          final messageBubble = MessageBubble(
              text: messageText,
              sender: messageSender,
              isMe: currentUser == messageSender);
          messageBubbles.add(messageBubble);
        }

        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 20,
            ),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  late final String sender, text;
  late bool isMe;

  MessageBubble({required this.text, required this.sender, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  )
                : BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
            elevation: 5.0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 20, 15, 5),
              child: Text(
                '$text\n',
                style: TextStyle(
                    fontSize: 15.0,
                    color: isMe ? Colors.white : Colors.black87),
              ),
            ),
            color: isMe ? Colors.lightBlue : Colors.white,
          ),
        ],
      ),
    );
  }
}
