class ServiceCallReportItem {
  const ServiceCallReportItem({
    required this.serviceNo,
    required this.customer,
    required this.createdDate,
    required this.priority,
    required this.assignedTech,
    required this.status,
  });

  final String serviceNo;
  final String customer;
  final String createdDate;
  final String priority;
  final String assignedTech;
  final String status;

  factory ServiceCallReportItem.fromJson(Map<String, dynamic> json) {
    final createdDateRaw = (json['CreatedDate'] ?? '').toString().trim();
    return ServiceCallReportItem(
      serviceNo: (json['ServiceNo'] ?? '').toString().trim(),
      customer: (json['CustomerName'] ?? '').toString().trim(),
      createdDate: _normalizeDate(createdDateRaw),
      priority: (json['Priority'] ?? '').toString().trim(),
      assignedTech: (json['AssignedTech'] ?? '').toString().trim(),
      status: (json['CurrentStatus'] ?? '').toString().trim(),
    );
  }

  static String _normalizeDate(String value) {
    if (value.isEmpty) return '';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '${parsed.year}-$month-$day';
  }
}
