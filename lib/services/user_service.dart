import '../models/user.dart';

abstract class UserService {
  Future<User> getCurrentUser();
  Future<List<User>> getPotentialPartners();
  Future<bool> matchWithPartner(String partnerId);
  Future<User?> getPartnerProfile(String partnerId);
}

class MockUserService implements UserService {
  final User _currentUser = User(
    id: 'user1',
    name: 'Alex Johnson',
    email: 'alex@example.com',
    profileImageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    interests: ['Running', 'Weight Training', 'Yoga'],
    fitnessLevel: 'intermediate',
    fitnessGoals: ['Build Muscle', 'Improve Endurance'],
    accountabilityPartnerId: 'user2',
  );

  final List<User> _potentialPartners = [
    User(
      id: 'user2',
      name: 'Jamie Smith',
      email: 'jamie@example.com',
      profileImageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
      interests: ['Running', 'CrossFit', 'Swimming'],
      fitnessLevel: 'intermediate',
      fitnessGoals: ['Weight Loss', 'Improve Endurance'],
      accountabilityPartnerId: 'user1',
    ),
    User(
      id: 'user3',
      name: 'Taylor Wilson',
      email: 'taylor@example.com',
      profileImageUrl: 'https://randomuser.me/api/portraits/men/67.jpg',
      interests: ['Weight Training', 'Mountain Biking'],
      fitnessLevel: 'advanced',
      fitnessGoals: ['Build Muscle', 'Strength Training'],
    ),
    User(
      id: 'user4',
      name: 'Morgan Lee',
      email: 'morgan@example.com',
      profileImageUrl: 'https://randomuser.me/api/portraits/women/29.jpg',
      interests: ['Yoga', 'Pilates', 'Hiking'],
      fitnessLevel: 'beginner',
      fitnessGoals: ['Flexibility', 'Wellness'],
    ),
  ];

  @override
  Future<User> getCurrentUser() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentUser;
  }

  @override
  Future<List<User>> getPotentialPartners() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _potentialPartners;
  }

  @override
  Future<bool> matchWithPartner(String partnerId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Update current user's partner
    _currentUser.accountabilityPartnerId = partnerId;

    // Find partner and update their partner as well
    final partner = _potentialPartners.firstWhere(
      (user) => user.id == partnerId,
    );
    partner.accountabilityPartnerId = _currentUser.id;

    return true;
  }

  @override
  Future<User?> getPartnerProfile(String partnerId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _potentialPartners.firstWhere((user) => user.id == partnerId);
    } catch (e) {
      return null;
    }
  }
}
