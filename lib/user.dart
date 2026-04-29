import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  TextEditingController username = TextEditingController();
  TextEditingController age = TextEditingController();

  void saveData() async {
    try {
      await FirebaseFirestore.instance.collection('users').add({
        'name': username.text,
        'age': double.parse(age.text),
        'timestamp': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data added successfully!')),
      );
      username.clear();
      age.clear();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 300,
            ),
            TextField(
              controller: username,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: "Name"),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
                controller: age,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "Age")),
            MaterialButton(
              onPressed: saveData,
              color: Colors.black,
              textColor: Colors.white,
              child: Text("SUBMIT"),
            )
          ],
        ),
      ),
    );
  }
}
