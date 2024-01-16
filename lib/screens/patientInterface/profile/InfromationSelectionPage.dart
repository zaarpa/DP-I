import 'package:design_project_1/screens/patientInterface/Storage/Upload.dart';
import 'package:design_project_1/screens/patientInterface/medications/currentPrescription.dart';
import 'package:flutter/material.dart';
import 'package:design_project_1/screens/patientInterface/profile/profile.dart';
import 'package:fluttertoast/fluttertoast.dart';

class InformationSelectionScreen extends StatefulWidget {
  const InformationSelectionScreen({super.key});

  @override
  State<InformationSelectionScreen> createState() => _InformationSelectionScreenState();
}

class _InformationSelectionScreenState extends State<InformationSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blue.shade900,

      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [Colors.white70, Colors.blue.shade100],
          ),
        ),
        child: ListView(

          children: <Widget>[
            ListTile(

              leading: Icon(Icons.account_circle),
              title: Text('Account Information'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.medical_services),
              title: Text('Medications'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CurrentPrescriptionScreen(medicationTime: 'morning',)));
              },
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: Text('Reports and Prescriptions'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadFile()));
              },
            ),

          ],
        ),
      ),



    );
  }
}
