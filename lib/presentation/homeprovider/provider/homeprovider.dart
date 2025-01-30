import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../../data/Strings/api_key.dart';
import '../../../data/Strings/urls.dart';
import 'package:imagelister/data/model/model.dart';

class HomeProvider extends ChangeNotifier {
  bool isLoading = false;
  List<Photo> images = [];
  String? errorMessage;
  String apiKey = Environment.apiKey;
  int currentPage = 10;

  HomeProvider() {
    getAllImages();
  }

  Future<void> getAllImages({int page = 1}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final url = Uri.parse('$baseUrl/curated?page=$page&per_page=$currentPage');
    try {
      final response = await http.get(url, headers: {'Authorization': apiKey});

      if (response.statusCode == 200) {
        final Map<String, dynamic> dataMap = jsonDecode(response.body);
        final data = Imagemodel.fromJson(dataMap);
        images.addAll(data.photos!);
      } else {
        throw Exception('Failed to load images: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  void loadMoreImages() {
    currentPage += 10;
    getAllImages(page: currentPage);
  }

  Future<void> requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.status;
    if (!status.isGranted) {
      PermissionStatus newStatus = await Permission.storage.request();
      if (!newStatus.isGranted) {
        Fluttertoast.showToast(
            msg: "Permission denied. Please enable storage access.");
      }
    }
  }

  Future<void> downloadImage(String imageUrl) async {
    await requestStoragePermission();

    PermissionStatus status = await Permission.storage.status;
    if (status.isGranted) {
      try {
        Dio dio = Dio();
        Directory? directory = await getExternalStorageDirectory();
        if (directory == null) {
          Fluttertoast.showToast(
              msg: 'Failed to get external storage directory.');
          return;
        }
        String filePath =
            '/storage/emulated/0/Download/downloaded_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

        await dio.download(imageUrl, filePath);
        Fluttertoast.showToast(msg: "Image downloaded successfully!");
      } catch (e) {
        Fluttertoast.showToast(msg: "Error downloading image: $e");
      }
    }
  }
}
