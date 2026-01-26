import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  bool _isLoading = false; // Trạng thái chờ tải
  Map<String, dynamic>? _result; // Lưu kết quả từ AI
  final ImagePicker _picker = ImagePicker();

  // Địa chỉ IP máy tính chạy Server AI (Dùng 10.0.2.2 cho máy ảo Android)
  final String apiUrl = "http://10.0.2.2:8000/predict";

  Future<void> _pickImage(ImageSource source) async {
    final XFile? selectedImage = await _picker.pickImage(source: source);
    if (selectedImage != null) {
      setState(() {
        _image = File(selectedImage.path);
        _result = null; // Xóa kết quả cũ khi chọn ảnh mới
      });
    }
  }

  // Hàm gửi ảnh lên Server AI
  Future<void> _analyzeImage() async {
    if (_image == null) return;

    setState(() => _isLoading = true);

    try {
      // Tạo yêu cầu Multipart
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Thêm file ảnh với key là 'file'
      request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _result = data);
      } else {
        _showError("Lỗi kết nối Server: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Không thể kết nối tới AI Server. Hãy kiểm tra IP và Wifi.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                "PetAI Scanner",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              Text("Nhận diện giống loài bằng trí tuệ nhân tạo",
                  style: TextStyle(color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
              const SizedBox(height: 32),

              // Khu vực hiển thị ảnh
              GestureDetector(
                onTap: _isLoading ? null : () => _showPickerOptions(),
                child: Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                  ),
                  child: _image == null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: const Color(0xFFF0FDFA), borderRadius: BorderRadius.circular(20)),
                        child: const Icon(LucideIcons.uploadCloud, size: 48, color: Color(0xFF0D9488)),
                      ),
                      const SizedBox(height: 16),
                      const Text("Tải ảnh lên để quét", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.file(_image!, fit: BoxFit.cover),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Nút chức năng
              if (_image != null && !_isLoading)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: _analyzeImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        icon: const Icon(LucideIcons.scanLine),
                        label: Text("BẮT ĐẦU QUÉT", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() { _image = null; _result = null; }),
                      child: const Text("Chọn ảnh khác", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),

              // Loading Indicator
              if (_isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF0D9488)),
                    SizedBox(height: 16),
                    Text("Đang phân tích giống loài...", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
                  ],
                ),

              // Hiển thị kết quả
              if (_result != null) _buildResultSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    bool success = _result!['success'] ?? false;
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: success ? const Color(0xFFF0FDFA) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: success ? const Color(0xFFCCFBF1) : const Color(0xFFFEE2E2)),
      ),
      child: Column(
        children: [
          Text(
            success ? "Kết quả dự đoán:" : "Thông báo:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: success ? const Color(0xFF0F766E) : Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            success ? _result!['breed'] : _result!['message'],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          if (success)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Độ tin cậy: ${_result!['confidence']}%",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: const Text('Thư viện ảnh', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () { _pickImage(ImageSource.gallery); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: const Text('Máy ảnh', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () { _pickImage(ImageSource.camera); Navigator.pop(context); },
            ),
          ],
        ),
      ),
    );
  }
}