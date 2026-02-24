class ProblemSubTypeData {
  const ProblemSubTypeData({
    required this.id,
    required this.problemSubType,
  });

  final String id;
  final String problemSubType;

  factory ProblemSubTypeData.fromJson(Map<String, dynamic> json) {
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

    return ProblemSubTypeData(
      id: readValue(<String>['id', 'Id']),
      problemSubType: readValue(
        <String>[
          'ProblemSubTypes',
          'problemSubTypes',
          'ProblemSubType',
          'problemSubType',
          'SubProblemTypes',
        ],
      ),
    );
  }
}
