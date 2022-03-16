import 'package:agriadmin/Models/reply_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReplyScreen extends StatefulWidget {
  final String userId;
  final String type;
  const ReplyScreen({Key? key, required this.userId, required this.type})
      : super(key: key);

  @override
  _ReplyScreenState createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {
  final textFormField = TextEditingController();

  sendReply() async {
    if (textFormField.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection(widget.type)
          .add({
        'reply': textFormField.text,
        'time': DateTime.now(),
      });
      textFormField.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection(widget.type)
              .orderBy("time", descending: true)
              .snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            List<ReplyModel> replyList = [];
            final messages = snapshot.data!.docs;
            for (var item in messages) {
              replyList.add(ReplyModel.fromJson(item));
            }
            return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: replyList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(replyList[index].reply),
                  );
                });
          }),
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextFormField(
          controller: textFormField,
          decoration: InputDecoration(
            suffixIcon: IconButton(
                onPressed: () => sendReply(), icon: const Icon(Icons.send)),
            hintText: 'Reply',
          ),
        ),
      ),
    );
  }
}
