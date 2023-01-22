//class with functions for getting api requests from openai api

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secrets.dart';
import 'decor.dart';
// ignore: depend_on_referenced_packages
import 'package:gallery_saver/gallery_saver.dart';

class Controller {
  //function to get api request
  static Future<String> getApiRequest({required String prompt}) async {
    //api request
    try {
      var response = await http.post(
          Uri.parse('https://api.openai.com/v1/images/generations'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey'
          },
          body: jsonEncode({
            "prompt": prompt,
            "n": 1,
            "size": '1024x1024',
          }));
      final decodedResponse = json.decode(response.body);
      return decodedResponse['data'][0]['url'];
    } catch (e) {
      print("ERROR: $e");
      return "error"; //implememt further error handling
    }
  }

  static Future<void> download({required String url, required context}) async {
    try {
      GallerySaver.saveImage(url);
      Decor.notification(text: "Image Downloaded", context: context);
    } catch (e) {
      print("ERROR: $e"); 
      Decor.notification(text: "Unable to download image", context: context);
    }
  }
}
