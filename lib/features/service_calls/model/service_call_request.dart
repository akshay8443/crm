class ServiceCallRequest {
  final String customerCode;
  final String customerName;
  final String phone;
  final String email;
  final String contractNo;
  final String itemCode;
  final String serialNumber;
  final String mfrSerialno;
  final String currentStatus;
  final String priority;
  final String assignedTech;
  final String serviceType;
  final String serviceNo;
  final String createdDate;
  final String? closedDate;
  final String originType;
  final String problemType;
  final String problemSubType;
  final String callType;
  final String jobSheet;
  final String tourClaim;
  final String subjects;
  final String? tourStartDate;
  final String? tourEndDate;
  final String tourLocation;
  final String repairAssesmentType;
  final String projectCode;
  final String chargeable;
  final String remarks;
  final double expenseAmount;

  const ServiceCallRequest({
    required this.customerCode,
    required this.customerName,
    required this.phone,
    required this.email,
    required this.contractNo,
    required this.itemCode,
    required this.serialNumber,
    required this.mfrSerialno,
    required this.currentStatus,
    required this.priority,
    required this.assignedTech,
    required this.serviceType,
    required this.serviceNo,
    required this.createdDate,
    this.closedDate,
    required this.originType,
    required this.problemType,
    required this.problemSubType,
    required this.callType,
    required this.jobSheet,
    required this.tourClaim,
    required this.subjects,
    this.tourStartDate,
    this.tourEndDate,
    required this.tourLocation,
    required this.repairAssesmentType,
    required this.projectCode,
    required this.chargeable,
    required this.remarks,
    required this.expenseAmount,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'customerCode': customerCode,
      'customerName': customerName,
      'phone': phone,
      'email': email,
      'contractNo': contractNo,
      'itemCode': itemCode,
      'serialNumber': serialNumber,
      'mfrSerialno': mfrSerialno,
      'currentStatus': currentStatus,
      'priority': priority,
      'assignedTech': assignedTech,
      'serviceType': serviceType,
      'serviceNo': serviceNo,
      'createdDate': createdDate,
      'closedDate': closedDate,
      'originType': originType,
      'problemType': problemType,
      'problemSubType': problemSubType,
      'callType': callType,
      'jobSheet': jobSheet,
      'tourClaim': tourClaim,
      'subjects': subjects,
      'tourStartDate': tourStartDate,
      'tourEndDate': tourEndDate,
      'tourLocation': tourLocation,
      'repairAssesmentType': repairAssesmentType,
      'projectCode': projectCode,
      'chargeable': chargeable,
      'remarks': remarks,
      'expenseAmount': expenseAmount,
    };
  }
}
