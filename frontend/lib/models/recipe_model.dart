class Recipe {
  final dynamic id;
  final String title;
  final String description;
  // Nanti bisa ditambah: ingredients, steps, imageUrl, dll sesuai database kamu

  Recipe({required this.id, required this.title, required this.description});

  // Fungsi andalan buat ngubah JSON dari backend jadi Objek Dart
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'] ?? 'Tanpa Judul', // Kasih default kalau kosong
      description: json['description'] ?? 'Tidak ada deskripsi',
    );
  }
}
