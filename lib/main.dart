// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:otp/otp.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2FA Code Generator',
      home: TOTPCodes(),
      theme: ThemeData(
        primaryColor: Colors.yellow,
      ),
    );
  }
}

class TOTPCodes extends StatefulWidget {
  @override
  TOTPCodeState createState() => TOTPCodeState();
}

class TOTPCodeState extends State<TOTPCodes> with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  final _codes = [
    TOTPCode("JBSWY3DPEHPK3PXP", "CPR Ben GSuite"),
    TOTPCode("a0w89ef", "Facebook"),
    TOTPCode("tlkasdf", "Bastion"),
    TOTPCode("key", "PCI"),
  ];

  double _timerProgress = 1.0;

  @override
  void initState() {
    super.initState();

    var now = new DateTime.now();
    _startTimer(Duration(seconds: 30 - now.second % 30));
  }

  void _startTimer(Duration d) {
    controller = AnimationController(duration: d, vsync: this);
    controller.addListener(() {
      setState(() {
        _timerProgress = controller.value;
      });
    });
    controller.forward();

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _startTimer(const Duration(seconds: 30));
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('2FA Code Generator'),
        ),
        body: Column(
          children: [
            LinearProgressIndicator(value: 1.0 - _timerProgress),
            Expanded(
              child: ListView(
                children: ListTile.divideTiles(
                  context: context,
                  tiles: _codes.map((TOTPCode code) {
                    return ListTile(
                      title: Text(code.name),
                      leading: Icon(
                        Icons.favorite,
                        color: Colors.pink,
                        size: 40,
                      ),
                      trailing: Text(
                        code.code().toString(),
                        style: TextStyle(fontSize: 40),
                      ),
                      onTap: () {},
                    );
                  }),
                ).toList(),
              ),
            )
          ],
        )
    );
  }
}

class TOTPCode {
  String key;
  String name;

  TOTPCode(this.key, this.name) {}

  int code() {
    return OTP.generateTOTPCode(key, DateTime.now().millisecond);
  }
}
