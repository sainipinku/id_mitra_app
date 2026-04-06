
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPref {
  static setToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_token', token);
  }
  static setIntroScreen(bool seen) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('seen', seen);
  }
  static setUserFirstName(String exist) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_first_name', exist);
  }
  static setUserLastName(String exist) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_last_name', exist);
  }
  static setUserID(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_id', userId);
  }
  static setProfileImage(String profile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_profile', profile);
  }
  static setUserEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_email', email);
  }
  static setUserPhone(String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_phone', phone);
  }
  static Future<String> getUserID(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? " ";
  }
  static Future<String> getToken(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? " ";
  }
  static Future<String> getProfileImage(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? " ";
  }
  static Future<String> getUserFirstName(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? " ";
  }
  static Future<String> getUserEmail(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? " ";
  }
  static Future<String> getUserLastName(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? " ";
  }
  static Future<String> getUserPhone(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? " ";
  }
  static removeAll() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}