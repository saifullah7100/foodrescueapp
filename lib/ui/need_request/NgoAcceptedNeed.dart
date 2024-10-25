// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:foods_rescue/Utils/appcolors.dart';
import 'package:foods_rescue/helper/widget.dart';
import 'package:foods_rescue/ui/chat_screen.dart';

class NgoAcceptedNeedPage extends StatelessWidget {
  const NgoAcceptedNeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back,color: AppColor.subheadingColor,)),
          backgroundColor: AppColor.appbarColor,
          title: Text('My Food Requests',style: AppColor.bebasstylesubheading(),),
        ),
        body: NgoAcceptedNeedRequestList(), // Widget to display food requests
      ),
    );
  }
}

class NgoAcceptedNeedRequestList extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

   NgoAcceptedNeedRequestList({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> deleteDocument(String documentId) async {
      try {
        await FirebaseFirestore.instance
            .collection('need_requests')
            .doc(documentId)
            .delete();
        print('Document deleted successfully');
        showCustomSnackbar(context, "Received successfully");
        // showCustomSnackbar(context, "Deleted successfully");
      } catch (e) {
        print('Error deleting document: $e');
      }
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('need_requests')
          .where('NgoEmail', isEqualTo: _auth.currentUser!.email)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.error != null) {
          return  Center(
            child: Text('Error fetching data',style: AppColor.bebasstyle(),),
          );
        }
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 05,
            mainAxisSpacing: 05,
            mainAxisExtent: 160,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Food Required: ${doc['foodTitle']}",
                        style: AppColor.bebasstyle(),
                        overflow: TextOverflow.visible,
                      ),
                      Text(
                        "Donated by: ${doc['userEmail']}",
                        style: AppColor.bebasstyle(),
                        overflow: TextOverflow.visible,
                      ),
                      Text(
                        "Details: ${doc['foodDescription']}",
                        style: AppColor.bebasstyle(),
                        overflow: TextOverflow.visible,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: AppColor.primaryColor,
                            ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                            receiverUserEmail: doc['userEmail'],
                                            receiverUserId: doc['userId'])));
                              },
                              icon: Icon(
                                Icons.chat,
                                color: AppColor.subheadingColor,
                              ),
                              label: Text("Send Message",style: AppColor.bebasstyle(),)),
                          ElevatedButton(
                            style: TextButton.styleFrom(
                              backgroundColor: AppColor.primaryColor,
                            ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoAlertDialog(
                                      title:  Text('Alert',style: AppColor.bebasstyle(),),
                                      content: const Text(
                                          'Are you sure you want to Confrim Received this item? after that this disapraed'),
                                      actions: [
                                        // The "Yes" button
                                        CupertinoDialogAction(
                                          onPressed: () {
                                            deleteDocument(doc.id);
                                            Navigator.of(context).pop();
                                          },
                                          isDefaultAction: true,
                                          isDestructiveAction: true,
                                          child:  Text('Yes',style: AppColor.bebasstyle(),),
                                        ),
                                        // The "No" button
                                        CupertinoDialogAction(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          isDefaultAction: false,
                                          isDestructiveAction: false,
                                          child:  Text('Back',style: AppColor.bebasstyle(),),
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text("Received",style: AppColor.bebasstyle(),)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
