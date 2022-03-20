import 'dart:io';

import 'package:agriadmin/Components/audio_preview.dart';
import 'package:agriadmin/Models/file_model.dart';
import 'package:agriadmin/Screens/reply_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class EquipmentScreen extends StatefulWidget {
  final String userId;
  const EquipmentScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _EquipmentScreenState createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agri Equipment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReplyScreen(
                            userId: widget.userId,
                            type: "EquipmentMessages",
                          )));
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId)
                  .collection("Equipment")
                  .orderBy('dateTime', descending: true)
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final QuerySnapshot<Map<String, dynamic>>? data = snapshot.data;
                final dataDocs = data!.docs;
                final List<FileModel> files = [];
                for (var item in dataDocs) {
                  files.add(FileModel.fromJson(item));
                  // print(files[0].url);
                }
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: files.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3 / 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10),
                    itemBuilder: (context, index) {
                      return files[index].type == "image"
                          ? InkWell(
                              onLongPress: () {
                                bool loading = false;
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(
                                          builder: (context, setState) {
                                        return Stack(
                                          children: [
                                            AlertDialog(
                                              title:
                                                  const Text("Image Preview"),
                                              content: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  CachedNetworkImage(
                                                      imageUrl:
                                                          files[index].url,
                                                      fit: BoxFit.cover,
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Icon(
                                                              Icons.error)),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                      DateFormat()
                                                          .add_yMMMEd()
                                                          .format(files[index]
                                                              .dateTime
                                                              .toDate()),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!)
                                                ],
                                              ),
                                              actions: [
                                                ElevatedButton.icon(
                                                    onPressed: () async {
                                                      // File(path)
                                                      setState(() {
                                                        loading = true;
                                                      });
                                                      final imageurl =
                                                          files[index].url;
                                                      final uri =
                                                          Uri.parse(imageurl);
                                                      final response =
                                                          await get(uri);
                                                      final bytes =
                                                          response.bodyBytes;
                                                      final temp =
                                                          await getTemporaryDirectory();
                                                      final path =
                                                          '${temp.path}/image.jpg';
                                                      File(path)
                                                          .writeAsBytesSync(
                                                              bytes);
                                                      await Share.shareFiles(
                                                          [path],
                                                          text: 'Image Shared');
                                                      setState(() {
                                                        loading = false;
                                                      });
                                                    },
                                                    icon:
                                                        const Icon(Icons.share),
                                                    label: const Text(
                                                        "Share Image")),
                                              ],
                                            ),
                                            if (loading)
                                              Container(
                                                color: Colors.black38,
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator
                                                          .adaptive(),
                                                ),
                                              )
                                          ],
                                        );
                                      });
                                    });
                              },
                              child: CachedNetworkImage(
                                  imageUrl: files[index].url,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error)),
                            )
                          : InkWell(
                              onLongPress: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(
                                          builder: (context, setState) {
                                        bool loading = false;
                                        return Stack(
                                          children: [
                                            AlertDialog(
                                              title:
                                                  const Text("Audio Preview"),
                                              content: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  AudioPreview(
                                                    url: files[index].url,
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                      DateFormat()
                                                          .add_yMMMEd()
                                                          .format(files[index]
                                                              .dateTime
                                                              .toDate()),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!)
                                                ],
                                              ),
                                              actions: [
                                                ElevatedButton.icon(
                                                    onPressed: () async {
                                                      // File(path)
                                                      setState(() {
                                                        loading = true;
                                                      });
                                                      final audiourl =
                                                          files[index].url;
                                                      final uri =
                                                          Uri.parse(audiourl);
                                                      final response =
                                                          await get(uri);
                                                      final bytes =
                                                          response.bodyBytes;
                                                      final temp =
                                                          await getTemporaryDirectory();
                                                      final path =
                                                          '${temp.path}/audio.mp3';
                                                      File(path)
                                                          .writeAsBytesSync(
                                                              bytes);
                                                      await Share.shareFiles(
                                                          [path],
                                                          text: 'Audio Shared');
                                                      setState(() {
                                                        loading = false;
                                                      });
                                                    },
                                                    icon:
                                                        const Icon(Icons.share),
                                                    label: const Text(
                                                        "Share Audio")),
                                              ],
                                            ),
                                            if (loading)
                                              Container(
                                                color: Colors.black38,
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator
                                                          .adaptive(),
                                                ),
                                              )
                                          ],
                                        );
                                      });
                                    });
                              },
                              child: AudioPreview(
                                url: files[index].url,
                              ),
                            );
                    },
                  ),
                );
              }),
          // Positioned(
          //   bottom: 10,
          //   left: 0,
          //   right: 0,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       ElevatedButton.icon(
          //           style: ElevatedButton.styleFrom(
          //               elevation: 6,
          //               padding: const EdgeInsets.symmetric(
          //                   vertical: 10, horizontal: 20)),
          //           onPressed: () {
          //             Navigator.of(context)
          //                 .pushNamed(UploadImagesScreen.routeName, arguments: {
          //               'collection': "Equipment",
          //             });
          //           },
          //           icon: const Icon(Icons.add_a_photo),
          //           label: Text("Upload Image".toUpperCase())),
          //       ElevatedButton.icon(
          //           style: ElevatedButton.styleFrom(
          //               elevation: 6,
          //               padding: const EdgeInsets.symmetric(
          //                   vertical: 10, horizontal: 20)),
          //           onPressed: () {
          //             Navigator.of(context)
          //                 .pushNamed(AudioScreen.routeName, arguments: {
          //               'collection': "Equipment",
          //             });
          //           },
          //           icon: const Icon(Icons.audiotrack),
          //           label: Text("Upload Audio".toUpperCase()))
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }
}
