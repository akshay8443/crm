class ProblemTypeData {
  const ProblemTypeData({
    required this.id,
    required this.problemType,
  });

  final String id;
  final String problemType;

  factory ProblemTypeData.fromJson(Map<String, dynamic> json) {
    String readValue(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value != null) {
          final normalized = value.toString().trim();
          if (normalized.isNotEmpty) return normalized;
        }
      }
      return '';
    }

    return ProblemTypeData(
      id: readValue(<String>['id', 'Id']),
      problemType: readValue(<String>['ProblemTypes', 'problemTypes']),
    );
  }
}
