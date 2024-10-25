import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foods_rescue/Utils/appcolors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserId;

  const ChatScreen({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late ChatProvider chatProvider;
  final ScrollController _scrollController = ScrollController();
  List<QueryDocumentSnapshot> allMessages = [];
  bool _loadingMoreMessages = false;
  DocumentSnapshot? _lastVisibleMessage;

  @override
  void initState() {
    super.initState();
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _scrollController.addListener(_scrollListener);
    loadInitialMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    if (messageController.text.isNotEmpty) {
      await chatProvider.sendMessage(
        messageController.text,
        widget.receiverUserId,
      );
      messageController.clear();
    }
  }

  void loadInitialMessages() {
    chatProvider
        .getMessagesPagination(
      _firebaseAuth.currentUser!.uid,
      widget.receiverUserId,
      null,
    )
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          allMessages = snapshot.docs;
        });
      }
    });
  }

  void loadMoreMessages() {
    if (_loadingMoreMessages) {
      return;
    }

    setState(() {
      _loadingMoreMessages = true;
    });

    chatProvider
        .getMessagesPagination(
      _firebaseAuth.currentUser!.uid,
      widget.receiverUserId,
      allMessages.isEmpty ? null : allMessages.last,
    )
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          allMessages.addAll(snapshot.docs);
          _lastVisibleMessage = snapshot.docs.last;
          _loadingMoreMessages = false;
          print('load old message');
        });
      } else {
        setState(() {
          _loadingMoreMessages = false;
        });
      }
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      loadMoreMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:  GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back,color: AppColor.subheadingColor,)),
        backgroundColor: AppColor.appbarColor,
        title: Text(widget.receiverUserEmail,style: const TextStyle(color: AppColor.subheadingColor),),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Stack(
      children: [
        ListView.builder(
          reverse: true,
          controller: _scrollController,
          itemCount: allMessages.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(allMessages[index]);
          },
        ),
        if (_loadingMoreMessages)
          const Center(
            child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Colors.green,
                  strokeWidth: 5,
                )), // Loading indicator
          ),
      ],
    );
  }

  Widget _buildMessageItem(QueryDocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    var clr = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Colors.green
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: alignment,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['senderEmail'],
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            data['timestamp'],
            style: TextStyle(
              color: clr,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: clr,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                data['message'],
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

///provider for state management
class ChatProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String message, String receiverId) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final timestamp = Timestamp.now();
    String formattedTimestamp =
        DateFormat('dd-MM-yyyy HH:mm:ss.SSS').format(timestamp.toDate());

    Message newMessage = Message(
      message: message,
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      timestamp: formattedTimestamp,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
    print("Message sent: $message");
  }

  Stream<QuerySnapshot> getMessagesPagination(
    String userId,
    String otherUserId,
    DocumentSnapshot? startAfter,
  ) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoom = ids.join("_");
    Query query = _firestore
        .collection('chat_rooms')
        .doc(chatRoom)
        .collection('messages')
        .orderBy('timestamp', descending: true);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.limit(10).snapshots();
  }
}

///send message model
class Message {
  final String message;
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String timestamp;

  Message(
      {required this.message,
      required this.senderId,
      required this.senderEmail,
      required this.receiverId,
      required this.timestamp});

  ///convert To map
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'timestamp': timestamp,
    };
  }
}
