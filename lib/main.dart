import 'package:flutter/material.dart';
import 'package:noteapp/view/home/home/view/home_view.dart';
import 'package:provider/provider.dart';

import 'view/home/home/view_model/view_model.dart';



void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => HomeViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black12),
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}
