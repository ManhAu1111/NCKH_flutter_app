import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; // Thêm để dùng rootBundle nạp JSON
import '../pet_detail/pet_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  final ImagePicker _picker = ImagePicker();
  List<dynamic> _allPets = []; // Danh sách lưu trữ dữ liệu từ pets_data.json

  // Cập nhật địa chỉ Backend mới sang Render
  final String apiUrl = "https://pet-ai-backend-c7h8.onrender.com/predict";

  @override
  void initState() {
    super.initState();
    _loadPetData(); // Nạp dữ liệu ngay khi vào App
  }

  // Hàm nạp dữ liệu từ assets/data/pets_data.json
  Future<void> _loadPetData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/pets_data.json',
      );
      final data = await json.decode(response);
      setState(() {
        _allPets = data;
      });
    } catch (e) {
      debugPrint("Lỗi nạp dữ liệu JSON: $e");
    }
  }

  // Hàm tìm thú cưng trong danh sách dựa trên tên breed từ AI
  Map<String, dynamic>? _findPetInData(String breedName) {
    try {
      return _allPets.firstWhere(
        (pet) =>
            pet['name'].toString().toLowerCase().trim() ==
            breedName.toLowerCase().trim(),
        orElse: () => null,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? selectedImage = await _picker.pickImage(source: source);
    if (selectedImage != null) {
      setState(() {
        _image = File(selectedImage.path);
        _result = null;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;
    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(
        await http.MultipartFile.fromPath('file', _image!.path),
      );
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _result = data);
      } else {
        _showError("Lỗi kết nối Server: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Không thể kết nối tới AI Server. Vui lòng kiểm tra Internet.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
              // --- LOGO PETAI THEO PHONG CÁCH VUE/TAILWIND ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488), // teal-600
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D9488).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.dog,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B), // slate-800
                        letterSpacing: -1.2,
                      ),
                      children: [
                        TextSpan(text: "Pet"),
                        TextSpan(
                          text: "AI",
                          style: TextStyle(color: Color(0xFF0D9488)), // teal-600
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // ----------------------------------------------

              const SizedBox(height: 12),
              const Text(
                "Nhận diện giống loài bằng trí tuệ nhân tạo",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
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
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 2,
                    ),
                  ),
                  child: _image == null
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.uploadCloud, size: 48, color: Color(0xFF94A3B8)),
                              SizedBox(height: 12),
                              const Text(
                                "Tải ảnh lên để quét",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        ),
                ),
              ),

              const SizedBox(height: 32),

              if (_image != null && !_isLoading)
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _analyzeImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(LucideIcons.scanLine),
                    label: const Text(
                      "BẮT ĐẦU QUÉT",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

              if (_isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF0D9488)),
                    SizedBox(height: 16),
                    Text("Đang phân tích dữ liệu...", style: TextStyle(color: Color(0xFF64748B))),
                  ],
                ),

              if (_result != null) _buildResultSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    bool success = _result!['success'] ?? false;
    String breedName = _result!['breed'] ?? "";
    String displayMessage =
        _result!['message'] ??
        _result!['error'] ??
        "Lỗi hệ thống không xác định";
    double confidence = (_result!['confidence'] ?? 0.0).toDouble();

    var foundPet = _findPetInData(breedName);

    // Bắt chước hàm formatBreed bên Vue (Xóa dấu _, Viết hoa chữ cái đầu)
    String formattedBreed = breedName
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: success ? Colors.white : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: success ? const Color(0xFF14B8A6) : const Color(0xFFF87171),
          width: 4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          if (!success) ...[
            const Text(
              "Không nhận diện được",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              displayMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF475569),
              ),
            ),
          ]
          else ...[
            const Text(
              "KẾT QUẢ PHÂN TÍCH",
              style: TextStyle(
                color: Color(0xFF0D9488),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formattedBreed,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Độ tin cậy: ",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDFA),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "${confidence.toStringAsFixed(1)}%",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF0D9488),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            if (foundPet != null)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PetDetailScreen(pet: foundPet),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  label: const Text(
                    "Xem thông tin chi tiết",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  icon: const Icon(LucideIcons.arrowRight, size: 20),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Text(
                  "(Chưa có dữ liệu chi tiết cho giống này)",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: const Text('Thư viện ảnh'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: const Text('Máy ảnh'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
