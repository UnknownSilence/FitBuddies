import 'package:flutter_test/flutter_test.dart';
import 'package:hardyfit/models/user.dart';
import 'package:hardyfit/services/user_service.dart';

void main() {
  late MockUserService mockUserService;

  setUp(() {
    mockUserService = MockUserService();
  });

  group('UserService', () {
    test('getCurrentUser returns the current user', () async {
      final user = await mockUserService.getCurrentUser();

      expect(user, isA<User>());
      expect(user.id, 'user1');
      expect(user.name, 'Alex Johnson');
      expect(user.email, 'alex@example.com');
    });

    test('getPotentialPartners returns a list of users', () async {
      final partners = await mockUserService.getPotentialPartners();

      expect(partners, isA<List<User>>());
      expect(partners.length, 3); // Based on the mock implementation

      // Check first potential partner
      expect(partners[0].id, 'user2');
      expect(partners[0].name, 'Jamie Smith');

      // All partners should have different IDs
      final partnerIds = partners.map((p) => p.id).toSet();
      expect(partnerIds.length, partners.length);
    });

    test('matchWithPartner sets partner IDs for both users', () async {
      final partnerId = 'user2';

      // Before matching
      final currentUser = await mockUserService.getCurrentUser();
      expect(currentUser.accountabilityPartnerId, null);

      // Perform matching
      final result = await mockUserService.matchWithPartner(partnerId);
      expect(result, true);

      // After matching
      final updatedUser = await mockUserService.getCurrentUser();
      final partner = await mockUserService.getPartnerProfile(partnerId);

      // Check bidirectional connection
      expect(updatedUser.accountabilityPartnerId, partnerId);
      expect(partner?.accountabilityPartnerId, updatedUser.id);
    });

    test('getPartnerProfile returns the correct partner', () async {
      final partnerId = 'user3';
      final partner = await mockUserService.getPartnerProfile(partnerId);

      expect(partner, isNotNull);
      expect(partner!.id, partnerId);
      expect(partner.name, 'Taylor Wilson');
    });

    test('getPartnerProfile returns null for nonexistent partner', () async {
      final partner = await mockUserService.getPartnerProfile('nonexistent-id');
      expect(partner, null);
    });
  });
}
