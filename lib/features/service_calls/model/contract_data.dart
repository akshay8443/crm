class ContractData {
  const ContractData({
    required this.id,
    required this.contractNo,
    required this.businessPartnerCode,
    required this.businessPartnerName,
    required this.rowNo,
    required this.mfrSerialNo,
    required this.serialNumber,
    required this.itemNo,
    required this.itemDescription,
    required this.email,
    required this.phone,
  });

  final String id;
  final String contractNo;
  final String businessPartnerCode;
  final String businessPartnerName;
  final String rowNo;
  final String mfrSerialNo;
  final String serialNumber;
  final String itemNo;
  final String itemDescription;
  final String email;
  final String phone;

  factory ContractData.fromJson(Map<String, dynamic> json) {
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

    return ContractData(
      id: readValue(<String>['id', 'Id']),
      contractNo: readValue(<String>['ContractNo', 'contractNo']),
      businessPartnerCode: readValue(
        <String>['BusinessPartnerCode', 'businessPartnerCode'],
      ),
      businessPartnerName: readValue(
        <String>['BusinessPartnerName', 'businessPartnerName'],
      ),
      rowNo: readValue(<String>['RowNo', 'rowNo']),
      mfrSerialNo: readValue(<String>['MfrSerialNo', 'mfrSerialNo']),
      serialNumber: readValue(<String>['SerialNumber', 'serialNumber']),
      itemNo: readValue(<String>['ItemNo', 'itemNo']),
      itemDescription: readValue(<String>['ItemDescription', 'itemDescription']),
      email: readValue(<String>['Email', 'email']),
      phone: readValue(<String>['Phone', 'phone']),
    );
  }
}
