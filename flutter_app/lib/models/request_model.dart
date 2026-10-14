import 'equipment_model.dart';
import 'institution_model.dart';
import 'user_model.dart';

class RequestModel {
  final String id;
  final UserModel? requesterUser;
  final String? requesterUserId;
  final InstitutionModel? requesterInstitution;
  final String? requesterInstitutionId;
  final EquipmentModel? equipment;
  final String? equipmentId;
  final UserModel? listingOwner;
  final String? listingOwnerId;
  final String requestType; // 'rental' | 'purchase'
  final String status; // 'pending' | 'approved' | 'rejected' | 'cancelled' | 'completed'
  final int requestedQuantity;
  final DateTime? rentalStartDate;
  final DateTime? rentalEndDate;
  final String intendedUse;
  final String message;
  final Map<String, dynamic>? decisionMetadata;
  final Map<String, dynamic>? cancellationMetadata;
  final Map<String, dynamic>? completionMetadata;
  final DateTime? createdAt;

  RequestModel({
    required this.id,
    this.requesterUser,
    this.requesterUserId,
    this.requesterInstitution,
    this.requesterInstitutionId,
    this.equipment,
    this.equipmentId,
    this.listingOwner,
    this.listingOwnerId,
    required this.requestType,
    required this.status,
    this.requestedQuantity = 1,
    this.rentalStartDate,
    this.rentalEndDate,
    required this.intendedUse,
    this.message = '',
    this.decisionMetadata,
    this.cancellationMetadata,
    this.completionMetadata,
    this.createdAt,
  });

  bool get isRental => requestType == 'rental';
  bool get isPurchase => requestType == 'purchase';

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    UserModel? reqUser;
    String? reqUserId;
    if (json['requesterUser'] is Map<String, dynamic>) {
      reqUser = UserModel.fromJson(json['requesterUser']);
      reqUserId = reqUser.id;
    } else if (json['requesterUser'] is String) {
      reqUserId = json['requesterUser'];
    }

    InstitutionModel? reqInst;
    String? reqInstId;
    if (json['requesterInstitution'] is Map<String, dynamic>) {
      reqInst = InstitutionModel.fromJson(json['requesterInstitution']);
      reqInstId = reqInst.id;
    } else if (json['requesterInstitution'] is String) {
      reqInstId = json['requesterInstitution'];
    }

    EquipmentModel? equip;
    String? equipId;
    if (json['equipment'] is Map<String, dynamic>) {
      equip = EquipmentModel.fromJson(json['equipment']);
      equipId = equip.id;
    } else if (json['equipment'] is String) {
      equipId = json['equipment'];
    }

    UserModel? owner;
    String? ownerId;
    if (json['listingOwner'] is Map<String, dynamic>) {
      owner = UserModel.fromJson(json['listingOwner']);
      ownerId = owner.id;
    } else if (json['listingOwner'] is String) {
      ownerId = json['listingOwner'];
    }

    return RequestModel(
      id: json['_id'] ?? json['id'] ?? '',
      requesterUser: reqUser,
      requesterUserId: reqUserId,
      requesterInstitution: reqInst,
      requesterInstitutionId: reqInstId,
      equipment: equip,
      equipmentId: equipId,
      listingOwner: owner,
      listingOwnerId: ownerId,
      requestType: json['requestType'] ?? 'rental',
      status: json['status'] ?? 'pending',
      requestedQuantity: json['requestedQuantity'] ?? 1,
      rentalStartDate: json['rentalStartDate'] != null ? DateTime.tryParse(json['rentalStartDate']) : null,
      rentalEndDate: json['rentalEndDate'] != null ? DateTime.tryParse(json['rentalEndDate']) : null,
      intendedUse: json['intendedUse'] ?? '',
      message: json['message'] ?? '',
      decisionMetadata: json['decisionMetadata'] as Map<String, dynamic>?,
      cancellationMetadata: json['cancellationMetadata'] as Map<String, dynamic>?,
      completionMetadata: json['completionMetadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
