import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_firebase_test/read%20data/get_user_name.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  //document IDs
  List<String> docIDs = [];

  //get docIDs
  Future getDocId() async {
    //Before sorting was added
    //await FirebaseFirestore.instance.collection('users').get().then(

    //After adding sorting method
    await FirebaseFirestore.instance
        .collection('users')
        .orderBy(
          'age',
          //highest to lowest
          descending: true,
          //if it's false
          //it goes from lowest to highest
        )
        .get()
        .then(
          (snapshot) => snapshot.docs.forEach(
            (document) {
              print(document.reference);
              docIDs.add(document.reference.id);
            },
          ),
        );
  }

  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            user.email!,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            setState(() {});
          },
          child: Icon(
            Icons.refresh,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
            child: Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: FutureBuilder(
                //waiting for ids
                future: getDocId(),
                builder: (context, snapshot) {
                  return ListView.builder(
                    itemCount: docIDs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            changeOrRemoveUserName(context, index);
                          },
                          child: ListTile(
                            title: GetUserName(
                              documentID: docIDs[index],
                            ),
                            tileColor: Colors.deepOrange[200],
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

  //change or remove user name in firebase storage
  void changeOrRemoveUserName(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change name'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                final docUser = FirebaseFirestore.instance
                    .collection('users')
                    .doc(docIDs[index]);
                docUser.update({
                  'first name': FieldValue.delete(),
                });
                Navigator.pop(context);
                _controller.clear();
              },
              color: Colors.amber,
              child: Text('Remove'),
            ),
            MaterialButton(
              onPressed: () {
                final docUser = FirebaseFirestore.instance
                    .collection('users')
                    .doc(docIDs[index]);
                docUser.update({'first name': _controller.text});
                Navigator.pop(context);
                _controller.clear();
              },
              color: Colors.amber,
              child: Text('Save'),
            ),
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
                _controller.clear();
              },
              color: Colors.amber,
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
