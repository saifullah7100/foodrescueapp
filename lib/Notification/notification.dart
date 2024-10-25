import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePagereciver extends StatefulWidget {
  const HomePagereciver({super.key});

  @override
  _HomePagereciverState createState() => _HomePagereciverState();
}

class _HomePagereciverState extends State<HomePagereciver> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late FlutterLocalNotificationsPlugin _localNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    // Initialize local notifications
    _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // App icon
    const iosSettings = DarwinInitializationSettings();
    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse:
          _onSelectNotification, // Correct parameter for handling notification taps
    );

    _listenForNewFoodUploads(); // Set up the listener for new food uploads
  }

  Future<void> _onSelectNotification(NotificationResponse response) async {
    final payload = response.payload;
    if (payload != null) {
      print('Notification payload: $payload');
      // Handle what happens when the user taps on the notification
      // Example: navigate to a specific screen or show more details
    }
  }

  void _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'food_upload_channel',
      'Food Uploads',
      importance: Importance.max,
      priority: Priority.max,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      platformDetails,
      payload: 'New Food Upload', // Optional payload
    );
  }

  void _listenForNewFoodUploads() {
    FirebaseFirestore.instance
        .collection('foods')
        .snapshots() // Listen to the 'foods' collection
        .listen((snapshot) {
      final newFood = snapshot.docChanges
          .where((change) => change.type == DocumentChangeType.added)
          .firstOrNull; // Detect new documents

      if (newFood != null) {
        final doc = newFood.doc.data()!;
        final title = doc['title'] ?? 'New Food Item';
        final description =
            doc['description'] ?? 'A new food item was uploaded.';

        _showNotification(title, description);
      }
    });
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('foods')
          .doc(documentId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting document: $e')),
      );
    }
  }

  Future<void> acceptFood(
      String documentId, DocumentSnapshot foodDoc, String donorEmail) async {
    try {
      // Update the document to indicate acceptance
      await FirebaseFirestore.instance
          .collection('foods')
          .doc(documentId)
          .update({'accepted': true});

      // Record the acceptance in another collection if needed
      await FirebaseFirestore.instance.collection('food_requests').add({
        'donorEmail': donorEmail,
        'donorId': foodDoc['userid'],
        'foodTitle': foodDoc['title'],
        'foodDescription': foodDoc['description'],
        'userEmail': _auth.currentUser!.email,
        'userId': _auth.currentUser!.uid,
        // Add more relevant data if needed
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food accepted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting food: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Food Available"),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('foods')
              .where('accepted', isEqualTo: false)
              .snapshots(), // StreamBuilder listens for new data
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
      
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                mainAxisExtent: 260,
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                return _buildFoodCard(context, doc); // Build each card
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFoodCard(BuildContext context, DocumentSnapshot doc) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color(0xffE9E4fc),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 85,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              image: DecorationImage(
                image: NetworkImage(doc['imageUrl']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Title: ${doc['title']}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  "Desc: ${doc['description']}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showDonorDetails(context, doc['useremail'],
                        doc['location'], doc['phone']);
                  },
                  child: const Text("Donor Detail"),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _auth.currentUser!.email != doc['useremail']
                  ? ElevatedButton(
                      onPressed: () {
                        // Accept the food item
                        acceptFood(doc.id, doc, doc['useremail']);
                      },
                      child: const Text("Accept Food"),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        // Delete the document
                        deleteDocument(doc.id);
                      },
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDonorDetails(
      BuildContext context, String email, String location, String phone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Donor Details"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Email: $email"),
              Text("Location: $location"),
              Text("Phone: $phone"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
