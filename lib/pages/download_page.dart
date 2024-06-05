import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  List<FileSystemEntity> fileContents1 = [];

  Future<List<FileSystemEntity>> loadAllFiles() async {

    log("asfjm");
    final dir = await getTemporaryDirectory();
    final Stream<FileSystemEntity> fileList = dir.list();

    await for (FileSystemEntity entity in fileList) {
      log(entity.path);
      if (entity.path.contains(".mp4") || entity.path.contains(".jpg") || entity.path.contains(".m4a")) {
        log(entity.path);
        fileContents1.add(entity);
      }
    }

    log(fileContents1.length.toString());
    return fileContents1;
  }

  @override
  void initState() {
    loadAllFiles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Downloads'),
        titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 28
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<List<FileSystemEntity>>(
        future: loadAllFiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'), 
            );
          } else {
            List<FileSystemEntity> fileContents = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: fileContents.length,
                    itemBuilder: (_, i){
                      return Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Text(
                            fileContents[i].path,
                            style: const TextStyle(
                                color: Colors.black
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }

}
