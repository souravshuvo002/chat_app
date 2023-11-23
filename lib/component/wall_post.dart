import 'package:chat_app/component/comment_button.dart';
import 'package:chat_app/component/comments.dart';
import 'package:chat_app/component/delete_button.dart';
import 'package:chat_app/component/like_button.dart';
import 'package:chat_app/helper/helper_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;

  const WallPost(
      {super.key,
      required this.message,
      required this.user,
      required this.time,
      required this.postId,
      required this.likes});

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  // User
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  //Comment TextController
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  // toggle like
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    // Access the documents in firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User posts').doc(widget.postId);

    if (isLiked) {
      // if the post is now liked, add user's email to the "Liked" field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      // if the post is now unliked, remove the user's email from the "Liked" field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  // Show dialog box for adding comment
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: _commentTextController,
          decoration: const InputDecoration(hintText: "Write a comment..."),
        ),
        actions: [
          // Cancel Button
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                //clear the controller
                _commentTextController.clear();
              },
              child: const Text('Cancel')),

          // Post Button
          TextButton(
              onPressed: () {
                // add the comment
                addComment(_commentTextController.text);
                // pop box
                Navigator.pop(context);
                //clear the controller
                _commentTextController.clear();
              },
              child: const Text('Post')),
        ],
      ),
    );
  }

  // add a comment
  void addComment(String commentText) {
    // Write the comment in firestore comment section
    FirebaseFirestore.instance
        .collection('User posts')
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentBy": currentUser.email,
      "CommentTime": Timestamp.now()
    });
  }

  // delete post
  void deletePost() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Delete Post?'),
              content: const Text("Are you sure you want to delete this post?"),
              actions: [
                //Cancel
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                // Delete
                TextButton(
                    onPressed: () async {
                      // delete the comments from the firestore first
                      // lif you only delete the post, the comments will be stores in the firestore
                      final commentDocs = await FirebaseFirestore.instance
                          .collection("User posts")
                          .doc(widget.postId)
                          .collection("Comments")
                          .get();

                      for (var doc in commentDocs.docs) {
                        await FirebaseFirestore.instance
                            .collection("User posts")
                            .doc(widget.postId)
                            .collection("Comments")
                            .doc(doc.id)
                            .delete();
                      }

                      // then delete the post
                      FirebaseFirestore.instance
                          .collection("User posts")
                          .doc(widget.postId)
                          .delete()
                          .then((value) => print("Post deleted"))
                          .catchError((error) =>
                              print("Failed to delete post: $error"));

                      // pop box
                      Navigator.pop(context);
                    },
                    child: const Text("Delete"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wallpost
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // message, user email
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // message
                  Text(widget.message),
                  const SizedBox(
                    height: 5,
                  ),
                  // user
                  Row(
                    children: [
                      Text(
                        widget.user,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(
                        ".",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(
                        widget.time,
                        style: TextStyle(color: Colors.grey[400]),
                      )
                    ],
                  ),
                ],
              ),
              // Delete button
              if (widget.user == currentUser.email)
                DeleteButton(onTap: deletePost),
            ],
          ),

          const SizedBox(
            height: 20,
          ),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Like
              Column(
                children: [
                  // Like Button
                  LikeButton(isLiked: isLiked, onTap: toggleLike),

                  const SizedBox(
                    height: 5,
                  ),

                  // Like Count
                  Text(
                    widget.likes.length.toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              //Comment
              Column(
                children: [
                  // Comment Button
                  CommentButton(
                    onTap: showCommentDialog,
                  ),
                  const SizedBox(
                    height: 5,
                  ),

                  // comment Count
                  const Text(
                    "0",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
          // Comment under the post
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("User posts")
                .doc(widget.postId)
                .collection('Comments')
                .orderBy("CommentTime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              // show loading circle if no data yet
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView(
                shrinkWrap: true, // for nested lists
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  // get the comment
                  final commentData = doc.data() as Map<String, dynamic>;
                  // return the comment
                  return Comments(
                    text: commentData['CommentText'],
                    user: commentData['CommentBy'],
                    time: formatDate(commentData['CommentTime']),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
