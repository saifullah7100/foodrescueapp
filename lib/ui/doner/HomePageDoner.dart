import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foods_rescue/Utils/appcolors.dart';
import 'package:foods_rescue/helper/widget.dart';
import 'package:foods_rescue/ui/chat_screen.dart';

class HomePageDoner extends StatefulWidget {
  const HomePageDoner({super.key});

  @override
  State<HomePageDoner> createState() => _HomePageDonerState();
}

class _HomePageDonerState extends State<HomePageDoner> {
  Future<void> deleteDocument(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('needfoods')
          .doc(documentId)
          .delete();
      print('Document deleted successfully');
      showalertSnackbar(context, "Deleted successfully");
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  void acceptNeed(
      String documentId, DocumentSnapshot foodDoc, String ngoEmail) async {
    try {
      await FirebaseFirestore.instance
          .collection('needfoods')
          .doc(documentId)
          .update({'accepted': true});

      await FirebaseFirestore.instance.collection('need_requests').add({
        'NgoEmail': foodDoc['useremail'],
        'NgoId': foodDoc['userid'],
        'foodTitle': foodDoc['title'],
        'foodDescription': foodDoc['description'],
        'userEmail': _auth.currentUser!.email,
        'userId': _auth.currentUser!.uid,
      });

      showCustomSnackbar(context, "Need accepted successfully");
    } catch (e) {
      print('Error accepting food: $e');
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColor.appbarColor,
          title: Text(
            "Need for Food",
            style: AppColor.bebasstylesubheading(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _auth.currentUser!.photoURL.toString(),
                style: AppColor.bebasstylesubheading(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Name :${_auth.currentUser!.displayName.toString()}',
                style: AppColor.bebasstylesubheading(),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('needfoods')
                    .where('accepted', isEqualTo: false)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                      mainAxisExtent: 320,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot doc = snapshot.data!.docs[index];
                      return InkWell(
                        onTap: () {
                          // Handle item tap
                        },
                        child: Container(
                          margin: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: AppColor.appbarColor
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "Food Required: ${doc['title']}",
                                  style: AppColor.bebasstyle(),
                                ),
                                Text(
                                  "Request by: ${doc['name']}",
                                  style: AppColor.bebasstyle(),
                                ),
                                Text(
                                  "Details: ${doc['description']}",
                                  style: AppColor.bebasstyle(),
                                ),
                                 Text(
                            "Location: ${doc['location']}",
                            style: AppColor.bebasstyle(),
                          ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if (_auth.currentUser!.email !=
                                          doc['useremail'])
                                        ElevatedButton(
                                          style: TextButton.styleFrom(
                              backgroundColor: AppColor.primaryColor,
                            ),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatScreen(
                                                            receiverUserEmail:
                                                                doc['useremail'],
                                                            receiverUserId:
                                                                doc['userid'])));
                                          },
                                          child: const Icon(Icons.chat,color: AppColor.subheadingColor,),
                                        ),
                                      if (_auth.currentUser!.email ==
                                          doc['useremail'])
                                        InkWell(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return CupertinoAlertDialog(
                                                  title:  Text('Alert',style: AppColor.bebasstyle(),),
                                                  content: Text(
                                                      'Are you sure you want to delete this item?',
                                                      style: AppColor.bebasstyle(),),
                                                  actions: [
                                                    CupertinoDialogAction(
                                                      onPressed: () {
                                                        deleteDocument(doc.id);
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      isDefaultAction: true,
                                                      isDestructiveAction: true,
                                                      child: Text('Delete',style: AppColor.bebasstyle(),),
                                                    ),
                                                    CupertinoDialogAction(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      isDefaultAction: false,
                                                      isDestructiveAction: false,
                                                      child:Text('Back',style: AppColor.bebasstyle(),),
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                      if (_auth.currentUser!.email !=
                                          doc['useremail'])
                                        ElevatedButton(
                                          style: TextButton.styleFrom(
                              backgroundColor: AppColor.primaryColor,
                            ),
                                          onPressed: () {
                                            acceptNeed(
                                                doc.id, doc, doc['useremail']);
                                          },
                                          child: Text("Accept Need",style: AppColor.bebasstyle(),),
                                        ),
                                      ElevatedButton(
                                        style: TextButton.styleFrom(
                              backgroundColor: AppColor.primaryColor,
                            ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title:  Text('Receiver Details',style: AppColor.bebasstyle(),),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        "Email: ${doc['useremail']},style: AppColor.bebasstyle(),"),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child:  Text('Close',style: AppColor.bebasstyle(),),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child:  Text("Receiver Details",style: AppColor.bebasstyle(),),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
