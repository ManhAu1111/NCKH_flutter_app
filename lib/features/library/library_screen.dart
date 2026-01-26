import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/pet_model.dart';
import '../../data/repositories/pet_repository.dart';
import '../../shared/widgets/PetCard.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String searchQuery = "";
  String selectedType = "All"; // All, Dog, Cat
  String selectedSize = "All"; // All, Nhỏ, Trung bình, Lớn
  RangeValues priceRange = const RangeValues(0, 100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // slate-50
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildQuickFilters(),
            Expanded(child: _buildPetGrid()),
          ],
        ),
      ),
    );
  }

  // Tiêu đề Thư viện
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              children: [
                TextSpan(text: "Thư viện "),
                TextSpan(text: "Thú Cưng", style: TextStyle(color: Color(0xFF0D9488))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Khám phá hàng trăm giống chó mèo phổ biến",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Thanh tìm kiếm giống Web
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          hintText: "Tìm kiếm tên giống...",
          prefixIcon: const Icon(LucideIcons.search, color: Colors.grey),
          suffixIcon: IconButton(
            icon: const Icon(LucideIcons.filter, color: Color(0xFF0D9488)),
            onPressed: _showFilterDrawer,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // Bộ lọc nhanh (Loài vật)
  Widget _buildQuickFilters() {
    final types = ["All", "Dog", "Cat"];
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          bool isSelected = selectedType == types[index];
          return ChoiceChip(
            label: Text(types[index] == "All" ? "Tất cả" : (types[index] == "Dog" ? "Chó" : "Mèo")),
            selected: isSelected,
            onSelected: (val) => setState(() => selectedType = types[index]),
            selectedColor: const Color(0xFF0D9488),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    );
  }

  // Lưới hiển thị danh sách
  Widget _buildPetGrid() {
    return FutureBuilder<List<Pet>>(
      future: PetRepository.loadPets(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        // Logic lọc dữ liệu giống bản Web
        final filteredList = snapshot.data!.where((pet) {
          final matchesSearch = pet.name.toLowerCase().contains(searchQuery.toLowerCase());
          final matchesType = selectedType == "All" || pet.type == selectedType;
          return matchesSearch && matchesType;
        }).toList();

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.68,
          ),
          itemCount: filteredList.length,
          itemBuilder: (context, index) => PetCard(pet: filteredList[index].toMap()),
        );
      },
    );
  }

  // Bottom Sheet cho bộ lọc nâng cao
  void _showFilterDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bộ lọc nâng cao", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            const Text("Kích thước", style: TextStyle(fontWeight: FontWeight.bold)),
            // ... Thêm các nút chọn kích thước ở đây tương tự Web
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488), padding: const EdgeInsets.all(16)),
                onPressed: () => Navigator.pop(context),
                child: const Text("Áp dụng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}