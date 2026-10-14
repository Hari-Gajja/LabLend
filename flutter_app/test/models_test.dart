import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/models/equipment_model.dart';
import 'package:flutter_app/models/institution_model.dart';
import 'package:flutter_app/models/request_model.dart';
import 'package:flutter_app/models/user_model.dart';

void main() {
  group('Models Serialization Tests', () {
    test('InstitutionModel parses JSON and generates correct display string', () {
      final json = {
        '_id': 'inst_123',
        'name': 'Stanford Bioengineering',
        'type': 'university',
        'city': 'Stanford',
        'state': 'CA',
        'verificationStatus': 'verified',
      };

      final inst = InstitutionModel.fromJson(json);
      expect(inst.id, 'inst_123');
      expect(inst.name, 'Stanford Bioengineering');
      expect(inst.locationDisplay, 'Stanford, CA');
      expect(inst.isVerified, isTrue);
    });

    test('UserModel parses nested institution and handles password exclusion', () {
      final json = {
        '_id': 'user_123',
        'fullName': 'Dr. Elena Rostova',
        'email': 'erostova@stanford.edu',
        'role': 'lab_admin',
        'institution': {
          '_id': 'inst_123',
          'name': 'Stanford Bioengineering',
          'city': 'Stanford',
          'state': 'CA',
          'verificationStatus': 'verified',
        },
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 'user_123');
      expect(user.fullName, 'Dr. Elena Rostova');
      expect(user.isLabAdmin, isTrue);
      expect(user.institution?.name, 'Stanford Bioengineering');
    });

    test('EquipmentModel computes rental rates and covers correctly', () {
      final json = {
        '_id': 'eq_1',
        'title': 'Olympus IX83 Inverted Microscope',
        'description': 'High-resolution imaging',
        'category': 'microscopy',
        'condition': 'like_new',
        'listingType': 'both',
        'rentalPrice': 75,
        'rentalPricingUnit': 'hour',
        'purchasePrice': 42000,
        'availability': 'available',
        'location': {'city': 'Stanford', 'state': 'CA'},
        'images': [
          {'url': 'https://example.com/cover.jpg', 'publicId': 'cov_1', 'isCover': true},
        ],
        'technicalSpecs': [
          {'key': 'Magnification', 'value': '100x TIRF'},
        ],
      };

      final equip = EquipmentModel.fromJson(json);
      expect(equip.canRent, isTrue);
      expect(equip.canBuy, isTrue);
      expect(equip.rentalRateDisplay, '\$75/hour');
      expect(equip.coverImageUrl, 'https://example.com/cover.jpg');
      expect(equip.technicalSpecs.first.key, 'Magnification');
    });

    test('RequestModel handles status helpers and rental flags', () {
      final json = {
        '_id': 'req_123',
        'requestType': 'rental',
        'status': 'pending',
        'intendedUse': 'Live cell observation protocol',
      };

      final req = RequestModel.fromJson(json);
      expect(req.isRental, isTrue);
      expect(req.isPending, isTrue);
      expect(req.isApproved, isFalse);
    });
  });
}
