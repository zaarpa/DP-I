import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/doctorInterface/emergencyPortal/previousEmergencyRequestScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../services/chatServices/chatService.dart';
import '../../doctorInterface/emergencyPortal/chat.dart';

class EmergencyRequestList extends StatefulWidget {
  const EmergencyRequestList({super.key});

  @override
  State<EmergencyRequestList> createState() => _EmergencyRequestListState();
}

class _EmergencyRequestListState extends State<EmergencyRequestList> {
  final ChatService _chatService = ChatService();
  final _auth = FirebaseAuth.instance;
  bool showPreviousChats = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink.shade900,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text("Emergency Requests"),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PreviousEmergencyRequestList(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter, // 10% of the width, so there are ten blinds.
            colors: [Colors.white70, Colors.pink.shade50], // whitish to gray// repeats the gradient over the canvas
          ),
        ),
        child: StreamBuilder(
          stream: _chatService.emergencyRequestList(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text('Loading...'),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            // Display current emergency requests
              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
                  return ListTile(
                    onTap: () async {
                      await _chatService.dismissEmergencyRequest(data['senderID']);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Chat(
                            receiverUserID: data['senderID'],
                          ),
                        ),
                      );
                    },
                    title: Text(data['senderName']),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.pink.shade900,
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        fixedSize: const Size(100.0, 40.0),
                      ),
                      child: const Text("Respond"),
                      onPressed: () {
                        _chatService.dismissEmergencyRequest(data['senderID']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Chat(
                              receiverUserID: data['senderID'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              );
            },
        ),
      ),
    );
  }
}
