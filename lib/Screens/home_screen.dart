import 'package:agriadmin/Components/navigation_bar.dart' as a;
import 'package:agriadmin/Models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// String userId = "";

class HomeScreen extends StatefulWidget {
  static const String routeName = '/HomeScreen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isFirstLoad = true;
  List<bool> switchs = [];

  // getUserId() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String id = prefs.getString('userId').toString();
  //   // print(id);
  //   if (id == "null") {
  //     // print("Empty Id");
  //     id = const Uuid().v4();
  //     prefs.setString('userId', id);
  //     userId = id;
  //     // print(userId);
  //     await FirebaseFirestore.instance.collection('users').doc(id).set({
  //       "userId": id,
  //       "dateTime": DateTime.now(),
  //     });
  //   } else {
  //     // print(id);
  //     userId = id;
  //     // print(userId);
  //   }
  //   // await prefs.setInt('counter', counter);
  //   setState(() {});
  // }

  // @override
  // void didChangeDependencies() {
  //   if (isFirstLoad) {
  //     getUserId();
  //   }
  //   isFirstLoad = false;

  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    // print(userId + "Printing User ID");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agri Admin'),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .orderBy("dateTime", descending: true)
              .snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final QuerySnapshot<Map<String, dynamic>>? data = snapshot.data;
            final dataDocs = data!.docs;
            final List<UserModel> files = [];
            for (var item in dataDocs) {
              files.add(UserModel.fromJson(item));
              switchs.add(false);
              // print(files[0].userId);
            }
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: files.length,
                // gridDelegate:
                //     const SliverGridDelegateWithFixedCrossAxisCount(
                //         crossAxisCount: 2,
                //         childAspectRatio: 3 / 2,
                //         crossAxisSpacing: 10,
                //         mainAxisSpacing: 10),
                itemBuilder: (context, index) {
                  return Dismissible(
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) async {
                      if (files[index].isRemoved) {
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(files[index].userId)
                            .update({"isRemoved": false});
                      } else {
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(files[index].userId)
                            .update({"isRemoved": true});
                      }
                      // switchs[index] = isOn;

                      setState(() {});
                    },
                    key: ObjectKey(files[index]),
                    child: Card(
                      child: ListTile(
                        key: ObjectKey(files[index]),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => a.NavigationBar(
                                userId: files[index].userId,
                              ),
                            ),
                          );
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        tileColor: files[index].isRemoved
                            ? Colors.white
                            : Colors.purple[300],
                        title: Text(
                          "User " + (index + 1).toString().toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                                  color: files[index].isRemoved
                                      ? Colors.purple[300]
                                      : Colors.white),
                        ),
                        subtitle: Text(
                            DateFormat()
                                .add_yMMMEd()
                                .format(files[index].userName.toDate()),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    color: files[index].isRemoved
                                        ? Colors.purple[300]
                                        : Colors.white)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (files[index].isExpert)
                              Text(
                                "Expert",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            Switch.adaptive(
                                value: files[index].isExpert,
                                onChanged: (isOn) async {
                                  await FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(files[index].userId)
                                      .update({"isExpert": isOn});
                                  // switchs[index] = isOn;

                                  setState(() {});
                                }),
                            IconButton(
                                onPressed: () async {
                                  if (files[index].isRemoved) {
                                    await FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(files[index].userId)
                                        .update({"isRemoved": false});
                                  } else {
                                    await FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(files[index].userId)
                                        .update({"isRemoved": true});
                                  }
                                  // switchs[index] = isOn;

                                  setState(() {});
                                },
                                icon: Icon(
                                  files[index].isRemoved
                                      ? Icons.add
                                      : Icons.remove,
                                  color: files[index].isRemoved
                                      ? Colors.purple[300]
                                      : Colors.white,
                                ))
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
    );
  }
}
