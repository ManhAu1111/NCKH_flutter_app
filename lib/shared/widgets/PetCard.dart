import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PetCard extends StatelessWidget {
  final Map pet;
  PetCard({required this.pet});

  // Đổi localhost thành 10.0.2.2 để máy ảo hiểu
  final String baseUrl = "http://192.168.137.197:5173/";

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Dùng Flexible cho ảnh để không chiếm hết chỗ
          Flexible(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.network(
                baseUrl + pet['image_path'],
                width: double.infinity,
                fit: BoxFit.cover,
                // Hiện icon nếu ảnh chưa load xong hoặc lỗi server
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),

          // 2. Phần thông tin chữ
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Giúp Column thu gọn
              children: [
                Text(
                  pet['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Cắt bớt nếu tên quá dài
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.clock, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded( // Tránh tràn ngang nếu text lifespan dài
                      child: Text(
                        pet['lifespan'],
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  pet['price']['paper'] ?? 'Liên hệ',
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}