import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const MaterialApp(home: KanjiApp()));
}

class KanjiApp extends StatefulWidget {
  const KanjiApp({super.key});
  @override
  State<KanjiApp> createState() => _KanjiAppState();
}

class _KanjiAppState extends State<KanjiApp> {
  File? _image; // Biến lưu trữ ảnh đã chọn
  final ImagePicker _picker = ImagePicker();

  // Hàm xử lý lấy ảnh
  Future<void> _pickImage(ImageSource source) async {
    final XFile? selectedImage = await _picker.pickImage(source: source);
    if (selectedImage != null) {
      setState(() {
        _image = File(selectedImage.path);
      });
    }
  }

  // Hàm hiển thị Menu lựa chọn từ dưới lên (Bottom Sheet)
  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh mới'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Học Kanji qua hình ảnh'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: _image == null
            ? const Text('Chưa có ảnh nào được chọn. Nhấn + để bắt đầu!')
            : Image.file(_image!), // Hiển thị ảnh sau khi chọn
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPickerOptions,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, size: 30), // Nút dấu cộng
      ),
    );
  }
}