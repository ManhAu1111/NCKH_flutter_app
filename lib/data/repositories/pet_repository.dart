import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/pet_model.dart'; // Đảm bảo import đúng file Model bạn đã tạo

class PetRepository {
  // Chuyển hàm của bạn thành một hàm static để dễ gọi ở mọi nơi
  static Future<List<Pet>> loadPets() async {
    // Đọc file từ thư mục assets đã khai báo trong pubspec.yaml
    final String response = await rootBundle.loadString('assets/data/pets_data.json');
    final List<dynamic> data = json.decode(response);

    // Chuyển đổi danh sách JSON thành danh sách các đối tượng Pet
    return data.map((json) => Pet.fromJson(json)).toList();
  }
}