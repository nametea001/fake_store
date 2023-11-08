// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class NetworkHelper {
  String prefixUrl = "fakestoreapi.com";
  // String apiPath = "/api/";
  final String url;
  final Map<String, String> params;

  NetworkHelper(this.url, this.params);

  Future getData() async {
    try {
      http.Response response = await http.get(
        Uri.http(prefixUrl, url, params),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        String data = response.body;
        return jsonDecode(data);
      } else {
        String data = response.body;
        return jsonDecode(data);
      }
    } catch (e) {
      print(e);
    }
  }

  Future postData(String jsonData) async {
    try {
      http.Response response = await http
          .post(
            Uri.http(prefixUrl, url, params),
            headers: {"Content-Type": "application/json"},
            body: jsonData,
          )
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        String data = response.body;
        return jsonDecode(data);
      } else {
        String data = response.body;
        return jsonDecode(data);
      }
    } catch (e) {
      print(e);
    }
  }

  Future putData(String jsonData) async {
    try {
      http.Response response = await http
          .put(
            Uri.http(prefixUrl, url, params),
            headers: {"Content-Type": "application/json"},
            body: jsonData,
          )
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        String data = response.body;
        return jsonDecode(data);
      } else {
        String data = response.body;
        return jsonDecode(data);
      }
    } catch (e) {
      print(e);
    }
  }

  Future deleteData() async {
    try {
      http.Response response = await http.delete(
        Uri.http(prefixUrl, url, params),
        headers: {"Content-Type": "application/json"},
      ).timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        String data = response.body;
        return jsonDecode(data);
      } else {
        String data = response.body;
        return jsonDecode(data);
      }
    } catch (e) {
      print(e);
    }
  }
}
