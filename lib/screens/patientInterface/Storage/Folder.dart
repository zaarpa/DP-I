import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/patientInterface/Storage/Upload.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../BookAppointment/doctorFinderPage.dart';
import 'FileViewer.dart';

class NewFolder extends StatefulWidget {
  final String folderName;

  const NewFolder({Key? key, required this.folderName}) : super(key: key);

  @override
  State<NewFolder> createState() => _NewFolderState();
}

class _NewFolderState extends State<NewFolder> {

  String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';
  bool doesCollectionExist = false;
  late Future<QuerySnapshot> collectionSnapshot;
   List<Map<String, dynamic>> allFilesData=[];
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  List<Map<String,dynamic>> fileData =[];

  @override
  void initState(){
    super.initState();
    getFiles();
  }

  Future<void> getFiles() async {
    try {
      QuerySnapshot filesSnapshot = await FirebaseFirestore.instance
          .collection('Documents')
          .doc('Reports and Prescriptions')
          .collection(userUID)
          .doc(widget.folderName)
          .collection('Files')
          .get();

      if (filesSnapshot.docs.isNotEmpty) {
        allFilesData = filesSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        setState(() {

        });

        // Print data for debugging
        for (var data in allFilesData) {
          print('File Data: $data');
        }

        print('All Files Data: $allFilesData');
      } else {
        print('No documents found in the Files subcollection.');
      }
    } catch (e) {
      print('Error retrieving files data: $e');
    }
  }
  void pickFileForFolder() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'doc','img','png','jpg'],
    );

    if (pickedFile != null) {
      String originalFileName = pickedFile.files[0].name;
      String userID = userUID;


      File file = File(pickedFile.files[0].path!);
      final downloadLink = await uploadFile(originalFileName, file);

      _firebaseFirestore.collection("Documents").
      doc('Reports and Prescriptions')
          .collection(userUID)
          .doc(widget.folderName)
          .collection('Files').add({
        "name": originalFileName,
        "URL": downloadLink,
      });

      print("File UPLOADED SUCCESSFULLY");

      Fluttertoast.showToast(
        msg: 'File Uploaded',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DoctorFinder()),
      );
    }
  }



  Future<String?> uploadFile(String fileName, File file) async{

    final reference = FirebaseStorage.instance.ref().child("Reports and Prescriptions/$fileName.pdf");

    final uploadTask = reference.putFile(file);

    await uploadTask.whenComplete(() => {});

    final downloadLink = await reference.getDownloadURL();

    return downloadLink;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(widget.folderName),
        ),
      ),
      body:  Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white70, Colors.blue.shade100],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            allFilesData.isEmpty
                ? Expanded(
              child: Container(
                padding: EdgeInsets.all(16.0),
                alignment: Alignment.center,
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                                          'Upload your files',
                          style: TextStyle(fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade700,),
                          textAlign: TextAlign.center,),
                      ),
                    ],),
                ),
              ),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: allFilesData.length,
                itemBuilder: (context, index) {
                  if (index < allFilesData.length) {
                  // Display file data
                  String fileName = allFilesData[index]['name'];
                  String fileURL = allFilesData[index]['URL'];
                  return

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onDoubleTap: () {
                          print('Tapped on file: $fileName, URL: $fileURL');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FileViewer(URL: fileURL),
                            ),
                          );
                        },
                        onLongPress: () {
                          _showDeleteConfirmationDialog(allFilesData[index]['name']);
                        },
                        child: Card(
                          color: Colors.white,
                          child: ListTile(
                            leading: Icon(Icons.file_copy),
                            title: Text(
                              allFilesData[index]['name'],
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    );



                  }
                  },
              ),
            ),
          ],
        ),
      ),


        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[

                      ListTile(
                        leading: Icon(Icons.file_upload),
                        title: Text('Upload a File'),
                        onTap: () {
                          pickFileForFolder();
                          Navigator.pop(context);
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => const DoctorFinder()),
                          // );


                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(String fileName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete File'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this file?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                // Perform delete operation
                  deleteFile(fileName);
                Navigator.of(context).pop();
              initState();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteFile(String fileName) async {
    try {
      await _firebaseFirestore
          .collection("Documents")
          .doc('Reports and Prescriptions')
          .collection(userUID)
          .doc(widget.folderName)
          .collection('Files')
          .where("name", isEqualTo: fileName)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {

          await doc.reference.delete();

          String fileURL = doc['URL'];
          Reference storageRef = FirebaseStorage.instance.refFromURL(fileURL);
          await storageRef.delete();
        });
      });

      print("File deletedddddd successfully");
      Fluttertoast.showToast(
        msg: 'File Deleted',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UploadFile()),
      );
    } catch (error) {
      print("Error deleting file: $error");
    }
  }

  // void downloadFile(String fileURL, String fileName) async {
  //   try {
  //     var request = await http.Client().get(Uri.parse(fileURL));
  //     var bytes = request.bodyBytes;
  //
  //     var dir = await getApplicationDocumentsDirectory();
  //     File file = File("${dir.path}/$fileName");
  //
  //     await file.writeAsBytes(bytes);
  //     var dire = await getApplicationDocumentsDirectory();
  //     print('Documentttttttttttttttttttts directory: ${dire.path}');
  //
  //     File fil = File("${dire.path}/$fileName");
  //
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('File downloaded successfully'),
  //     ));
  //   } catch (error) {
  //     print('Error downloading file: $error');
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('Error downloading file'),
  //     ));
  //   }
  // }
}

