import 'dart:io';

import 'package:flutter/material.dart';
import 'package:noteapp/view/home/note_changer/note_changer.dart';



class NoteReader extends StatefulWidget {
  const NoteReader({Key? key, required this.item}) : super(key: key);
  final Map<String, dynamic> item;

  @override
  NoteReaderState createState() => NoteReaderState();
}


class NoteReaderState extends State<NoteReader> {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
    appBar: AppBar(
    automaticallyImplyLeading: true,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
          widget.item['title'] ?? '',
           style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
         ),
        const SizedBox(height: 28,),
        Positioned(bottom: 10.0,
            right: 10.0,
            child: _buildSelectedImages(),),
          Text(
          widget.item['content'] ?? '',
          style: const TextStyle(fontSize: 15),
         ),
      ],
    ),
  ),
  floatingActionButton: Padding(
    padding:const EdgeInsets.only(bottom: 15.0, right: 15.0),
    child: Opacity(
        opacity: 0.8,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => NoteChanger(item : widget.item)),
      );
          },
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 255, 68, 230),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.edit),
            ),
          ),
        ),
      ),
    ),
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




// title: Text(widget.item['title'] ?? '')
// contentPadding: const EdgeInsets.all(8.0),
//               subtitle: Text(widget.item['content'] ?? ''),
