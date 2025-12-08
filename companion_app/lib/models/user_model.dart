class UserModel {
  final String id;
  final String mobile;
  final String? name;
  final String? email;
  final String? pan;
  final String role;
  final bool consentedAnumati;
  final String? nokDesignationId;

  UserModel({
    required this.id,
    required this.mobile,
    this.name,
    this.email,
    this.pan,
    required this.role,
    this.consentedAnumati = false,
    this.nokDesignationId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      mobile: json['mobile'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      pan: json['pan'] as String?,
      role: json['role'] as String,
      consentedAnumati: json['consentedAnumati'] as bool? ?? false,
      nokDesignationId: json['nokDesignationId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobile': mobile,
      'name': name,
      'email': email,
      'pan': pan,
      'role': role,
      'consentedAnumati': consentedAnumati,
      'nokDesignationId': nokDesignationId,
    };
  }

  UserModel copyWith({
    String? id,
    String? mobile,
    String? name,
    String? email,
    String? pan,
    String? role,
    bool? consentedAnumati,
    String? nokDesignationId,
  }) {
    return UserModel(
      id: id ?? this.id,
      mobile: mobile ?? this.mobile,
      name: name ?? this.name,
      email: email ?? this.email,
      pan: pan ?? this.pan,
      role: role ?? this.role,
      consentedAnumati: consentedAnumati ?? this.consentedAnumati,
      nokDesignationId: nokDesignationId ?? this.nokDesignationId,
    );
  }
}

