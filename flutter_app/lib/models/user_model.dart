import 'institution_model.dart';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String contactNumber;
  final String department;
  final String title;
  final String role;
  final String accountStatus;
  final String avatarUrl;
  final InstitutionModel? institution;
  final String? institutionId;
  final DateTime? lastLogin;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.contactNumber = '',
    this.department = '',
    this.title = 'Researcher',
    this.role = 'researcher',
    this.accountStatus = 'active',
    this.avatarUrl = '',
    this.institution,
    this.institutionId,
    this.lastLogin,
    this.createdAt,
  });

  bool get isActive => accountStatus == 'active';
  bool get isLabAdmin => role == 'lab_admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    InstitutionModel? inst;
    String? instId;

    if (json['institution'] is Map<String, dynamic>) {
      inst = InstitutionModel.fromJson(json['institution']);
      instId = inst.id;
    } else if (json['institution'] is String) {
      instId = json['institution'];
    }

    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      department: json['department'] ?? '',
      title: json['title'] ?? 'Researcher',
      role: json['role'] ?? 'researcher',
      accountStatus: json['accountStatus'] ?? 'active',
      avatarUrl: json['avatarUrl'] ?? '',
      institution: inst,
      institutionId: instId,
      lastLogin: json['lastLogin'] != null ? DateTime.tryParse(json['lastLogin']) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'contactNumber': contactNumber,
      'department': department,
      'title': title,
      'role': role,
      'accountStatus': accountStatus,
      'avatarUrl': avatarUrl,
      'institution': institution?.toJson() ?? institutionId,
    };
  }
}
