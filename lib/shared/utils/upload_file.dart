import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:wallpaper_app/configs/app_logger.dart';
import 'package:wallpaper_app/configs/enums.dart';

Future<UploadDocResultModel> uploadDocumentToServer(String docPath) async {
  UploadTask uploadTask;

  final docName = docPath.split('/').last;

  appLogger("Uploading document to server");

  try {
    Reference ref = FirebaseStorage.instance.ref().child('images').child('/$docName');

    uploadTask = ref.putFile(File(docPath));

    TaskSnapshot snapshot = await uploadTask.whenComplete(() => appLogger("Task completed"));

    final downloadUrl = await snapshot.ref.getDownloadURL();

    return Future.value(UploadDocResultModel(state: ViewState.success, fileUrl: downloadUrl));
  } on FirebaseException catch (error) {
    appLogger("F-Error uploading image : $error");

    return Future.value(UploadDocResultModel(state: ViewState.error, fileUrl: 'F-Error uploading image'));
  } catch (error) {
    appLogger("Error uploading image : $error");

    return Future.value(UploadDocResultModel(state: ViewState.error, fileUrl: 'Error uploading image'));
  }
}

class UploadDocResultModel {
  final ViewState state;
  final String fileUrl;
  UploadDocResultModel({required this.state, required this.fileUrl});
}
