# Charity Management Flutter Architecture

This project follows a feature-first, scalable architecture with clear separation between shared/core concerns and feature modules.

## Folder Structure

```text
lib/
  app.dart
  main.dart

  core/
    config/
      env/
        app_env.dart
    errors/
      app_exception.dart

  models/
    app_notification.dart
    campaign.dart
    charity_stats.dart
    donation.dart
    user_profile.dart
    user_role.dart

  repositories/
    auth_repository.dart
    campaign_repository.dart
    dashboard_repository.dart
    donation_repository.dart
    notification_repository.dart
    profile_repository.dart

  routing/
    app_router.dart
    app_routes.dart

  services/
    network/
      api_client.dart
      api_response.dart
      dio_api_client.dart
      network_providers.dart

  shared/
    mock_data/
      mock_dashboard_stats.dart
      mock_donations.dart
      mock_notifications.dart
      mock_users.dart
    state/
      app_async_state.dart
    widgets/
      app_navigation_drawer.dart
      app_scaffold.dart
      async_value_view.dart
      empty_state.dart

  theme/
    app_theme.dart

  features/
    authentication/
      data/
        local/
          auth_local_storage.dart
        mock_auth_repository.dart
      domain/
        models/
          auth_bootstrap_data.dart
          auth_failure.dart
          auth_state.dart
          auth_status.dart
          login_request.dart
          register_request.dart
      presentation/
        providers/
          auth_provider.dart
        utils/
          auth_validators.dart
        screens/
          splash_screen.dart
          onboarding_screen.dart
          role_selection_screen.dart
          login_screen.dart
          register_screen.dart
          forgot_password_screen.dart
        widgets/
          auth_error_message.dart
          auth_form_card.dart
          auth_primary_button.dart
          auth_role_card.dart
          auth_screen_shell.dart
          auth_text_field.dart

    campaigns/
      data/
        local/
          campaign_local_storage.dart
        mock/
          mock_campaigns_data.dart
        mock_campaign_repository.dart
      domain/
        campaign_filters.dart
      presentation/
        providers/
          campaign_detail_provider.dart
          campaign_filters_provider.dart
          campaign_follow_provider.dart
          campaign_repository_provider.dart
          campaigns_list_provider.dart
        screens/
          campaign_detail_screen.dart
          campaigns_screen.dart
        utils/
          campaign_formatters.dart
        widgets/
          campaign_card.dart
          campaign_category_filter.dart
          campaign_list_loading.dart
          campaign_search_bar.dart

    donations/
      data/
        mock_donation_repository.dart
      domain/
        donation_filters.dart
      presentation/
        screens/
          donations_screen.dart

    notifications/
      data/
        mock_notification_repository.dart
      domain/
        notification_filters.dart
      presentation/
        screens/
          notifications_screen.dart

    profile/
      data/
        mock_profile_repository.dart
      domain/
        profile_form_state.dart
      presentation/
        screens/
          profile_screen.dart

    charity_dashboard/
      data/
        mock_dashboard_repository.dart
      domain/
        dashboard_period.dart
      presentation/
        screens/
          charity_dashboard_screen.dart
```

## Conventions

- Keep features independent: no direct imports between feature modules.
- Shared contracts go in `models/` and `repositories/`.
- Feature implementations go in `features/<feature>/data`.
- UI state uses Riverpod providers in `features/<feature>/presentation/providers`.
- Navigation paths are centralized in `routing/app_routes.dart`.
- All network calls must go through `ApiClient` abstraction.
- Mock data for local development belongs in `shared/mock_data/`.
- Use immutable model classes with `toJson`/`fromJson` and `copyWith` style to stay compatible with future `freezed` + `json_serializable` migration.

## Environment Setup

Use `--dart-define` to control env at runtime:

```bash
flutter run --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=https://api.example.com
```

Supported environments:
- `dev`
- `staging`
- `prod`

## Extension Guidelines

When adding a new feature:

1. Create `features/<feature>/data`, `domain`, `presentation`.
2. Add repository contract if shared, otherwise keep it within feature domain.
3. Add mock implementation first to validate UX and state handling.
4. Add provider(s) in presentation layer.
5. Add route entry in `app_router.dart` and path in `app_routes.dart`.
6. Use `AsyncValueView`/`AsyncValueX` for consistent loading and error handling.
