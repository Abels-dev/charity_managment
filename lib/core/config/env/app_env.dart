import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppEnvironment { dev, staging, prod }

class AppEnv {
  const AppEnv({
    required this.environment,
    required this.baseUrl,
    required this.connectTimeoutMs,
    required this.receiveTimeoutMs,
  });

  final AppEnvironment environment;
  final String baseUrl;
  final int connectTimeoutMs;
  final int receiveTimeoutMs;

  bool get isProduction => environment == AppEnvironment.prod;

  factory AppEnv.fromDefines() {
    const envRaw = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    const baseUrlRaw = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:5000',
    );

    final env = switch (envRaw) {
      'prod' => AppEnvironment.prod,
      'staging' => AppEnvironment.staging,
      _ => AppEnvironment.dev,
    };

    return AppEnv(
      environment: env,
      baseUrl: baseUrlRaw,
      connectTimeoutMs: 15000,
      receiveTimeoutMs: 20000,
    );
  }
}

final appEnvProvider = Provider<AppEnv>((ref) => AppEnv.fromDefines());
