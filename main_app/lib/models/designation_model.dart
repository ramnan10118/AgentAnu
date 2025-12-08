class DesignationModel {
  final String id;
  final String accountHolderId;
  final String? accountHolderName;
  final String? accountHolderMobile;
  final String nokMobile;
  final String nokName;
  final String relationship;
  final String status;
  final String designatedAt;
  final String? respondedAt;
  final String? rejectionReason;

  DesignationModel({
    required this.id,
    required this.accountHolderId,
    this.accountHolderName,
    this.accountHolderMobile,
    required this.nokMobile,
    required this.nokName,
    required this.relationship,
    required this.status,
    required this.designatedAt,
    this.respondedAt,
    this.rejectionReason,
  });

  factory DesignationModel.fromJson(Map<String, dynamic> json) {
    return DesignationModel(
      id: json['id']?.toString() ?? '',
      accountHolderId: json['accountHolderId']?.toString() ?? '',
      accountHolderName: json['accountHolderName']?.toString(),
      accountHolderMobile: json['accountHolderMobile']?.toString(),
      nokMobile: json['nokMobile']?.toString() ?? '',
      nokName: json['nokName']?.toString() ?? '',
      relationship: json['relationship']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      designatedAt: json['designatedAt']?.toString() ?? DateTime.now().toIso8601String(),
      respondedAt: json['respondedAt']?.toString(),
      rejectionReason: json['rejectionReason']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountHolderId': accountHolderId,
      'accountHolderName': accountHolderName,
      'accountHolderMobile': accountHolderMobile,
      'nokMobile': nokMobile,
      'nokName': nokName,
      'relationship': relationship,
      'status': status,
      'designatedAt': designatedAt,
      'respondedAt': respondedAt,
      'rejectionReason': rejectionReason,
    };
  }

  String get relationshipLabel {
    return relationship[0].toUpperCase() + relationship.substring(1);
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
}

