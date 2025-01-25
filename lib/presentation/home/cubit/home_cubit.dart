import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:imagelister/data/model/model.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import '../../../data/Strings/api_key.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this.context) : super(HomeInitial()) {
    getAllImages();
  }

  BuildContext context;
  String apiKey = Environment.apiKey;

  int currentPage = 80;
  List<Photo> allImages = [];

  Future<void> requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.status;

    if (status.isGranted) {
      return;
    } else if (status.isDenied) {
      PermissionStatus newStatus = await Permission.storage.request();

      if (newStatus.isGranted) {
        print("Storage permission granted.");
      } else if (newStatus.isPermanentlyDenied) {
        Fluttertoast.showToast(
            msg: "Please enable storage permission in settings.");
        openAppSettings();
      } else {
        Fluttertoast.showToast(
            msg: "Permission denied. Please enable storage access.");
      }
    } else if (status.isPermanentlyDenied) {
      Fluttertoast.showToast(
          msg: "Please enable storage permission in settings.");
      openAppSettings();
    }
  }

  Future<void> getAllImages({int page = 1}) async {
    emit(HomeLoading());

    final url = Uri.parse(
        'https://api.pexels.com/v1/curated?page=1&per_page=$currentPage');
    try {
      final response = await http.get(url, headers: {'Authorization': apiKey});

      if (response.statusCode == 200) {
        final Map<String, dynamic> dataMap = jsonDecode(response.body);
        final data = Imagemodel.fromJson(dataMap);
        allImages.addAll(data.photos!);
        emit(HomeLoaded(images: allImages));
      } else {
        throw Exception('Failed to load images: ${response.statusCode}');
      }
    } catch (e) {
      emit(HomeError(errorMessage: e.toString()));
    }
  }

  void loadMoreImages() {
    currentPage += 10;
    getAllImages(page: currentPage);
  }

  Future<void> downloadImage(String imageUrl) async {
    await requestStoragePermission();

    PermissionStatus status = await Permission.storage.status;

    if (status.isGranted) {
      try {
        final Uri url = Uri.parse(imageUrl);
        final response = await http.get(url);

        if (response.statusCode == 200) {
          Directory? directory = await getExternalStorageDirectory();

          if (directory != null) {
            String fileName =
                'downloaded_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
            String filePath = '${directory.path}/$fileName';

            File file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);

            Fluttertoast.showToast(msg: "Image downloaded successfully!");
          } else {
            throw 'Failed to get external storage directory.';
          }
        } else {
          throw 'Failed to download image. Status code: ${response.statusCode}';
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Error downloading image: $e");
      }
    } else {
      Fluttertoast.showToast(
          msg: "Permission denied. Please enable storage access.");
    }
  }
}
