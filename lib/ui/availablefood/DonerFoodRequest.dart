import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foods_rescue/Utils/appcolors.dart';
import 'package:foods_rescue/helper/widget.dart';
import 'package:foods_rescue/ui/chat_screen.dart';

class DonerRequestPage extends StatelessWidget {
  const DonerRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back,color: AppColor.subheadingColor,)),
          backgroundColor: AppColor.appbarColor,
          title: Text('My Food Available Requests',style: AppColor.bebasstylesubheading(),),
        ),
        body: donerRequestList(), // Widget to display food requests
      ),
    );
  }
}

class donerRequestList extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

   donerRequestList({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> deleteDocument(String documentId) async {
      try {
        await FirebaseFirestore.instance
            .collection('food_requests')
            .doc(documentId)
            .delete();
        print('Document deleted successfully');
        showCustomSnackbar(context, "Delivered successfully");
        // showCustomSnackbar(context, "Deleted successfully");
      } catch (e) {
        print('Error deleting document: $e');
      }
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('food_requests')
          .where('donorEmail', isEqualTo: _auth.currentUser!.email)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.error != null) {
          return const Center(
            child: Text('Error fetching data'),
          );
        }
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                margin: const EdgeInsets.all(10),
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
                        "Request by: ${doc['userEmail']}",
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
                            style: ElevatedButton.styleFrom(
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
                              icon: const Icon(
                                Icons.chat,
                                color: AppColor.subheadingColor,
                              ),
                              label:  Text("Send Message",style: AppColor.bebasstyle(),)),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoAlertDialog(
                                      title: const Text('Alert'),
                                      content: const Text(
                                          'Are you sure you want to Confrim Delivered this item? after that this disapraed'),
                                      actions: [
                                        // The "Yes" button
                                        CupertinoDialogAction(
                                          onPressed: () {
                                            deleteDocument(doc.id);
                                            Navigator.of(context).pop();
                                          },
                                          isDefaultAction: true,
                                          isDestructiveAction: true,
                                          child: const Text('Yes'),
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
                              child:  Text("Delivered",style: AppColor.bebasstyle(),)),
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
