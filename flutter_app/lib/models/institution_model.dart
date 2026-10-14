class InstitutionModel {
  final String id;
  final String name;
  final String type;
  final String description;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String contactEmail;
  final String contactNumber;
  final String verificationStatus;
  final DateTime? createdAt;

  InstitutionModel({
    required this.id,
    required this.name,
    this.type = 'university',
    this.description = '',
    this.address = '',
    required this.city,
    required this.state,
    this.postalCode = '',
    this.country = 'United States',
    this.contactEmail = '',
    this.contactNumber = '',
    this.verificationStatus = 'unverified',
    this.createdAt,
  });

  bool get isVerified => verificationStatus == 'verified';

  String get locationDisplay => '$city, $state';

  factory InstitutionModel.fromJson(Map<String, dynamic> json) {
    return InstitutionModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'university',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
      country: json['country'] ?? 'United States',
      contactEmail: json['contactEmail'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      verificationStatus: json['verificationStatus'] ?? 'unverified',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'contactEmail': contactEmail,
      'contactNumber': contactNumber,
      'verificationStatus': verificationStatus,
    };
  }
}
