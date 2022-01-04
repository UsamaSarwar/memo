import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memo/Controller/controller.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Controller _controller = Get.put(Controller());
  final _memoCollection =
      FirebaseFirestore.instance.collection('Memo Collection');
  // Form key (For Validation)
  final GlobalKey<FormState> key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memo Pro',
        style: GoogleFonts.handlee(),),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.pink,
                Colors.red,
                Colors.redAccent,
              ],
            ),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: Image.asset(
        //       'assets/memo.png',
        //     ),
        //   )
        // ],
      ),

      // Get list of memo from firebase
      body: StreamBuilder<QuerySnapshot>(
        stream: _memoCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            // reverse: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: Key(snapshot.data!.docs[index].id),
                onDismissed: (direction) =>
                    _memoCollection.doc(snapshot.data!.docs[index].id).delete(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                  child: Card(
                    elevation: 4,
                    // Round edge
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      leading: SizedBox(
                        height: 30,
                        width: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.pink,
                                Colors.red,
                                Colors.redAccent,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              index.toString(),
                              style: GoogleFonts.handlee(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      title: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(snapshot.data!.docs[index]['memo'],
                        style: GoogleFonts.handlee(),),
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.date_range_rounded,
                                  size: 15, color: Colors.grey),
                              SizedBox(width: 5),
                              Text(
                                snapshot.data!.docs[index]['date'],
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.insert_drive_file,
                                  size: 15, color: Colors.grey),
                              SizedBox(width: 5),
                              Text(
                                snapshot.data!.docs[index].id,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.close_rounded, color: Colors.grey),
                        onPressed: () {
                          _memoCollection
                              .doc(snapshot.data!.docs[index].id)
                              .delete();
                        },
                      ),
                      onTap: () {
                        // Create Form
                        Get.dialog(
                          AlertDialog(
                            // title: Text('Edit Memo'),
                            content: Form(
                              key: key,
                              child: TextFormField(
                                style: GoogleFonts.handlee(),
                                maxLines: 5,
                                initialValue: snapshot.data!.docs[index]
                                    ['memo'],
                                onChanged: (value) {
                                  _memoCollection
                                      .doc(snapshot.data!.docs[index].id)
                                      .update({'memo': value});
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Form(
                  key: key,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        style: GoogleFonts.handlee(),
                        maxLines: 5,
                        decoration: InputDecoration(labelText: 'Memo',labelStyle: GoogleFonts.handlee()),
                        validator: (_val) {
                          if (_val!.isEmpty) {
                            return '*Required';
                          } else {
                            return null;
                          }
                        },
                        onChanged: (_val) {
                          _controller.memo.value = _val;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ElevatedButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.add),
                              Text("Add Memo"),
                            ],
                          ),
                          onPressed: () {
                            if (key.currentState!.validate()) {
                              // _controller.memoList.add(_controller.memo.value);
                              key.currentState!.save();
                              Get.back();
                              // Add to Firestore
                              _memoCollection.add({
                                'memo': _controller.memo.value,
                                'date':
                                    '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                              });
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}