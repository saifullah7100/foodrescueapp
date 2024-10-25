// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:foods_rescue/Utils/appcolors.dart';
import 'package:foods_rescue/helper/widget.dart';

class NeedFood extends StatefulWidget {
  const NeedFood({super.key});

  @override
  State<NeedFood> createState() => _NeedFoodState();
}

class _NeedFoodState extends State<NeedFood> {
  Future<void> deleteDocument(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('needfoods')
          .doc(documentId)
          .delete();
      print('Document deleted successfully');
      showalertSnackbar(context, "Deleted successfully");
      // showCustomSnackbar(context, "Deleted successfully");
    } catch (e) {
      print('Error deleting document: $e');
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
        ),
        body: Column(
          children: [
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Container(
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(
            //           30), // Adjust the border radius as needed
            //       color: Colors
            //           .white, // Background color of the circular search field
            //       boxShadow: [
            //         BoxShadow(
            //           color: Colors.grey.withOpacity(0.5),
            //           spreadRadius: 2,
            //           blurRadius: 5,
            //           offset: Offset(0, 3),
            //         ),
            //       ],
            //     ),
            //     child: TextField(
            //       decoration: InputDecoration(
            //         contentPadding: EdgeInsets.symmetric(
            //             horizontal: 20), // Adjust the content padding as needed
            //         hintText: 'Search...',
            //         hintStyle: TextStyle(
            //             color: Colors
            //                 .grey), // Customize the hint text color if needed
            //         border: InputBorder.none, // Remove the border
            //         prefix: Padding(
            //           padding: const EdgeInsets.symmetric(
            //               vertical:
            //                   10), // Adjust the padding to center vertically
            //           child: Icon(Icons.search),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('needfoods')
                    .where('userid', isEqualTo: _auth.currentUser!.uid)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 05,
                      mainAxisSpacing: 05,
                      mainAxisExtent: 200,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot doc = snapshot.data!.docs[index];
                      return InkWell(
                        onTap: () {
                          // Handle item tap
                        },
                        child: Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: AppColor.appbarColor,
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
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      style: TextButton.styleFrom(
                              backgroundColor: AppColor.primaryColor,
                            ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return CupertinoAlertDialog(
                                                title: const Text('Alert'),
                                                content:  Text(
                                                    'Are you sure you want to delete this item?',style: AppColor.bebasstyle(),),
                                                actions: [
                                                  // The "Yes" button
                                                  CupertinoDialogAction(
                                                    onPressed: () {
                                                      deleteDocument(doc.id);
                                                      Navigator.of(context).pop();
                                                    },
                                                    isDefaultAction: true,
                                                    isDestructiveAction: true,
                                                    child:  Text('Delete,style: AppColor.bebasstyle(),'),
                                                  ),
                                                  // The "No" button
                                                  CupertinoDialogAction(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    isDefaultAction: false,
                                                    isDestructiveAction: false,
                                                    child: const Text('Back'),
                                                  )
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Text("Delete",style: AppColor.bebasstyle(),)),
                                    doc['accepted']
                                        ? myText("Status : Accepted",
                                            Colors.green, 14, FontWeight.bold)
                                        : myText("Status : Not Accepted",
                                            Colors.redAccent, 14, FontWeight.bold)
                                  ],
                                )
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
