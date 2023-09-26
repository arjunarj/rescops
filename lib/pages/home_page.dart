// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:skanmed/pages/agencies.dart';
import 'package:skanmed/pages/map_display.dart';
import 'package:skanmed/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState;
  }

  final screens = [
    MapDisp(),
    Agencies(),
    Center(child: Text("weather")),
    ProfilePage()
  ];
  bool isTrue = false;
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBar(
          onDestinationSelected: (index) => setState(() {
                this.index = index;
              }),
          selectedIndex: index,
          destinations: [
            NavigationDestination(icon: Icon(Icons.map), label: "Home"),
            NavigationDestination(icon: Icon(Icons.shield), label: "Agencies"),
            NavigationDestination(
                icon: Icon(Icons.sunny_snowing), label: "Weather"),
            NavigationDestination(icon: Icon(Icons.person), label: "User"),
          ]),
    );
  }
}
