import 'dart:ui'; // Thêm để dùng BackdropFilter cho hiệu ứng blur
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PetDetailScreen extends StatelessWidget {
  final Map pet;
  const PetDetailScreen({super.key, required this.pet});

  // Đã cập nhật baseUrl sang link Web đã triển khai để lấy ảnh
  final String baseUrl = "https://pet-ai-web-e43t.onrender.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // 1. Header Image với Tags đè lên
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF0D9488)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'pet-${pet['id']}',
                    child: Image.network(
                      baseUrl + pet['image_path'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 100,
                    left: 20,
                    child: Row(
                      children: [
                        _buildGlassTag(
                          pet['type'] == 'Dog' ? 'Chó cảnh' : 'Mèo cảnh',
                          const Color(0xFF0D9488),
                          Colors.white,
                        ),
                        const SizedBox(width: 8),
                        _buildGlassTag(
                          "Size: ${pet['size']}",
                          Colors.orange,
                          Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Title Section
                  Text(
                    pet['name'],
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text("⏳ Tuổi thọ: ${pet['lifespan']}",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  ),

                  const SizedBox(height: 32),

                  // 3. Scores Grid
                  _buildAllScoresGrid(),

                  const SizedBox(height: 32),

                  // 4. Pricing Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(LucideIcons.dollarSign, color: Colors.white),
                            SizedBox(width: 8),
                            Text("Bảng giá tham khảo",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        const Divider(color: Colors.white24, height: 24),
                        _buildPriceRow("Có giấy tờ (VKA)", pet['price']['paper']),
                        _buildPriceRow("Không giấy tờ", pet['price']['no_paper']),
                        _buildPriceRow("Nhập khẩu", pet['price']['international']),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 5. Care Instructions
                  const Text("Hướng dẫn chăm sóc",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  const SizedBox(height: 12),
                  Text(
                    pet['care_instruction'] ?? "Đang cập nhật...",
                    style: const TextStyle(fontSize: 16, color: Color(0xFF475569), height: 1.6),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.orange,
        label: const Text("LIÊN HỆ NGAY", style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(LucideIcons.messageSquare),
      ),
    );
  }

  Widget _buildGlassTag(String label, Color color, Color textColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white.withOpacity(0.9),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildAllScoresGrid() {
    final List<Map<String, dynamic>> scoreConfigs = [
      {"label": "Vận động", "value": (pet['scores']?['energy'] ?? 3).toInt(), "icon": LucideIcons.activity, "color": Colors.teal},
      {"label": "Không gian", "value": (pet['scores']?['space'] ?? 3).toInt(), "icon": LucideIcons.home, "color": Colors.blue},
      {"label": "Chăm sóc lông", "value": (pet['scores']?['grooming'] ?? 3).toInt(), "icon": LucideIcons.scissors, "color": Colors.purple},
      {"label": "Thân thiện trẻ em", "value": (6 - (pet['scores']?['kid_friendly'] ?? 3)).toInt(), "icon": LucideIcons.heart, "color": Colors.red},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.activity, size: 20, color: Color(0xFF0D9488)),
              SizedBox(width: 10),
              Text("Chỉ số đặc điểm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: scoreConfigs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.6,
            ),
            itemBuilder: (context, index) {
              final item = scoreConfigs[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(item['icon'], size: 14, color: const Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item['label'].toUpperCase(),
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (barIndex) {
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.only(right: barIndex < 4 ? 3 : 0),
                            decoration: BoxDecoration(
                              color: barIndex < item['value'] ? item['color'] : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String? price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14))),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: Text(price ?? "Liên hệ", textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
        ],
      ),
    );
  }
}
