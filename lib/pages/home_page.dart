import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fire_storages/pages/download_page.dart';
import 'package:fire_storages/services/storage_service.dart';
import 'package:fire_storages/services/util_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AssetEntity>? selectedAssets;
  Future<ListResult>? futureFiles;
  late VideoPlayerController controller;
  String url = "";
  bool isVideo = false;
  bool isPause= false;
  late Future<void> initializeVideoPlayerFuture;
  File? file;
  bool isLoading = false;
  String filePath = "";
  (List<String>, List<String>) mainListVideo = ([],[]);
  List<String> nameListVideo = [];
  List<String> linkListVideo = [];
  (List<String>, List<String>) mainListPicture = ([],[]);
  List<String> nameListPicture = [];
  List<String> linkListPicture = [];
  (List<String>, List<String>) mainListMusic = ([],[]);
  List<String> nameListMusic = [];
  List<String> linkListMusic = [];
  (List<String>, List<String>) mainListPDF = ([],[]);
  List<String> nameListPDF = [];
  List<String> linkListPDF= [];

  Future<void> loadDataVideo()async{
    isLoading = true;
    setState(() {});
    mainListVideo = await StorageService.getData("video");
    nameListVideo = mainListVideo.$1;
    linkListVideo = mainListVideo.$2;
    isLoading = false;
    setState(() {});
  }

  Future<void> loadDataPDF()async{
    isLoading = true;
    setState(() {});
    mainListPDF = await StorageService.getData("PDF");
    nameListPDF = mainListPDF.$1;
    linkListPDF = mainListPDF.$2;
    isLoading = false;
    setState(() {});
  }

  Future<void> loadDataMusic()async{
    isLoading = true;
    setState(() {});
    mainListMusic = await StorageService.getData("music");
    nameListMusic = mainListMusic.$1;
    linkListMusic = mainListMusic.$2;
    isLoading = false;
    setState(() {});
  }

  Future<void> loadDataPicture()async{
    isLoading = true;
    setState(() {});
    mainListPicture = await StorageService.getData("image");
    nameListPicture = mainListPicture.$1;
    linkListPicture = mainListPicture.$2;
    isLoading = false;
    setState(() {});
  }

  Future<void> pickAssets() async {
    final List<AssetEntity>? resultList = await AssetPicker.pickAssets(
      context,
    );

    if (resultList != null) {
      setState(() {
        selectedAssets = resultList;
      });
    }
  }

  Future<void> openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        filePath = result.files.single.path!;
      });
      file = File(filePath);
    }
  }

  Future<void> loadVideo(String path) async {
    isVideo = false;
    setState(() {

    });
    controller = VideoPlayerController.networkUrl(Uri.parse(path));
    initializeVideoPlayerFuture = controller.initialize().then(
        (_){
          controller.play();
          controller.setLooping(true);
          setState(() {

          });
        }
    );

    isVideo = true;
    setState(() {

    });
  }

  Future<void> download(String path, String name)async{
    try {
      final dir = await getTemporaryDirectory();
      final filePath = "${dir.path}/$name";
      final file = File(filePath);

      if (await file.exists()) {
        log('File already exists');
        Utils.fireSnackBar("File already exists", context);
        return;
      }

      final response = await http.get(Uri.parse(path));

      if (response.statusCode == 200) {

        await file.writeAsBytes(response.bodyBytes);
        log('File downloaded successfully');
        Utils.fireSnackBar("File downloaded successfully", context);
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      log('Error downloading file: $e');
    }
  }




  @override
  void initState() {
    loadDataVideo();
    loadDataMusic();
    loadDataPDF();
    loadDataPicture();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)=>const DownloadPage()
                  )
              );
            },
            icon: const Icon(
              Icons.download,
              color: Colors.white,
              size: 26,
            ),
          ),
          backgroundColor: Colors.black,
          title: const Text('App'),
          titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 28
          ),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.play_arrow),
                text: 'Video',
              ),

              Tab(
                  icon: Icon(Icons.picture_as_pdf),
                  text: 'PDF'
              ),

              Tab(
                  icon: Icon(Icons.image),
                  text: 'Picture'
              ),

              Tab(
                  icon: Icon(Icons.music_note),
                  text: 'Music'
              ),
            ],
          ),
        ),
        body: isLoading ? const Center(
          child: CircularProgressIndicator(),
        ) : TabBarView(
          children: [
            Column(
              children: <Widget>[
                Row(
                  children: [
                    const SizedBox(width: 20),

                    const Text(
                      "Video",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24
                      ),
                    ),

                    const SizedBox(width: 260),

                    IconButton(
                        onPressed: ()async{
                          await pickAssets();
                          final file1 = await selectedAssets![0].file;

                          isLoading = true;
                          setState(() {

                          });
                          await StorageService.upload(
                              path: "video",
                              file: file1!
                          );
                          await loadDataVideo();
                          isLoading = false;
                          setState(() {

                          });
                        },
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        )
                    )
                  ],
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    itemCount: nameListVideo.length,
                    itemBuilder: (_, index) {
                      return Card(
                        color: Colors.grey.shade900,
                        child: ListTile(
                          leading: IconButton(
                            onPressed: () async {
                              await loadVideo(linkListVideo[index]);
                              if(context.mounted){
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    double aspectRatio = controller.value.aspectRatio;
                                    double height = MediaQuery.of(context).size.width;
                                    double width = height / aspectRatio;

                                    return Dialog(
                                      backgroundColor: Colors.black,
                                      child: WillPopScope(
                                        onWillPop: () async {
                                          controller.dispose();
                                          return true;
                                        },
                                        child: SizedBox(
                                          width: width,
                                          height: height,
                                          child: Column(
                                            children: [
                                              AspectRatio(
                                                aspectRatio: aspectRatio,
                                                child: VideoPlayer(controller),
                                              ),

                                              IconButton(
                                                  onPressed: ()async{
                                                    isPause = !isPause;
                                                    isPause ? await controller.play() : await controller.pause();
                                                    setState(() {});
                                                  },
                                                  icon: Icon(
                                                    isPause ? Icons.play_arrow : Icons.pause,
                                                    color: Colors.white,
                                                    size: 28,
                                                  )
                                              )
                                            ],
                                          ),
                                        ),
                                      ),

                                    );
                                  },
                                );

                              }
                            },
                            icon: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          title: Text(
                            nameListVideo[index],
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: ()async{
                              await download(linkListVideo[index], nameListVideo[index]);
                            },
                            icon: const Icon(
                              Icons.download,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 20),

                    const Text(
                      "PDF",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24
                      ),
                    ),

                    const SizedBox(width: 260),

                    IconButton(
                        onPressed: ()async{
                          await openFilePicker();

                          isLoading = true;
                          setState(() {

                          });
                          await StorageService.upload(
                              path: "PDF",
                              file: file!
                          );
                          await loadDataPDF();
                          isLoading = false;
                          setState(() {

                          });
                        },
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        )
                    )
                  ],
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    itemCount: nameListPDF.length,
                    itemBuilder: (_, index){
                      return Card(
                        color: Colors.grey.shade900,
                        child: ListTile(
                          leading: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 28,
                          ),
                          title: Text(
                            nameListPDF[index],
                            style: const TextStyle(
                                color: Colors.white
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: (){},
                            icon: const Icon(
                              Icons.download,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),

            Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 20),

                    const Text(
                      "Image",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24
                      ),
                    ),

                    const SizedBox(width: 260),

                    IconButton(
                        onPressed: ()async{
                          await pickAssets();
                          final file1 = await selectedAssets![0].file;

                          isLoading = true;
                          setState(() {

                          });
                          await StorageService.upload(
                              path: "image",
                              file: file1!
                          );
                          await loadDataPicture();
                          isLoading = false;
                          setState(() {

                          });
                        },
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        )
                    )
                  ],
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    itemCount: nameListPicture.length,
                    itemBuilder: (_, index){
                      return Card(
                        color: Colors.grey.shade900,
                        child: ListTile(
                          leading: GestureDetector(
                            child: Image.network(linkListPicture[index]),
                            onTap: (){
                              showDialog(
                                  context: context,
                                  builder: (context){
                                    return Dialog(
                                      backgroundColor: Colors.black,
                                      child: SizedBox(
                                        height: 400,
                                        width: MediaQuery.of(context).size.width,
                                        child: CachedNetworkImage(
                                          imageUrl: linkListPicture[index],
                                          placeholder: (context, url) => const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) => const Icon(Icons.error),
                                        ),
                                      ),
                                    );
                                  }
                              );
                            },
                          ),
                          title: Text(
                            nameListPicture[index],
                            style: const TextStyle(
                                color: Colors.white
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: ()async{
                              await download(linkListPicture[index], nameListPicture[index]);
                            },
                            icon: const Icon(
                              Icons.download,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 20),

                    const Text(
                      "Music",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24
                      ),
                    ),

                    const SizedBox(width: 260),

                    IconButton(
                        onPressed: ()async{
                          await openFilePicker();

                          isLoading = true;
                          setState(() {

                          });
                          await StorageService.upload(
                              path: "music",
                              file: file!
                          );
                          await loadDataMusic();
                          isLoading = false;
                          setState(() {

                          });
                        },
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        )
                    )
                  ],
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    itemCount: nameListMusic.length,
                    itemBuilder: (_, index){
                      return Card(
                        color: Colors.grey.shade900,
                        child: ListTile(
                          leading: IconButton(
                            onPressed: ()async{
                              AudioPlayer audio = AudioPlayer();

                              showDialog(
                                  context: context,
                                  builder: (context){
                                    return AlertDialog(
                                      backgroundColor: Colors.grey.shade900,
                                      title: const Text(
                                          "Music",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28
                                        ),
                                      ),
                                      actions: [
                                        Center(
                                          child: Row(
                                            children: [
                                              MaterialButton(
                                                  onPressed: ()async{
                                                    await audio.play(UrlSource(linkListMusic[index]));
                                                  },
                                                child: const Icon(
                                                  Icons.play_arrow,
                                                  color: Colors.white,
                                                  size: 25,
                                                ),
                                              ),

                                              MaterialButton(
                                                onPressed: ()async{
                                                  await audio.stop();
                                                },
                                                child: const Icon(
                                                  Icons.pause,
                                                  color: Colors.white,
                                                  size: 25,
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    );
                                  }
                              );
                            },
                            icon: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          title: Text(
                            nameListMusic[index],
                            style: const TextStyle(
                                color: Colors.white
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: ()async{
                              await download(linkListMusic[index], nameListMusic[index]);
                            },
                            icon: const Icon(
                              Icons.download,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ],
        )
      ),
    );
  }
}
