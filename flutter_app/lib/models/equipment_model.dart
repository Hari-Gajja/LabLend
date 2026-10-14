import 'institution_model.dart';
import 'user_model.dart';

class EquipmentImage {
  final String url;
  final String publicId;
  final bool isCover;

  EquipmentImage({
    required this.url,
    required this.publicId,
    this.isCover = false,
  });

  factory EquipmentImage.fromJson(Map<String, dynamic> json) {
    return EquipmentImage(
      url: json['url'] ?? '',
      publicId: json['publicId'] ?? '',
      isCover: json['isCover'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'publicId': publicId,
      'isCover': isCover,
    };
  }
}

class EquipmentLocation {
  final String building;
  final String room;
  final String city;
  final String state;

  EquipmentLocation({
    this.building = '',
    this.room = '',
    required this.city,
    required this.state,
  });

  String get shortDisplay => '$city, $state';
  String get fullDisplay {
    final parts = [building, room, city, state].where((p) => p.isNotEmpty).toList();
    return parts.join(', ');
  }

  factory EquipmentLocation.fromJson(Map<String, dynamic> json) {
    return EquipmentLocation(
      building: json['building'] ?? '',
      room: json['room'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'building': building,
      'room': room,
      'city': city,
      'state': state,
    };
  }
}

class TechnicalSpec {
  final String key;
  final String value;

  TechnicalSpec({required this.key, required this.value});

  factory TechnicalSpec.fromJson(Map<String, dynamic> json) {
    return TechnicalSpec(
      key: json['key'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'key': key, 'value': value};
}

class EquipmentModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String condition;
  final List<TechnicalSpec> technicalSpecs;
  final List<EquipmentImage> images;
  final String listingType;
  final num? rentalPrice;
  final String rentalPricingUnit;
  final num? purchasePrice;
  final String availability;
  final EquipmentLocation location;
  final UserModel? ownerUser;
  final String? ownerUserId;
  final InstitutionModel? ownerInstitution;
  final String? ownerInstitutionId;
  final bool featured;
  final bool isArchived;
  final int totalBookings;
  final DateTime? createdAt;

  EquipmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.condition = 'excellent',
    this.technicalSpecs = const [],
    this.images = const [],
    this.listingType = 'rent',
    this.rentalPrice,
    this.rentalPricingUnit = 'day',
    this.purchasePrice,
    this.availability = 'available',
    required this.location,
    this.ownerUser,
    this.ownerUserId,
    this.ownerInstitution,
    this.ownerInstitutionId,
    this.featured = false,
    this.isArchived = false,
    this.totalBookings = 0,
    this.createdAt,
  });

  String get coverImageUrl {
    if (images.isEmpty) return '';
    final cover = images.firstWhere((img) => img.isCover, orElse: () => images.first);
    return cover.url;
  }

  bool get canRent => listingType == 'rent' || listingType == 'both';
  bool get canBuy => listingType == 'buy' || listingType == 'both';
  bool get isAvailable => availability == 'available';

  String get rentalRateDisplay {
    if (rentalPrice == null) return '';
    return '\$${rentalPrice!.toInt()}/$rentalPricingUnit';
  }

  String get purchasePriceDisplay {
    if (purchasePrice == null) return '';
    return '\$${purchasePrice!.toInt()}';
  }

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    UserModel? user;
    String? userId;
    if (json['ownerUser'] is Map<String, dynamic>) {
      user = UserModel.fromJson(json['ownerUser']);
      userId = user.id;
    } else if (json['ownerUser'] is String) {
      userId = json['ownerUser'];
    }

    InstitutionModel? institution;
    String? instId;
    if (json['ownerInstitution'] is Map<String, dynamic>) {
      institution = InstitutionModel.fromJson(json['ownerInstitution']);
      instId = institution.id;
    } else if (json['ownerInstitution'] is String) {
      instId = json['ownerInstitution'];
    }

    final imagesList = (json['images'] as List<dynamic>? ?? [])
        .map((img) => EquipmentImage.fromJson(img as Map<String, dynamic>))
        .toList();

    final specsList = (json['technicalSpecs'] as List<dynamic>? ?? [])
        .map((s) => TechnicalSpec.fromJson(s as Map<String, dynamic>))
        .toList();

    return EquipmentModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'general_lab',
      condition: json['condition'] ?? 'excellent',
      technicalSpecs: specsList,
      images: imagesList,
      listingType: json['listingType'] ?? 'rent',
      rentalPrice: json['rentalPrice'],
      rentalPricingUnit: json['rentalPricingUnit'] ?? 'day',
      purchasePrice: json['purchasePrice'],
      availability: json['availability'] ?? 'available',
      location: json['location'] != null
          ? EquipmentLocation.fromJson(json['location'] as Map<String, dynamic>)
          : EquipmentLocation(city: 'Unknown', state: 'Unknown'),
      ownerUser: user,
      ownerUserId: userId,
      ownerInstitution: institution,
      ownerInstitutionId: instId,
      featured: json['featured'] ?? false,
      isArchived: json['isArchived'] ?? false,
      totalBookings: json['totalBookings'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'condition': condition,
      'technicalSpecs': technicalSpecs.map((s) => s.toJson()).toList(),
      'images': images.map((i) => i.toJson()).toList(),
      'listingType': listingType,
      'rentalPrice': rentalPrice,
      'rentalPricingUnit': rentalPricingUnit,
      'purchasePrice': purchasePrice,
      'availability': availability,
      'location': location.toJson(),
      'featured': featured,
    };
  }
}
