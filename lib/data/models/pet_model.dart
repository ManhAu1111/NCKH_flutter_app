class Pet {
  final String id;
  final String name;
  final String type;
  final String lifespan;
  final String careInstruction;
  final Map<String, String> price;
  final String size;
  final Map<String, int> scores;
  final String imagePath;

  Pet({
    required this.id, required this.name, required this.type,
    required this.lifespan, required this.careInstruction,
    required this.price, required this.size, required this.scores,
    required this.imagePath,
  });

  // Hàm chuyển từ JSON sang Object
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      lifespan: json['lifespan'],
      careInstruction: json['care_instruction'],
      price: Map<String, String>.from(json['price']),
      size: json['size'],
      scores: Map<String, int>.from(json['scores']),
      imagePath: json['image_path'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'lifespan': lifespan,
      'care_instruction': careInstruction,
      'price': price,
      'size': size,
      'scores': scores,
      'image_path': imagePath,
    };
  }
}