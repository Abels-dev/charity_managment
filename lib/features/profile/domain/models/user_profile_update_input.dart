class UserProfileUpdateInput {
  const UserProfileUpdateInput({
    required this.name,
    required this.phone,
    required this.bio,
  });

  final String name;
  final String? phone;
  final String? bio;
}
