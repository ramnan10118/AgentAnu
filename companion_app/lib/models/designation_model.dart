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
      id: json['id'] as String,
      accountHolderId: json['accountHolderId'] as String,
      accountHolderName: json['accountHolderName'] as String?,
      accountHolderMobile: json['accountHolderMobile'] as String?,
      nokMobile: json['nokMobile'] as String,
      nokName: json['nokName'] as String,
      relationship: json['relationship'] as String,
      status: json['status'] as String,
      designatedAt: json['designatedAt'] as String,
      respondedAt: json['respondedAt'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
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

