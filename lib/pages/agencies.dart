import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:url_launcher/url_launcher.dart';

class Agencies extends StatefulWidget {
  const Agencies({super.key});

  @override
  State<Agencies> createState() => _AgenciesState();
}

class _AgenciesState extends State<Agencies> {
  List<String> numbers = [
    "04222300101",
    "04259223333",
    "04222450101",
    "04253222444",
    "04254222299"
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("1"),
              IconButton(
                  onPressed: () {
                    launchUrl(Uri.parse("tel:${numbers[0]}"));
                  },
                  icon: Icon(Icons.call)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("2"),
              IconButton(
                  onPressed: () {
                    launchUrl(Uri.parse("tel:${numbers[1]}"));
                  },
                  icon: Icon(Icons.call)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("3"),
              IconButton(
                  onPressed: () {
                    launchUrl(Uri.parse("tel:${numbers[2]}"));
                  },
                  icon: Icon(Icons.call)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("4"),
              IconButton(
                  onPressed: () {
                    launchUrl(Uri.parse("tel:${numbers[3]}"));
                  },
                  icon: Icon(Icons.call)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("5"),
              IconButton(onPressed: () {}, icon: Icon(Icons.call)),
            ],
          ),
        ]),
      ),
    ));
  }
}
