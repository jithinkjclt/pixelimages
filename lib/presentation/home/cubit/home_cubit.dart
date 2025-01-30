import 'dart:io';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:imagelister/data/model/model.dart';
import 'package:meta/meta.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../../data/Strings/api_key.dart';
import '../../../data/Strings/urls.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this.context) : super(HomeInitial()) {
    getAllImages();
  }

  BuildContext context;
  String apiKey = Environment.apiKey;

  int currentPage = 10;
  List<Photo> allImages = [];
  List <Photo> revesreImages = [];

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

  reversing() {
    revesreImages = allImages.reversed.toList();
    emit(HomeLoaded(images:revesreImages ));
  }

  Future<void> getAllImages({int page = 1}) async {
    emit(HomeLoading());
    final url = Uri.parse('$baseUrl/curated?page=$page&per_page=$currentPage');
    try {
      final response = await http.get(url, headers: {'Authorization': apiKey});

      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> dataMap = jsonDecode(response.body);
        final data = Imagemodel.fromJson(dataMap);
        allImages.addAll(data.photos!);
        emit(HomeLoaded(images: allImages));
        // reversing();
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
        Dio dio = Dio();

        Directory? directory = await getExternalStorageDirectory();
        if (directory == null) {
          Fluttertoast.showToast(
              msg: 'Failed to get external storage directory.');
          return;
        }

        String filePath =
            '/storage/emulated/0/Download/downloaded_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

        await dio.download(imageUrl, filePath,
            onReceiveProgress: (received, total) {
          if (total != -1) {}
        });

        const MethodChannel('com.example.app/refreshGallery')
            .invokeMethod('refreshGallery', filePath);

        Fluttertoast.showToast(msg: "Image downloaded successfully!");
      } catch (e) {
        Fluttertoast.showToast(msg: "Error downloading image: $e");
      }
    } else {
      Fluttertoast.showToast(
          msg: "Permission denied. Please enable storage access.");
    }
  }
}
