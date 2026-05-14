import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../features/pet_detail/pet_detail_screen.dart';

class PetCard extends StatelessWidget {
  final Map pet;
  const PetCard({super.key, required this.pet});

  // Đã cập nhật baseUrl sang link Web đã triển khai
  final String baseUrl = "https://pet-ai-web-e43t.onrender.com";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetDetailScreen(pet: pet),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  baseUrl + pet['image_path'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _toTitleCase(pet['name'].toString()),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(LucideIcons.clock, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
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
                    style: const TextStyle(
                      color: Color(0xFF0D9488), // Đổi sang màu Teal cho đồng bộ
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  // Viết hoa chữ cái đầu mỗi từ trong tên giống loài
  String _toTitleCase(String text) {
    return text
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
