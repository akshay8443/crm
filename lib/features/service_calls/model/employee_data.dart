class EmployeeData {
  const EmployeeData({
    required this.id,
    required this.employeeName,
  });

  final String id;
  final String employeeName;

  factory EmployeeData.fromJson(Map<String, dynamic> json) {
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

    return EmployeeData(
      id: readValue(<String>['id', 'Id']),
      employeeName: readValue(<String>['EmployeeName', 'employeeName']),
    );
  }
}
