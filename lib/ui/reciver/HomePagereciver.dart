// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:foods_rescue/Utils/appcolors.dart';
import 'package:foods_rescue/helper/widget.dart';
import 'package:foods_rescue/ui/chat_screen.dart';

class HomePagereciver extends StatefulWidget {
  const HomePagereciver({super.key});

  @override
  State<HomePagereciver> createState() => _HomePagereciverState();
}

class _HomePagereciverState extends State<HomePagereciver> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> deleteDocument(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('foods')
          .doc(documentId)
          .delete();
      print('Document deleted successfully');
      showalertSnackbar(context, "Deleted successfully");
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  void acceptFood(
      String documentId, DocumentSnapshot foodDoc, String donorEmail) async {
    try {
      await FirebaseFirestore.instance
          .collection('foods')
          .doc(documentId)
          .update({'accepted': true});
      await FirebaseFirestore.instance.collection('food_requests').add({
        'donorEmail': donorEmail,
        'donorId': foodDoc['userid'],
        'foodTitle': foodDoc['title'],
        'foodDescription': foodDoc['description'],
        'userEmail': _auth.currentUser!.email,
        'userId': _auth.currentUser!.uid,
      });

      showCustomSnackbar(context, "Food accepted successfully");
    } catch (e) {
      print('Error accepting food: $e');
    }
  }

  Future<void> _showDonorDetail(BuildContext context, String donorId) async {
    final donorDoc =
        await FirebaseFirestore.instance.collection('users').doc(donorId).get();
    final donorData = donorDoc.data();

    if (donorData != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Donor Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Email: ${donorData['email'] }'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Donor details not found.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColor.appbarColor,
          title: Text("Food Available",style: AppColor.bebasstylesubheading(),),
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
                'Name: ${_auth.currentUser!.displayName.toString()}',
                style: AppColor.bebasstylesubheading(),
              ),
            ),
          ],
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('foods')
              .where('accepted', isEqualTo: false)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('An error occurred',style: AppColor.bebasstyle(),));
            }
      
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                mainAxisExtent: 360, // Adjusted height to fit buttons
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot doc = snapshot.data!.docs[index];
                return InkWell(
                  onTap: () {
                    // Handle item tap
                  },
                  child: Container(
                    margin: EdgeInsets.all(6),
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
                          Container(
                            height: 85,
                            width: double.infinity,
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
                          Text(
                            "Title: ${doc['title']}",
                            style: AppColor.bebasstyle(),
                          ),
                          Text(
                            "Desc: ${doc['description']}",
                            style: AppColor.bebasstyle(),
                          ),
                          Text(
                            "Location: ${doc['location']}",
                            style: AppColor.bebasstyle(),
                          ),
                          Column(
                            children: [
                              _auth.currentUser!.email != doc['useremail']
                                  ? ElevatedButton(
                                    style: TextButton.styleFrom(
                              backgroundColor: AppColor.primaryColor,
                            ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                              receiverUserEmail: doc['useremail'],
                                              receiverUserId: doc['userid'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Icon(Icons.chat,color: AppColor.subheadingColor,),
                                    )
                                  : ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return CupertinoAlertDialog(
                                              title:  Text('Alert',style: AppColor.bebasstyle(),),
                                              content:  Text(
                                                  'Are you sure you want to delete this item?',style: AppColor.bebasstyle(),),
                                              actions: [
                                                CupertinoDialogAction(
                                                  onPressed: () {
                                                    deleteDocument(doc.id);
                                                    Navigator.of(context).pop();
                                                  },
                                                  isDefaultAction: true,
                                                  isDestructiveAction: true,
                                                  child:  Text('Delete',style: AppColor.bebasstyle(),),
                                                ),
                                                CupertinoDialogAction(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  isDefaultAction: false,
                                                  isDestructiveAction: false,
                                                  child:  Text('Back',style: AppColor.bebasstyle(),),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child:
                                          Icon(Icons.delete, color: Colors.red),
                                    ),
                              _auth.currentUser!.email != doc['useremail']
                                  ? ElevatedButton(
                                    style: TextButton.styleFrom(
                              backgroundColor: AppColor.primaryColor,
                            ),
                                      onPressed: () {
                                        acceptFood(doc.id, doc, doc['useremail']);
                                      },
                                      child: Text(
                                        "Accept Food",
                                        style: AppColor.bebasstyle(),
                                      ),
                                    )
                                  : SizedBox(),
                              ElevatedButton(
                                style: TextButton.styleFrom(
                              backgroundColor: AppColor.primaryColor,
                            ),
                                onPressed: () {
                                  _showDonorDetail(context, doc['userid']);
                                },
                                child: Text(
                                  "Donor Detail",
                                  style: AppColor.bebasstyle(),
                                ),
                              ),
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
        ),
      ),
    );
  }
}
