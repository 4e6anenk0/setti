import 'setti_error.dart';
import 'setti_exception.dart';

class NotUniqueIdException extends SettiException {
  NotUniqueIdException({
    required super.msg,
    super.solutionMsg,
    super.label = "Not Unique ID",
    super.stackTrace,
  });
}

class AdapterException extends SettiException {
  AdapterException({
    required super.msg,
    super.solutionMsg,
    super.label = "Adapter Exception",
    super.stackTrace,
  });
}

class InitializationError extends SettiError {
  InitializationError({
    required super.msg,
    super.label = "Initialization Error",
    super.solutionMsg,
    super.stackTrace,
  });
}

class SettingNotFoundException extends SettiException {
  SettingNotFoundException({
    required super.msg,
    super.label = "Setting not found",
    super.solutionMsg,
    super.stackTrace,
  });
}

class LocalStorageException extends SettiException {
  LocalStorageException({
    required super.msg,
    super.label = "Local Storage Exception",
    super.solutionMsg,
    super.stackTrace,
  });
}

class AppDataPathProviderException extends SettiException {
  AppDataPathProviderException({
    required super.msg,
    super.label = "Platform specific AppData can't be processed correctly",
    super.solutionMsg,
    super.stackTrace,
  });
}

class ControllerException extends SettiException {
  ControllerException({
    required super.msg,
    super.label = "Invalid Operation",
    super.solutionMsg,
    super.stackTrace,
  });
}

class ConfigManagerException extends SettiException {
  ConfigManagerException({
    required super.msg,
    super.label = "Config Manager Exception",
    super.solutionMsg,
    super.stackTrace,
  });
}

class ValidationException extends SettiException {
  ValidationException({
    required super.msg,
    super.label = "Validation Exception",
    super.solutionMsg,
    super.stackTrace,
  });
}
