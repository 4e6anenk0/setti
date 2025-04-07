import 'setti_error.dart';
import 'setti_exception.dart';
import 'setti_warning.dart';

class NotUniqueIdException extends SettiException {
  NotUniqueIdException({
    required super.msg,
    super.solutionMsg,
    super.label = "Not Unique ID",
    super.stackTrace,
    super.isPretty,
  });
}

class AdapterException extends SettiException {
  AdapterException({
    required super.msg,
    super.solutionMsg,
    super.label = "Adapter Exception",
    super.stackTrace,
    super.isPretty,
  });
}

class InitializationError extends SettiError {
  InitializationError({
    required super.msg,
    super.label = "Initialization Error",
    super.solutionMsg,
    super.stackTrace,
    super.isPretty,
  });
}

class SettingNotFoundException extends SettiException {
  SettingNotFoundException({
    required super.msg,
    super.label = "Setting not found",
    super.solutionMsg,
    super.stackTrace,
    super.isPretty,
  });
}

class LocalStorageException extends SettiException {
  LocalStorageException({
    required super.msg,
    super.label = "Local Storage Exception",
    super.solutionMsg,
    super.stackTrace,
    super.isPretty,
  });
}

class AppDataPathProviderException extends SettiException {
  AppDataPathProviderException({
    required super.msg,
    super.label = "Platform specific AppData can't be processed correctly",
    super.solutionMsg,
    super.stackTrace,
    super.isPretty,
  });
}

class ControllerException extends SettiException {
  ControllerException({
    required super.msg,
    super.label = "Invalid Operation",
    super.solutionMsg,
    super.stackTrace,
    super.isPretty,
  });
}

/* InvalidOperationException

class SettingNotFoundException implements Exception {
  final String settingId;

  SettingNotFoundException(this.settingId);

  @override
  String toString() =>
      'SettingNotFoundException: Setting with id "$settingId" not found.';
}

class LocalStorageException implements Exception {
  LocalStorageException(this.message);

  final String message;

  @override
  String toString() {
    return "LocalStorageException: $message.";
  }
}
 */
