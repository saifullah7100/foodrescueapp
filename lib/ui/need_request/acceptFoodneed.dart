import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foods_rescue/Utils/appcolors.dart';
import 'package:foods_rescue/ui/chat_screen.dart';

class acceptFoodneedPage extends StatelessWidget {
  const acceptFoodneedPage({super.key});

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
          title:  Text('Accepted Need Food Requests',style: AppColor.bebasstylesubheading(),),
        ),
        body: acceptneedFoodRequestList(), // Widget to display food requests
      ),
    );
  }
}

class acceptneedFoodRequestList extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

   acceptneedFoodRequestList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('need_requests')
          .where('userEmail', isEqualTo: _auth.currentUser!.email)
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
        return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot doc = snapshot.data!.docs[index];

              return Padding(
                padding: const EdgeInsets.only(top:12),
                child: ListTile(
                  tileColor: AppColor.appbarColor,
                  title: Text(
                    "Need For: ${doc['foodTitle']}",
                    style: AppColor.bebasstyle(),
                  ),
                  subtitle: Text(
                    "Desc: ${doc['foodDescription']}",
                    style: AppColor.bebasstyle(),
                  ),
                  trailing: Text(
                    "Receiver: ${doc['NgoEmail']}",
                    style: AppColor.bebasstyle(),
                  ),
                  leading: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                    receiverUserEmail: doc['NgoEmail'],
                                    receiverUserId: doc['NgoId'])));
                      },
                      icon: const Icon(Icons.chat,color: AppColor.subheadingColor,)),
                ),
              );
            });
      },
    );
  }
}
