import 'package:chat_app/component/drawer.dart';
import 'package:chat_app/component/text_field.dart';
import 'package:chat_app/component/wall_post.dart';
import 'package:chat_app/component/wall_text_field.dart';
import 'package:chat_app/helper/helper_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // current user
  final currentUser = FirebaseAuth.instance.currentUser!;

  // textController
  final textController = TextEditingController();

  // Sign out
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  // Post message
  void postMessage() {
    // only post if there is something in the textfield
    if (textController.text.isNotEmpty) {
      // store in firebase
      FirebaseFirestore.instance.collection('User posts').add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': []
      });
    }

    // clear the textfiled
    setState(() {
      textController.clear();
    });
  }

  // Navigate to profile page
  void goToProfilePage() {
    // pop menu drawer
    Navigator.pop(context);
    // go to profile page
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const ProfilePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("The Wall"),
      ),
      drawer: MyDrawer(
        onTapProfile: goToProfilePage,
        onTapSignOut: signOut,
      ),
      body: Center(
        child: Column(
          children: [
            // the Wall
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User posts")
                    .orderBy("TimeStamp", descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          // get the message
                          final post = snapshot.data!.docs[index];
                          return WallPost(
                            message: post['Message'],
                            user: post['UserEmail'],
                            time: formatDate(post['TimeStamp']),
                            postId: post.id,
                            likes: List<String>.from(post['Likes'] ?? []),
                          );
                        });
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error:${snapshot.error}'),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),

            // post messages
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  // text field
                  Expanded(
                    child: Wall_Text_Field(
                      controller: textController,
                      hintText: "Write something on the wall",
                      obscureText: false,
                    ),
                  ),
                  // post button
                  IconButton(
                      onPressed: postMessage,
                      icon: const Icon(Icons.arrow_circle_up))
                ],
              ),
            ),
            // logged in as
            Text(
              "Logged in as: " + currentUser.email!,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
