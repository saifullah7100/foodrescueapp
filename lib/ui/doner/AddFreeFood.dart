// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foods_rescue/Utils/appcolors.dart';
import 'package:foods_rescue/helper/widget.dart';
// Import Firestore

class AddFreeFood extends StatefulWidget {
  const AddFreeFood({super.key});

  @override
  State<AddFreeFood> createState() => _AddFreeFoodState();
}

class _AddFreeFoodState extends State<AddFreeFood> {
// Function to delete a document from Firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    Future<void> deleteDocument(String documentId) async {
      try {
        await FirebaseFirestore.instance
            .collection('foods')
            .doc(documentId)
            .delete();
        print('Document deleted successfully');
        showalertSnackbar(context, "Deleted successfully");
        // showCustomSnackbar(context, "Deleted successfully");
      } catch (e) {
        print('Error deleting document: $e');
      }
    }

    void acceptFood(
        String documentId, DocumentSnapshot foodDoc, String donorEmail) async {
      try {
        // Update the document in Firestore to indicate that the food has been accepted
        await FirebaseFirestore.instance
            .collection('foods')
            .doc(documentId)
            .update({'accepted': true});

        // Create a new document in the food_requests collection
        await FirebaseFirestore.instance.collection('food_requests').add({
          'donorEmail': donorEmail,
          'donorId': foodDoc['userid'],
          'foodTitle': foodDoc['title'],
          'foodDescription': foodDoc['description'],
          'userEmail': _auth.currentUser!.email,
          'userId': _auth.currentUser!.uid,
          // Add any other relevant data
        });

        // Show a confirmation message
        showCustomSnackbar(context, "Food accepted successfully");
      } catch (e) {
        print('Error accepting food: $e');
      }
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColor.appbarColor,
          title: Text("Add Free Food",style: AppColor.bebasstylesubheading(),),
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
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('foods')
              .where('useremail', isEqualTo: _auth.currentUser!.email)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.error != null) {
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
                    margin: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: AppColor.appbarColor,
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 85,
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(doc['imageUrl']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Title: ${doc['title']}",
                                      style: AppColor.bebasstyle(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "Desc: ${doc['description']}",
                                      style: AppColor.bebasstyle(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "Location: ${doc['location']}",
                                      style: AppColor.bebasstyle(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
      
                          //  if (_auth.currentUser!.email != doc['email']){
      
                          //  }
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                          title:  Text('Alert',style: AppColor.bebasstyle(),),
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
                                              child:  Text('Delete',style: AppColor.bebasstyle(),),
                                            ),
                                            // The "No" button
                                            CupertinoDialogAction(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              isDefaultAction: false,
                                              isDestructiveAction: false,
                                              child: Text('Back',style: AppColor.bebasstyle(),),
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Text("Delete",style: AppColor.bebasstyle(),)),
                              doc['accepted']
                                  ? myText("Status : Accepted", Colors.green, 14,
                                      FontWeight.bold)
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
    );
  }
}
