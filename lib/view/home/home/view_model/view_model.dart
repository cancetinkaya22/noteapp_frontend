import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class HomeViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _foundUser = [];
  bool _isLoading = true;

  List<Map<String, dynamic>> get items => _items;
  List<Map<String, dynamic>> get foundUser => _foundUser;
  bool get isLoading => _isLoading;

  set items(List<Map<String, dynamic>> value) {
    _items = value;
    notifyListeners();
  }
  void refreshHomeView() {
    fetchPostItems();
  }
   void updateFoundUser() {
    _foundUser = List.from(_items);
  }

  


  Future<void> fetchPostItems() async {
    try {
      final response = await Dio().get("http://localhost/noteapi/api");

      if (response.statusCode == 200) {
        final List<dynamic> responseData = response.data;
        items = List<Map<String, dynamic>>.from(responseData);
        
      } else {
        print("Veriler alınamadı. Hata kodu: ${response.statusCode}");
      }
    } catch (e) {
      print("Hata oluştu: $e");
    }
    _isLoading = false;
    notifyListeners();
  }
  
}

//   void searchItems(String query) {
//   if (query.isEmpty) {
//     filteredItems = List.from(items); // Arama sorgusu boş ise, tüm öğeleri filtrelenmiş listeye atayın
//   } else {
//     filteredItems = items.where((item) {
//       // Arama sorgusu ile eşleşen öğeleri filtrelenmiş listeye ekleyin
//       final String content = item['content'] ?? '';
//       return content.toLowerCase().contains(query.toLowerCase());
//     }).toList();
//   }
//   notifyListeners();
// }


