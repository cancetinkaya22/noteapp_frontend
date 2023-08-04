import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../home/view/home_view.dart';

class NoteChanger extends StatefulWidget {
  const NoteChanger( {super.key, required this.item});
  final Map<String, dynamic> item;

  @override
  State<NoteChanger> createState() => _NoteChangerState();
}

class _NoteChangerState extends State<NoteChanger> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  bool showSaveIcon = false;

   @override
  void initState() {
    super.initState();
    
    titleController.text = widget.item['title'] ?? '';
    noteController.text = widget.item['content'] ?? '';
    

    titleController.addListener(updateSaveIconVisibility);
    updateSaveIconVisibility();
  }
  Future<bool?> save() async {
  final Dio dio = Dio();
  int noteId = int.parse(widget.item['id'].toString());
  String url = "http://localhost/noteapi/api?id=$noteId";
  Map<String, dynamic> data = {
      "title": titleController.text,
      "content": noteController.text,
    };
  try {
    final response = await dio.put(url, data: data);
    if (response.statusCode == 200) {
      print("Güncelleme başarılı");
      print(noteId.runtimeType);
      print(titleController.text);
      return true;
    } else {
      print("Güncelleme başarısız");
      return false;
    }
  } catch (e) {
    print(e.toString());
  }
  return null;
}
@override
 

  @override
  void dispose() {
    titleController.dispose();
    noteController.dispose();
    super.dispose();
  }

 void updateSaveIconVisibility() {
    setState(() {
      showSaveIcon = titleController.text.isNotEmpty || noteController.text.isNotEmpty;
    });
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      
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
          InkWell(
            onLongPress: () async{


            bool confirmResult = false;

            confirmResult = await showDialog(
            context: context,
            builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Silme Onayı"),
              content: const Text("Bu notu silmek istediğinizden emin misiniz?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Evet seçeneği
                  },
                  child: const Text("Evet"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Hayır seçeneği
                  },
                  child: const Text("Hayır"),
                ),
              ],
            );
          },
        );
        if (confirmResult) {
          
        }
            },
            child: Positioned(bottom: 10.0,
              right: 10.0,
              child: _buildSelectedImages(),),
          ),
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
      color: Colors.red, // Choose your desired color here
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
                        // Add your specific action for the close button here
                        Navigator.pop(context); 
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.purpleAccent,
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
        color: Colors.white, 
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
                
                Navigator.of(context).push(MaterialPageRoute(builder:(context) =>  const HomeView() ));
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
  Widget _buildSelectedImages() {
  if (widget.item['image_url'] == null || widget.item['image_url'].isEmpty) {
    return const SizedBox.shrink();
  }
  final String imageUrl = widget.item['image_url'];
  final List<String> imageUrls = imageUrl.split(',');
  final double itemSize = MediaQuery.of(context).size.width * 0.3;
  
  return SizedBox(
    height: itemSize + 10,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        String path = imageUrls[index].trim();
        return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(4.0),
            margin: const EdgeInsets.all(4.0),
            child: Image.file(
              File(path),
              width: 100,
              fit: BoxFit.cover,
            ),
          );
      },
    ),
  );
}
}

