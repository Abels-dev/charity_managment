enum UserRole {
  donor,
  charityOrganization;

  String get value => switch (this) {
        UserRole.donor => 'donor',
        UserRole.charityOrganization => 'charity_organization',
      };

  String get label => switch (this) {
        UserRole.donor => 'Donor',
        UserRole.charityOrganization => 'Charity Organization',
      };

  static UserRole fromJson(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.donor,
    );
  }
}
