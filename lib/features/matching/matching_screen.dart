import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../pet_detail/pet_detail_screen.dart';
import 'quiz_data.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen>
    with SingleTickerProviderStateMixin {
  // Đã cập nhật baseUrl sang link Web Render để lấy ảnh
  final String baseUrl = "https://pet-ai-web-e43t.onrender.com";
  List<dynamic> allPets = [];
  bool isLoading = true;

  int currentStep = 0;
  Map<String, dynamic> answers = {};
  bool isFinished = false;
  List<Map<String, dynamic>> suggestedPets = [];

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadPetsData();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadPetsData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/pets_data.json',
      );
      final data = await json.decode(response);
      setState(() {
        allPets = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading pets data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  double get progress => (currentStep + 1) / quizQuestions.length;

  bool get hasCurrentAnswer {
    final key = quizQuestions[currentStep]['key'] as String;
    return answers.containsKey(key);
  }

  void selectOption(dynamic val) {
    setState(() {
      final key = quizQuestions[currentStep]['key'] as String;
      answers[key] = val;
    });
  }

  void nextStep() {
    if (hasCurrentAnswer) {
      if (currentStep < quizQuestions.length - 1) {
        setState(() {
          currentStep++;
        });
        _slideController.reset();
        _slideController.forward();
      } else {
        finishQuiz();
      }
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
      _slideController.reset();
      _slideController.forward();
    }
  }

  void finishQuiz() {
    calculateResult();
    setState(() {
      isFinished = true;
    });
  }

  bool _isMatchClose(num petVal, dynamic userRange) {
    if (userRange == null || userRange is! List) return false;
    List list = userRange;
    if (list.isEmpty) return false;
    num minVal = list.first;
    num maxVal = list.last;
    return petVal >= minVal - 1 && petVal <= maxVal + 1;
  }

  double _calculateWeightedDistance(
    Map<String, dynamic> userSelection,
    Map<String, dynamic> petScores,
  ) {
    List<String> keys = ['energy', 'space', 'grooming', 'kid_friendly'];
    double distanceSq = 0;

    for (String key in keys) {
      double weight = matchingWeights[key] ?? 1.0;
      List<dynamic> userRange = userSelection[key] ?? [3];
      var rawPetVal = petScores[key];
      num petVal = (rawPetVal == null || rawPetVal == 0) ? 3 : rawPetVal as num;

      double diff = 0;
      if (userRange.isNotEmpty) {
        num minR = userRange.first;
        num maxR = userRange.last;

        if (petVal < minR) {
          diff = (minR - petVal).toDouble();
        } else if (petVal > maxR) {
          diff = (petVal - maxR).toDouble();
        }
      }

      distanceSq += weight * pow(diff, 2);
    }
    return sqrt(distanceSq);
  }

  String _generateMatchReasons(
    Map<String, dynamic> pet,
    Map<String, dynamic> user,
  ) {
    List<String> reasons = [];
    var scores = pet['scores'] ?? {};
    if (_isMatchClose(scores['energy'] ?? 3, user['energy']))
      reasons.add('Mức năng lượng phù hợp');
    if (_isMatchClose(scores['space'] ?? 3, user['space']))
      reasons.add('Phù hợp không gian sống');
    if (_isMatchClose(scores['kid_friendly'] ?? 3, user['kid_friendly']))
      reasons.add('Thân thiện gia đình');
    if (pet['size'] == user['size']) reasons.add('Kích thước mong muốn');

    if (reasons.isEmpty) return 'Phù hợp làm bạn đồng hành';
    return reasons.take(2).join(' • ');
  }

  List<String> _generateMatchTags(
    Map<String, dynamic> pet,
    Map<String, dynamic> user,
  ) {
    List<String> tags = [];
    var scores = pet['scores'] ?? {};
    if (_isMatchClose(scores['energy'] ?? 3, user['energy']))
      tags.add('Năng lượng');
    if (_isMatchClose(scores['space'] ?? 3, user['space']))
      tags.add('Không gian');
    if (_isMatchClose(scores['kid_friendly'] ?? 3, user['kid_friendly']))
      tags.add('Thân thiện');
    if (pet['size'] == user['size']) tags.add('Kích thước');
    return tags;
  }

  void calculateResult() {
    Map<String, dynamic> user = answers;
    List<Map<String, dynamic>> results = [];

    for (var p in allPets) {
      if (p['id'] == 'unknown') continue;
      if (p['type']?.toString().toLowerCase() != user['type']) continue;

      var scores = p['scores'] ?? {};

      // HARD FILTERS
      var userSpace = user['space'];
      if (userSpace != null &&
          userSpace is List &&
          userSpace.isNotEmpty &&
          userSpace.first == 1 &&
          (scores['space'] ?? 3) >= 4) {
        continue;
      }

      var userKid = user['kid_friendly'];
      if (userKid != null &&
          userKid is List &&
          userKid.isNotEmpty &&
          userKid.first == 4 &&
          (scores['kid_friendly'] ?? 3) <= 2) {
        continue;
      }

      double distance = _calculateWeightedDistance(user, scores);

      // Kích thước phạt
      if (p['size'] != user['size']) distance += 1.5;

      double score = 100 / (1 + distance * 0.2);
      score = score.clamp(0, 100);

      Map<String, dynamic> petData = Map<String, dynamic>.from(p);
      petData['match'] = "${score.round()}%";
      petData['scoreObj'] = score;
      petData['desc'] = _generateMatchReasons(petData, user);
      petData['matchTags'] = _generateMatchTags(petData, user);

      results.add(petData);
    }

    results.sort(
      (a, b) => (b['scoreObj'] as double).compareTo(a['scoreObj'] as double),
    );

    setState(() {
      suggestedPets = results.take(3).toList();
    });
  }

  void restart() {
    setState(() {
      currentStep = 0;
      answers.clear();
      isFinished = false;
      suggestedPets.clear();
    });
    _slideController.reset();
    _slideController.forward();
  }

  void editAnswers() {
    setState(() {
      isFinished = false;
      currentStep = 0;
    });
    _slideController.reset();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0D9488)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isFinished) _buildQuizProcess() else _buildResultView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizProcess() {
    final curQ = quizQuestions[currentStep];
    return Column(
      children: [
        // Progress Header
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 600),
          margin: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "TIẾN TRÌNH: ${(progress * 100).round()}%",
                    style: const TextStyle(
                      color: Color(0xFF0D9488), // Teal 600
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    "Câu hỏi ${currentStep + 1} / ${quizQuestions.length}",
                    style: const TextStyle(
                      color: Color(0xFF94A3B8), // Slate 400
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE2E8F0), // Slate 200
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF14B8A6),
                  ), // Teal 500
                ),
              ),
            ],
          ),
        ),

        // Quiz Card
        Container(
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFF1F5F9)), // Slate 100
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE2E8F0).withOpacity(0.5),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDD5), // Orange 100
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    curQ['category'].toString().toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFEA580C), // Orange 600
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Text(
                  curQ['text'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A), // Slate 900
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  curQ['subtitle'] ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B), // Slate 500
                  ),
                ),
                const SizedBox(height: 32),

                // Options list
                Column(
                  children: List.generate((curQ['options'] as List).length, (
                    index,
                  ) {
                    final opt = curQ['options'][index];
                    final key = quizQuestions[currentStep]['key'] as String;

                    // Do dart List == khác object identity nên ta có thể fallback JSON cho chắc
                    final bool isSelected =
                        jsonEncode(answers[key]) == jsonEncode(opt['value']);

                    return GestureDetector(
                      onTap: () => selectOption(opt['value']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF0FDFA)
                              : Colors.white, // Teal 50
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF14B8A6)
                                : const Color(
                                    0xFFF1F5F9,
                                  ), // Teal 500 / Slate 100
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opt['text'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isSelected
                                          ? const Color(0xFF115E59)
                                          : const Color(
                                              0xFF1E293B,
                                            ), // Teal 800 / Slate 800
                                    ),
                                  ),
                                  if (opt['sub'] != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      opt['sub'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF94A3B8), // Slate 400
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? const Color(0xFF14B8A6)
                                    : Colors.transparent, // Teal 500
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF14B8A6)
                                      : const Color(
                                          0xFFE2E8F0,
                                        ), // Teal 500 / Slate 200
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      LucideIcons.check,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 32),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: currentStep == 0 ? null : prevStep,
                      icon: const Icon(LucideIcons.chevronLeft, size: 20),
                      label: const Text(
                        "Quay lại",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF0F172A), // Slate 900
                        disabledForegroundColor: const Color(
                          0xFFCBD5E1,
                        ), // Slate 300
                      ),
                    ),
                    ElevatedButton(
                      onPressed: hasCurrentAnswer ? nextStep : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316), // Orange 500
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(
                          0xFFF97316,
                        ).withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: hasCurrentAnswer ? 8 : 0,
                        shadowColor: const Color(0xFFF97316).withOpacity(0.5),
                      ),
                      child: Text(
                        currentStep == quizQuestions.length - 1
                            ? 'HOÀN TẤT'
                            : 'TIẾP THEO',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    if (suggestedPets.isEmpty) {
      return Column(
        children: [
          const Text(
            "Không tìm thấy kết quả phù hợp!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: restart, child: const Text("Thử lại")),
        ],
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      width: double.infinity,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "Kết quả phân tích",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Top 3 thú cưng phù hợp với bạn",
                  style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: editAnswers,
                  icon: const Icon(LucideIcons.edit2, size: 16),
                  label: const Text("Sửa câu trả lời"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F766E),
                    side: const BorderSide(color: Color(0xFFCCFBF1)),
                    backgroundColor: const Color(0xFFF0FDFA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ListView for pets
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: suggestedPets.length,
            itemBuilder: (context, index) {
              final pet = suggestedPets[index];
              return _buildPetCard(pet, index);
            },
          ),

          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: restart,
            icon: const Icon(LucideIcons.rotateCcw, size: 18),
            label: const Text(
              "Làm lại từ đầu",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet, int index) {
    bool isTop = index == 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isTop ? const Color(0xFF14B8A6) : const Color(0xFFE2E8F0),
          width: isTop ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isTop ? const Color(0xFF14B8A6) : Colors.black).withOpacity(
              0.1,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isTop)
            Positioned(
              top: -12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Lựa chọn tốt nhất",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (isTop) const SizedBox(height: 12),
                Text(
                  "Xác suất: ${pet['match']}",
                  style: const TextStyle(
                    color: Color(0xFF0D9488),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF1F5F9),
                      width: 6,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      baseUrl + (pet['image_path'] ?? ''),
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        color: const Color(0xFFE2E8F0),
                        child: const Icon(
                          LucideIcons.imageOff,
                          size: 40,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  pet['name']?.toString().toUpperCase() ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  pet['desc'] ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: (pet['matchTags'] as List<dynamic>)
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5), // Emerald 50
                            border: Border.all(
                              color: const Color(0xFFA7F3D0),
                            ), // Emerald 200
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag.toString(),
                            style: const TextStyle(
                              color: Color(0xFF047857),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ), // Emerald 700
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PetDetailScreen(pet: pet),
                        ),
                      );
                    },
                    icon: const Text(
                      "Xem chi tiết",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    label: const Icon(LucideIcons.arrowRight, size: 18),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
