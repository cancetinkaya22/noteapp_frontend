import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:noteapp/view/home/note_editor/view/note_editor.dart';
import 'package:noteapp/view/home/note_reader/view/note_reader.dart';
// import 'package:noteapp/view/widgets/note_Card/note_card.dart';
import 'package:provider/provider.dart';

import '../view_model/view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  HomeViewModel homeViewModel = HomeViewModel();
  List<Map<String, dynamic>> item = [];
  List<Map<String, dynamic>> _foundUsers = [];

  @override
  void initState() {
    _foundUsers = item;
    super.initState();

    Provider.of<HomeViewModel>(context, listen: false).fetchPostItems();
    fetchItems();
  }

  Future<void> fetchItems() async {
    await homeViewModel.fetchPostItems();
    setState(() {
      item = homeViewModel.items;
      _foundUsers = List<Map<String, dynamic>>.from(item);
    });
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = item;
    } else {
      results = item
          .where((user) => user["content"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.red, Colors.blue]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            const Padding(
              padding: EdgeInsets.only(left: 10),
               child: Text(
                 "NOTLARINIZ",
                 style: TextStyle(
                   color: Colors.white,
                   fontSize: 30,
                   
                 ),
               ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.white60,
              ),
              child: TextField(
                onChanged: (value) => _runFilter(value),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "    Notunuzu Arayın",
                  prefixIcon: Icon(Icons.search),
                  prefixIconColor: Colors.black,
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 10)),
            Container(
              padding: const EdgeInsets.only(left: 16),
              child: const Center(
                // child: Text(
                //   "Notlarınız",
                //   style: TextStyle(
                //     fontSize: 30,
                //     color: Colors.white,
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Consumer<HomeViewModel>(
                builder: (context, viewModel, child) {
                  final items = _foundUsers;
                  final isLoading = viewModel.isLoading;

                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (items.isNotEmpty) {
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _buildNoteCard(context, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteReader(item: items[index]),
                            ),
                          );
                        }, items[index]);
                      },
                    );
                  } else {
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(padding: EdgeInsets.only(top: 50)),
                        Center(
                          child: Text(
                            "",
                            style: TextStyle(color: Colors.white, fontFamily: AutofillHints.middleName, fontSize: 20),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToNoteView(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, Function()? onTap, Map<String, dynamic> items) {
    final title = items['title'] as String;
    final content = items['content'] as String;
    final imageUrl =items['image_url'] as String?;
    // print(imageUrl);
    int noteId = int.parse(items['id']);

    return InkWell(
      onTap: () => onTap?.call(),
      onLongPress: () async {
        final dio = Dio();

        Future<void> deleteNote() async {
          try {
            final response = await dio.delete('http://localhost/noteapi/api/?id=$noteId');
            print('Response data: ${response.data}, Deleted ID: $noteId');
          } catch (error) {
            print('Hata oluştu: $error');
          }
        }

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
          await deleteNote();

          final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
          homeViewModel.refreshHomeView();
            await fetchItems();

          setState(() {
            _foundUsers = List<Map<String, dynamic>>.from(item);
          });
        }
      },
      child: Card(
        elevation: 5,
  color: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8.0),
  ),
  margin: const EdgeInsets.all(8.0),
  child: ListTile(
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 28,
      ),
    ),
    subtitle: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(content),
        if (imageUrl != null && imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.file(
              File(imageUrl),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        // imageUrl boş ise boş bir Container widget'ı döndür
      ],
    ),
  ),
),

    );
  }

  void _navigateToNoteView(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => const NoteView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
