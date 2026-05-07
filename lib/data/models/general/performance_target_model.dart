class PerformanceTargetMonthModel {
  final String month;
  final int target;
  final int realisasi;
  final double percentage;

  PerformanceTargetMonthModel({
    required this.month,
    required this.target,
    required this.realisasi,
    required this.percentage,
  });

  factory PerformanceTargetMonthModel.fromJson(Map<String, dynamic> json) {
    return PerformanceTargetMonthModel(
      month: json['month'],
      target: json['target'] is int
          ? json['target']
          : int.tryParse(json['target']?.toString() ?? '0') ?? 0,
      realisasi: json['realisasi'] is int
          ? json['realisasi']
          : int.tryParse(json['realisasi']?.toString() ?? '0') ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PerformanceTargetSummaryModel {
  final int target;
  final int realisasi;
  final double percentage;

  PerformanceTargetSummaryModel({
    required this.target,
    required this.realisasi,
    required this.percentage,
  });

  factory PerformanceTargetSummaryModel.fromJson(Map<String, dynamic> json) {
    return PerformanceTargetSummaryModel(
      target: json['target'] is int
          ? json['target']
          : int.tryParse(json['target']?.toString() ?? '0') ?? 0,
      realisasi: json['realisasi'] is int
          ? json['realisasi']
          : int.tryParse(json['realisasi']?.toString() ?? '0') ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PerformanceTargetDataModel {
  final String salesId;
  final int year;
  final PerformanceTargetSummaryModel summary;
  final List<PerformanceTargetMonthModel> months;

  PerformanceTargetDataModel({
    required this.salesId,
    required this.year,
    required this.summary,
    required this.months,
  });

  static const List<String> _monthNamesId = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static int? _monthIndexFromAny(String? raw) {
    final s = raw?.trim().toLowerCase();
    if (s == null || s.isEmpty) return null;
    switch (s) {
      case 'jan':
      case 'january':
      case 'januari':
        return 0;
      case 'feb':
      case 'february':
      case 'februari':
        return 1;
      case 'mar':
      case 'march':
      case 'maret':
        return 2;
      case 'apr':
      case 'april':
        return 3;
      case 'may':
      case 'mei':
        return 4;
      case 'jun':
      case 'june':
      case 'juni':
        return 5;
      case 'jul':
      case 'july':
      case 'juli':
        return 6;
      case 'aug':
      case 'august':
      case 'agu':
      case 'agustus':
        return 7;
      case 'sep':
      case 'sept':
      case 'september':
        return 8;
      case 'oct':
      case 'okt':
      case 'october':
      case 'oktober':
        return 9;
      case 'nov':
      case 'november':
        return 10;
      case 'dec':
      case 'des':
      case 'december':
      case 'desember':
        return 11;
      default:
        return null;
    }
  }

  factory PerformanceTargetDataModel.fromJson(Map<String, dynamic> json) {
    final rawMonths =
        (json['months'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        const <Map<String, dynamic>>[];

    // API sometimes returns duplicate month entries (e.g., Jan twice).
    // Normalize to a fixed 12-month list aligned to UI month index.
    // For duplicate months from API, take the LAST value (overwrite).
    final aggregated = <int, Map<String, num>>{};
    for (final m in rawMonths) {
      final idx = _monthIndexFromAny(m['month']?.toString());
      if (idx == null) continue;

      final target = m['target'] is int
          ? (m['target'] as int)
          : int.tryParse(m['target']?.toString() ?? '0') ?? 0;
      final realisasi = m['realisasi'] is int
          ? (m['realisasi'] as int)
          : int.tryParse(m['realisasi']?.toString() ?? '0') ?? 0;

      aggregated[idx] = {'target': target, 'realisasi': realisasi};
    }

    final normalizedMonths = List.generate(12, (i) {
      final bucket = aggregated[i];
      final target = (bucket?['target'] ?? 0).toInt();
      final realisasi = (bucket?['realisasi'] ?? 0).toInt();
      final percentage = target == 0 ? 0.0 : (realisasi / target) * 100.0;
      return PerformanceTargetMonthModel(
        month: _monthNamesId[i],
        target: target,
        realisasi: realisasi,
        percentage: percentage,
      );
    });

    return PerformanceTargetDataModel(
      salesId: json['sales_id'] ?? '',
      year: json['year'] is int
          ? json['year']
          : int.tryParse(
                  json['year']?.toString() ?? DateTime.now().year.toString(),
                ) ??
                DateTime.now().year,
      summary: PerformanceTargetSummaryModel.fromJson(json['summary'] ?? {}),
      months: normalizedMonths,
    );
  }
}
