class MGenModel {
  final String id;
  final String group;
  final String? key1;
  final String? value1;
  final String? value2;

  MGenModel({
    required this.id,
    required this.group,
    this.value1,
    this.value2,
    this.key1,
  });

  factory MGenModel.fromJson(Map<String, dynamic>? json) {
    // Tambahkan '?' agar bisa menerima null
    return MGenModel(
      id: json?['id']?.toString() ?? '', // Gunakan null-aware operator '?['
      group: json?['group']?.toString() ?? '',
      key1: json?['key1'],
      value2: json?['value2'],
      value1:
          json?['value1']?.toString() ??
          '-', // Berikan default '-' jika value1 null
    );
  }
}
