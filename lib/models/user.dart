class User {
  final String id;
  final String name;
  final String email;
  final String profileImageUrl;
  final List<String> interests;
  final String fitnessLevel; // beginner, intermediate, advanced
  final List<String> fitnessGoals;
  String? accountabilityPartnerId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImageUrl,
    required this.interests,
    required this.fitnessLevel,
    required this.fitnessGoals,
    this.accountabilityPartnerId,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    List<String>? interests,
    String? fitnessLevel,
    List<String>? fitnessGoals,
    String? accountabilityPartnerId,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      interests: interests ?? this.interests,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      fitnessGoals: fitnessGoals ?? this.fitnessGoals,
      accountabilityPartnerId:
          accountabilityPartnerId ?? this.accountabilityPartnerId,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImageUrl: json['profileImageUrl'],
      interests: List<String>.from(json['interests']),
      fitnessLevel: json['fitnessLevel'],
      fitnessGoals: List<String>.from(json['fitnessGoals']),
      accountabilityPartnerId: json['accountabilityPartnerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'interests': interests,
      'fitnessLevel': fitnessLevel,
      'fitnessGoals': fitnessGoals,
      'accountabilityPartnerId': accountabilityPartnerId,
    };
  }
}
