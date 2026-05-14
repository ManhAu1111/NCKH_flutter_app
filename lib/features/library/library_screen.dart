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
            const SizedBox(height: 16),
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
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
              children: [
                TextSpan(text: "Thư viện "),
                TextSpan(
                  text: "Thú Cưng",
                  style: TextStyle(color: Color(0xFF0D9488)),
                ),
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

  // Lưới hiển thị danh sách
  Widget _buildPetGrid() {
    return FutureBuilder<List<Pet>>(
      future: PetRepository.loadPets(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        // Logic lọc dữ liệu giống bản Web
        final filteredList = snapshot.data!.where((pet) {
          final matchesSearch = pet.name.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
          final matchesType =
              selectedType == "All" ||
              pet.type.toLowerCase() == selectedType.toLowerCase();
          final matchesSize =
              selectedSize == "All" ||
              pet.size.toLowerCase() == selectedSize.toLowerCase();
          return matchesSearch && matchesType && matchesSize;
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
          itemBuilder: (context, index) =>
              PetCard(pet: filteredList[index].toMap()),
        );
      },
    );
  }

  // Bottom Sheet cho bộ lọc nâng cao
  void _showFilterDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Bộ lọc",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (selectedSize != "All" || selectedType != "All")
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selectedSize = "All";
                              selectedType = "All";
                            });
                            setModalState(() {});
                          },
                          child: const Text(
                            "Xóa lọc",
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "LOÀI VẬT",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                      fontSize: 13,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: ["All", "Dog", "Cat"].map((type) {
                      bool isSelected = selectedType == type;
                      IconData? icon;
                      String label = "Tất cả";
                      if (type == "Dog") {
                        label = "Chó";
                        icon = LucideIcons.dog;
                      } else if (type == "Cat") {
                        label = "Mèo";
                        icon = LucideIcons.cat;
                      }

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => selectedType = type);
                            setModalState(() {});
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              right: type == "Cat" ? 0 : 8,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFF0FDFA)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF14B8A6)
                                    : Colors.grey.shade200,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (type == "All")
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 9.5,
                                    ),
                                    child: Text(
                                      "Tất cả",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isSelected
                                            ? const Color(0xFF0F766E)
                                            : Colors.grey,
                                      ),
                                    ),
                                  )
                                else ...[
                                  Icon(
                                    icon,
                                    color: isSelected
                                        ? const Color(0xFF0F766E)
                                        : Colors.grey,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    label,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isSelected
                                          ? const Color(0xFF0F766E)
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "KÍCH THƯỚC",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                      fontSize: 13,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...["All", "small", "medium", "large"].map((size) {
                    final sizeLabels = {
                      "All": "Tất cả kích thước",
                      "small": "Nhỏ",
                      "medium": "Trung bình",
                      "large": "Lớn",
                    };
                    bool isSelected = selectedSize == size;
                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedSize = size);
                        setModalState(() {});
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0D9488)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF0D9488)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              sizeLabels[size]!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Áp dụng",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
