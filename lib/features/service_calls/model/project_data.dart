class ProjectData {
  const ProjectData({
    required this.id,
    required this.projectCode,
    required this.projectName,
  });

  final String id;
  final String projectCode;
  final String projectName;

  String get displayLabel {
    if (projectName.isEmpty) return projectCode;
    return '$projectCode - $projectName';
  }

  factory ProjectData.fromJson(Map<String, dynamic> json) {
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

    return ProjectData(
      id: readValue(<String>['id', 'Id']),
      projectCode: readValue(<String>['ProjectCode', 'projectCode']),
      projectName: readValue(<String>['ProjectName', 'projectName']),
    );
  }
}
