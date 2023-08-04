import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noteapp/view/home/home/view/home_view.dart';
import 'package:noteapp/view/home/note_editor/view/sound_recorder.dart';
import 'package:noteapp/view/home/note_editor/view/timer_widget.dart';

class NoteView extends StatefulWidget {
  const NoteView({Key? key}) : super(key: key);
  
  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  final timerController=TimeController();
  final recorder = SoundRecorder();
  List<XFile>? _images;
  final picker = ImagePicker();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  bool showSaveIcon = false;

    Future<void> choiceImage() async {
  List<XFile>? pickedImages = await picker.pickMultiImage(
    imageQuality: 80,
    maxWidth: 800,
    maxHeight: 800,
  );
  setState(() {
    if (_images == null) {
      _images = pickedImages;
    } else {
      _images!.addAll(pickedImages);
    }
  });
  print(_images);
}

  Future<bool?> save() async{
  final Dio dio = Dio();
  String url = "http://localhost/noteapi/api";
  List<MultipartFile> imageFiles = [];
    if (_images != null) {
    for (XFile image in _images!) {
      File file = File(image.path);
      String fileName = image.name;
      imageFiles.add(await MultipartFile.fromFile(file.path, filename: fileName));
    }
  }
  FormData formData = FormData.fromMap({
    "title": titleController.text,
    "content": noteController.text,
    "image": imageFiles,
  }); 
      try {
      final response = await dio.post(url, data: formData);
      if (response.statusCode == 200){

        // ignore: avoid_print
        print("yes");
        return true;
      }else{
        // ignore: avoid_print
        print("no");
        return false;
      }
    } catch (e) {
        // ignore: avoid_print
        print(e.toString());
    }
    return null;
      
  }

  @override
  void initState() {
    super.initState();
    titleController.addListener(updateSaveIconVisibility);
    updateSaveIconVisibility();
    recorder.init();
  }

  @override
  void dispose() {
    recorder.dispose();
    titleController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void updateSaveIconVisibility() {
    setState(() {
      showSaveIcon = titleController.text.isNotEmpty;
    });
  }

  Widget _buildSelectedImages() {
  if (_images == null || _images!.isEmpty) {
    return const SizedBox.shrink();
  }
  final double itemSize = MediaQuery.of(context).size.width * 0.3;

  return SizedBox(
    height: itemSize + 10,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _images!.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _showImagePreview(_images![index]);
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(4.0),
            margin: const EdgeInsets.all(4.0),
            child: Image.file(
              File(_images![index].path),
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    ),
  );
}



  void _showImagePreview(XFile image) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          child: InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(20.0),
            minScale: 0.1,
            maxScale: 5.0,
            child: Image.file(
              File(image.path),
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    },
  );
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Padding(
  padding: const EdgeInsets.all(16.0),
  child: Stack(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(
              hintText: 'Not Başlığı',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16,),
          Positioned(bottom: 10.0,
            right: 10.0,
            child: _buildSelectedImages(),),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: SingleChildScrollView(
                child: TextFormField(
                  controller: noteController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Notunuzu buraya girin',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      Positioned(
  bottom: 10.0,
  left: 10.0,
  child: Container(
    width: 40,
    height: 40,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.red, 
    ),
    child: InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SizedBox(
              height: 150,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        choiceImage();
                        // Add your specific action for the photo button here
                        Navigator.pop(context); 
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.green,
                      ),
                      child: const Icon(Icons.photo_library_rounded),
                    ),
                    const SizedBox(height: 10),
                   ElevatedButton(
  onPressed: () {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final isRecording = recorder.isRecording;
        final icon = isRecording ? Icons.stop : Icons.mic;
        final text= isRecording ? 'STOP' : 'START';
        final primary = isRecording ? Colors.red : Colors.white;
        final onPrimary = isRecording ? Colors.white : Colors.black;

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          width:  MediaQuery.of(context).size.width * 0.7, // Cihazın yüksekliğinin yarısı
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.mic,size:20),
                          TimerWidget(controller:timerController),
                          const SizedBox(height: 10),
                          Text(text),
                        ],
                      ),
                ),
                  const SizedBox(height: 30),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: onPrimary, backgroundColor: primary, minimumSize: const Size(175,50),
                  ),
                  onPressed: () async {
                   await recorder.toggleRecording();
                   // ignore: unused_local_variable
                   final isRecording = await recorder.toggleRecording();
                   setState(() {});
                   if(isRecording){
                    timerController.startTimer();
                   }else{
                    timerController.stopTimer();
                   }
                  }, 
                  icon: Icon(icon), 
                  label: Text(text,style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)),
                
                
                // const SizedBox(height: 16),
                // const Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     ElevatedButton(
                //       onPressed: null,
                //       child: Text('Durdur'),
                //     ),
                //     SizedBox(width: 16),
                //     ElevatedButton(
                //       onPressed:null,
                //       child: Text('Bitir'),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        );
      },
    );
  },
  style: ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Colors.purpleAccent,
  ),
  child: const Icon(Icons.keyboard_voice_rounded),
),



                  ],
                ),
              ),
            );
          },
        );
      },
      child: const Icon(
        Icons.add,
        color: Colors.white, // Choose your desired color here
      ),
    ),
  ),
)


    ],
  ),
),

      floatingActionButton: showSaveIcon
  ? Padding(
      padding: const EdgeInsets.only(bottom: 10.0, right: 10.0),
      child: Opacity(
        opacity: 0.8,
        child: GestureDetector(
          onTap: () {
            save().then((value){
              if(value==true){
                Navigator.of(context).push(MaterialPageRoute(builder:(context) => const HomeView() ));
              }else{
                null;
              }
            });
          },
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent,
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.save),
            ),
          ),
        ),
      ),
    )
  : null,
  
    );
  

  }
}


