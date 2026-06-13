/// Top-level barrel for the shared package — app-agnostic primitives only:
/// core infra (api, auth-service, config, utils, widgets), domain constants,
/// domain models, and theme. No application logic (controllers/views/routing).
library;

export 'core/core.dart';
export 'domain/domain.dart';
export 'models/models.dart';
export 'theme/theme.dart';
