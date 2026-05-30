# Charity Management Mobile App

Flutter mobile client for the Charity Management platform.

## Main Functionalities

- Public home with campaign browsing and charity public profiles
- Authentication flow (splash, onboarding, role selection, login, register)
- Donor and Charity role-based navigation/permissions
- Campaign features: discover, view details, follow, and (charity) create/edit/manage
- Donation features: donate, view donation history, detail, success, and receipt screens
- Charity tools: dashboard, contributions, campaign requests, and bank account management
- User features: profile view/edit and in-app notifications

## Tech Stack

- Flutter
- Riverpod (state management)
- GoRouter (navigation)
- Dio (API layer)

## Project Structure

Feature-first architecture with clear module boundaries:

- `core/` app config and shared exceptions
- `features/` domain-specific modules (auth, campaigns, donations, etc.)
- `routing/` centralized app routes
- `services/network/` API abstractions
- `shared/` reusable widgets/state/mock data

## Test Credentials

Charity registration is not currently handled in the mobile app. To access the Charity flow, please use this pre-created account:

**Charity Account:**
- Email: `charitytwo@charity.com` 📋
- Password: `Charity123` 📋

**Donor Account:**

For Donor access, you can either use this test account or register a new donor directly in the app:

- Email: `donortwo@donor.com` 📋
- Password: `Ddonor123` 📋

*(Click the 📋 icon next to each credential to copy to clipboard)*

## Run Locally

```bash
flutter pub get
flutter run
```
