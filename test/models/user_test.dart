import 'package:flutter_test/flutter_test.dart';
import 'package:hardyfit/models/user.dart';

void main() {
  group('User', () {
    test('should create a User instance with correct values', () {
      final user = User(
        id: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
        profileImageUrl: 'http://example.com/image.jpg',
        interests: ['Running', 'Yoga'],
        fitnessLevel: 'intermediate',
        fitnessGoals: ['Weight Loss', 'Muscle Gain'],
      );

      expect(user.id, 'test-id');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.profileImageUrl, 'http://example.com/image.jpg');
      expect(user.interests, ['Running', 'Yoga']);
      expect(user.fitnessLevel, 'intermediate');
      expect(user.fitnessGoals, ['Weight Loss', 'Muscle Gain']);
      expect(user.accountabilityPartnerId, null);
    });

    test('should create a User with non-null accountabilityPartnerId', () {
      final user = User(
        id: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
        profileImageUrl: 'http://example.com/image.jpg',
        interests: ['Running'],
        fitnessLevel: 'beginner',
        fitnessGoals: ['Weight Loss'],
        accountabilityPartnerId: 'partner-id',
      );

      expect(user.accountabilityPartnerId, 'partner-id');
    });

    test('should correctly create a User from JSON', () {
      final json = {
        'id': 'json-id',
        'name': 'JSON User',
        'email': 'json@example.com',
        'profileImageUrl': 'http://example.com/json.jpg',
        'interests': ['Swimming', 'Cycling'],
        'fitnessLevel': 'advanced',
        'fitnessGoals': ['Endurance'],
        'accountabilityPartnerId': 'json-partner-id',
      };

      final user = User.fromJson(json);

      expect(user.id, 'json-id');
      expect(user.name, 'JSON User');
      expect(user.email, 'json@example.com');
      expect(user.profileImageUrl, 'http://example.com/json.jpg');
      expect(user.interests, ['Swimming', 'Cycling']);
      expect(user.fitnessLevel, 'advanced');
      expect(user.fitnessGoals, ['Endurance']);
      expect(user.accountabilityPartnerId, 'json-partner-id');
    });

    test('should correctly convert a User to JSON', () {
      final user = User(
        id: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
        profileImageUrl: 'http://example.com/image.jpg',
        interests: ['Running', 'Yoga'],
        fitnessLevel: 'intermediate',
        fitnessGoals: ['Weight Loss'],
        accountabilityPartnerId: 'partner-id',
      );

      final json = user.toJson();

      expect(json['id'], 'test-id');
      expect(json['name'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json['profileImageUrl'], 'http://example.com/image.jpg');
      expect(json['interests'], ['Running', 'Yoga']);
      expect(json['fitnessLevel'], 'intermediate');
      expect(json['fitnessGoals'], ['Weight Loss']);
      expect(json['accountabilityPartnerId'], 'partner-id');
    });

    test('should create a new User using copyWith', () {
      final user = User(
        id: 'original-id',
        name: 'Original Name',
        email: 'original@example.com',
        profileImageUrl: 'http://example.com/original.jpg',
        interests: ['Running'],
        fitnessLevel: 'beginner',
        fitnessGoals: ['Weight Loss'],
      );

      final updatedUser = user.copyWith(
        name: 'Updated Name',
        fitnessLevel: 'intermediate',
        accountabilityPartnerId: 'new-partner-id',
      );

      // Original properties should remain unchanged
      expect(user.name, 'Original Name');
      expect(user.fitnessLevel, 'beginner');
      expect(user.accountabilityPartnerId, null);

      // New object should have updated properties
      expect(updatedUser.id, 'original-id'); // Unchanged
      expect(updatedUser.name, 'Updated Name'); // Changed
      expect(updatedUser.email, 'original@example.com'); // Unchanged
      expect(
        updatedUser.profileImageUrl,
        'http://example.com/original.jpg',
      ); // Unchanged
      expect(updatedUser.interests, ['Running']); // Unchanged
      expect(updatedUser.fitnessLevel, 'intermediate'); // Changed
      expect(updatedUser.fitnessGoals, ['Weight Loss']); // Unchanged
      expect(updatedUser.accountabilityPartnerId, 'new-partner-id'); // Changed
    });
  });
}
