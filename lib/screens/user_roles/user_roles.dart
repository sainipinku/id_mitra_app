import 'package:flutter/material.dart';
import 'package:idmitra/Widgets/CommonAppBar.dart';



class UserRoles extends StatefulWidget {
  const UserRoles({super.key});

  @override
  State<UserRoles> createState() => _UserRolesState();
}

class _UserRolesState extends State<UserRoles> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: CommonAppBar(title: 'Add New School',backgroundColor: Colors.transparent,),
      body: Padding(padding: EdgeInsets.all(16.0),
      child: Column(
        children: [

        ],
      ),),
    );
  }
}
