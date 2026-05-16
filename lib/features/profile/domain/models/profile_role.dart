enum ProfileRole {
  donor,
  charity;

  String get value => switch (this) {
        ProfileRole.donor => 'DONOR',
        ProfileRole.charity => 'CHARITY',
      };

  String get label => switch (this) {
        ProfileRole.donor => 'Donor',
        ProfileRole.charity => 'Charity',
      };

  static ProfileRole fromJson(String value) {
    return ProfileRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => ProfileRole.donor,
    );
  }
}
