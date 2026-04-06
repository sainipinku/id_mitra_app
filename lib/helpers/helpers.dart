import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';


import 'keyboard.dart';

class Helpers {
  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }
  bool isValidGST(String gst) {
    final gstRegex = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
    );
    return gstRegex.hasMatch(gst.toUpperCase());
  }
  bool isValidWebsite(String url) {
    final websiteRegex = RegExp(
      r'^(https?:\/\/)?([\w\-]+\.)+[a-zA-Z]{2,}(\/\S*)?$',
    );
    return websiteRegex.hasMatch(url);
  }



}
