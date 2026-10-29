class UserProfile {
  final String fullName;
  final String email;
  final String phone;

  const UserProfile({
    required this.fullName,
    required this.email,
    required this.phone,
  });

  // dummyjson.com/users/1 returns firstName, lastName, email, phone
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        fullName: '${json['firstName']} ${json['lastName']}',
        email: json['email'] as String,
        phone: json['phone'] as String,
      );
}
