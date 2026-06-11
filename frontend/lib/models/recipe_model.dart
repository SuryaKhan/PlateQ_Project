class Recipe {
  final int id;
  final String title;
  final String content;
  final String difficulty;
  final String cookingTime;
  final String authorName;
  final String authorRole;
  final String? image;

  Recipe({
    required this.id, 
    required this.title, 
    required this.content,
    required this.difficulty,
    required this.cookingTime,
    required this.authorName,
    required this.authorRole,
    this.image,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'] ?? 'Tanpa Judul',
      content: json['content'] ?? 'Tidak ada deskripsi',
      difficulty: json['difficulty'] ?? 'Easy',
      cookingTime: json['cookingTime'] ?? '30 min',
      image: json['image'],
      authorName: json['author']?['name'] ?? json['author']?['username'] ?? 'Unknown',
      authorRole: json['author']?['role'] ?? 'USER',
    );
  }
}
