import 'package:charity_managment/models/user_profile.dart';
import 'package:charity_managment/models/user_role.dart';

const donorUser = UserProfile(
  id: 'u_donor_01',
  fullName: 'Alex Donor',
  email: 'donor@charity.app',
  role: UserRole.donor,
);

const organizationUser = UserProfile(
  id: 'u_org_01',
  fullName: 'Hope Foundation',
  email: 'org@charity.app',
  role: UserRole.charityOrganization,
);
