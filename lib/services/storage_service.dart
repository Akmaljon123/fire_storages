import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService{
  static final storage = FirebaseStorage.instance;

  static Future<String>upload({required String path, required File file})async{
    Reference reference = storage.ref(path).child("${DateTime.now().toLocal().toIso8601String()}${file.path.substring(file.path.lastIndexOf("."))}");
    UploadTask task = reference.putFile(file);
    await task.whenComplete((){});
    return reference.getDownloadURL();
  }

  static Future<(List<String>, List<String>)> getData(String path)async{
    List<String> linkList = [];
    List<String> nameList = [];

    final reference = storage.ref(path);
    final ListResult listResult = await reference.listAll();

    for (var e in listResult.items) {
      linkList.add(await e.getDownloadURL());
      nameList.add(e.name);
    }

    if(path=="music"){
      log("Log: ${nameList.length}");
    }

    return (nameList, linkList);
  }

  static Future<void> delete(String url)async{
    final Reference reference = storage.refFromURL(url);
    await reference.delete();
  }
}

