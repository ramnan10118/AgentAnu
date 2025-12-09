class AssetModel {
  final String id;
  final String userId;
  final String type;
  final String provider;
  final String accountNumber;
  final double value;
  final String currency;
  final Map<String, dynamic> details;
  final String source;
  final String asOf;
  final bool isRevealed;

  AssetModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.provider,
    required this.accountNumber,
    required this.value,
    required this.currency,
    required this.details,
    required this.source,
    required this.asOf,
    this.isRevealed = false,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      provider: json['provider'] as String,
      accountNumber: json['accountNumber'] as String,
      value: (json['value'] as num).toDouble(),
      currency: json['currency'] as String,
      details: json['details'] as Map<String, dynamic>,
      source: json['source'] as String,
      asOf: json['asOf'] as String,
      isRevealed: json['isRevealed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'provider': provider,
      'accountNumber': accountNumber,
      'value': value,
      'currency': currency,
      'details': details,
      'source': source,
      'asOf': asOf,
      'isRevealed': isRevealed,
    };
  }

  String get assetTypeLabel {
    switch (type) {
      case 'bank_account':
        return 'Bank Account';
      case 'mutual_fund':
        return 'Mutual Fund';
      case 'insurance':
        return 'Insurance';
      case 'fd':
        return 'Fixed Deposit';
      case 'nps':
        return 'NPS';
      case 'securities':
        return 'Securities';
      case 'loan':
        return details['loanType'] as String? ?? 'Loan';
      default:
        return type;
    }
  }
  
  bool get isLiability {
    return type == 'loan' || value < 0;
  }

  String get formattedValue {
    if (currency == 'INR') {
      return '₹${value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )}';
    }
    return '$currency ${value.toStringAsFixed(2)}';
  }
}

