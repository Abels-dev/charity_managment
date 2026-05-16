class CharityProfileUpdateInput {
  const CharityProfileUpdateInput({
    required this.organizationName,
    required this.description,
    required this.phone,
    required this.website,
    required this.address,
  });

  final String organizationName;
  final String? description;
  final String? phone;
  final String? website;
  final String? address;
}
