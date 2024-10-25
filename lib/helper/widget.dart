// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

Widget myText(String txt, color, double size, font) {
  return Text(
    txt,
    style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: font,
        overflow: TextOverflow.ellipsis),
  );
}

class Dropdown extends StatefulWidget {
  const Dropdown({super.key});

  @override
  _DropdownState createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
// Initial Selected Value
  String dropdownvalue = 'BLV';

// List of items in our dropdown menu
  var items = [
    'BLV',
    'USDB',
    'USDT',
    'BUSD',
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      width: 160,
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Colors.amber),
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
      child: Center(
        child: Column(
          children: [
            DropdownButton(
              // Initial Value
              value: dropdownvalue,

              // Down Arrow Icon
              icon: const Icon(Icons.keyboard_arrow_down),

              // Array list of items
              items: items.map((String items) {
                return DropdownMenuItem(
                  value: items,
                  child: Text(items),
                );
              }).toList(),
              // After selecting the desired option,it will
              // change button value to selected value
              onChanged: (String? newValue) {
                setState(() {
                  dropdownvalue = newValue!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

//   Navigator.of(context)
//                                           .push(MaterialPageRoute(
//                                         builder: (context) => Teamlevel(),
//                                       ));

// //  RichText(
//                     text: TextSpan(
//                       text: 'Hello,',
//                       style: TextStyle(color: Colors.black, fontSize: 18.0),
//                       children: <TextSpan>[
//                         TextSpan(
//                             text: 'how are you?',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                             )),
//                       ],
//                     ),
//                   ),

//  Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const Forgetpassword()));

void showCustomSnackbar(BuildContext context, String txt) {
  final snackBar = SnackBar(
    padding: EdgeInsets.all(10),
    elevation: 1,
    // showCloseIcon: true,

    content: Row(
      children: <Widget>[
        Icon(
          Icons.check_circle,
          color: Colors.green,
        ),
        SizedBox(width: 10),
        Text(
          txt,
          style: TextStyle(fontSize: 16),
          overflow: TextOverflow.fade,
        ),
      ],
    ),
    duration: const Duration(
        seconds: 2), // Duration for which the snackbar will be displayed
    backgroundColor: Colors.blueGrey, // Background color of the snackbar
    behavior: SnackBarBehavior
        .floating, // SnackBarBehavior can be floating, fixed, or sliding
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ), // Custom shape for the snackbar
    action: SnackBarAction(
      label: 'Action',
      onPressed: () {
        // Perform an action when the action button is clicked
      },
    ),
  );

  // Show the snackbar
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showalertSnackbar(BuildContext context, String txt) {
  final snackBar = SnackBar(
    padding: EdgeInsets.all(10),
    elevation: 1,
    // showCloseIcon: true,

    content: Row(
      children: <Widget>[
        Icon(
          Icons.cancel,
          color: Colors.amber,
        ),
        SizedBox(width: 10),
        Text(
          txt,
          style: TextStyle(fontSize: 16),
          overflow: TextOverflow.fade,
        ),
      ],
    ),
    duration: const Duration(
        seconds: 2), // Duration for which the snackbar will be displayed
    backgroundColor: Colors.red, // Background color of the snackbar
    behavior: SnackBarBehavior
        .floating, // SnackBarBehavior can be floating, fixed, or sliding
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ), // Custom shape for the snackbar
    action: SnackBarAction(
      label: 'Action',
      onPressed: () {
        // Perform an action when the action button is clicked
      },
    ),
  );

  // Show the snackbar
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

// class TransactionListWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final transactions = Provider.of<MyProvider>(context).transactions;

//     return ListView.builder(
//       itemCount: transactions.length,
//       itemBuilder: (context, index) {
//         final transaction = transactions[index];
//         return ListTile(
//           title: Text(transaction.trxDetail),
//           subtitle: Text('${transaction.trxAmount.toStringAsFixed(2)} coins'),
//           trailing: Text(transaction.createdAt.toIso8601String()),
//         );
//       },
//     );
//   }
// }



//cupertino dilalog
  // showDialog(
  //         context: context,
  //         builder: (context) {
  //           return CupertinoAlertDialog(
  //             title: const Text('Login Sucessfully'),
  //             content:
  //                 const Text('Please verfiy Your Email adress and sign in'),
  //             actions: [
  //               // The "Yes" button
  //               // CupertinoDialogAction(
  //               //   onPressed: () {
  //               //     Navigator.pushReplacement(
  //               //         context,
  //               //         MaterialPageRoute(
  //               //             builder: (context) => SignInsecreen()));
  //               //   },
  //               //   isDefaultAction: true,
  //               //   isDestructiveAction: true,
  //               //   child: const Text('Sign In'),
  //               // ),
  //               // The "No" button
  //               CupertinoDialogAction(
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 isDefaultAction: false,
  //                 isDestructiveAction: false,
  //                 child: const Text('OK'),
  //               )
  //             ],
  //           );
  //         },
  //       );
