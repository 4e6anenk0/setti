import 'base_validator.dart';

class MinLengthValidator extends StringValidator<String> {
  final int minLength;

  const MinLengthValidator(this.minLength);

  @override
  bool call(String value) => value.length >= minLength;

  @override
  String? explain(String value) {
    if (call(value)) return null;
    return 'Length ${value.length} is less than required minimum of $minLength.';
  }

  @override
  bool operator ==(Object other) =>
      other is MinLengthValidator && other.minLength == minLength;

  @override
  int get hashCode => minLength.hashCode;
}

class MaxLengthValidator extends StringValidator<String> {
  final int maxLength;

  const MaxLengthValidator(this.maxLength);

  @override
  bool call(String value) => value.length <= maxLength;

  @override
  String? explain(String value) {
    if (call(value)) return null;
    return 'Length ${value.length} exceeds maximum allowed of $maxLength.';
  }

  @override
  bool operator ==(Object other) =>
      other is MaxLengthValidator && other.maxLength == maxLength;

  @override
  int get hashCode => maxLength.hashCode;
}

class PatternValidator extends StringValidator<String> {
  final RegExp pattern;

  PatternValidator(this.pattern);

  @override
  bool call(String value) => pattern.hasMatch(value);

  @override
  String? explain(String value) {
    if (call(value)) return null;
    return 'The value "$value" does not match pattern "${pattern.pattern}".';
  }

  @override
  bool operator ==(Object other) =>
      other is PatternValidator && other.pattern.pattern == pattern.pattern;

  @override
  int get hashCode => pattern.pattern.hashCode;
}

class NonEmptyValidator extends StringValidator<String> {
  const NonEmptyValidator();

  @override
  bool call(String value) => value.trim().isNotEmpty;

  @override
  String? explain(String value) {
    if (call(value)) return null;
    return 'String is empty.';
  }

  @override
  bool operator ==(Object other) => other is NonEmptyValidator;

  @override
  int get hashCode => runtimeType.hashCode;
}

class OneOfValidator<T> extends Validator<T> {
  final Set<T> allowedValues;

  const OneOfValidator(this.allowedValues);

  @override
  bool call(T value) => allowedValues.contains(value);

  @override
  String? explain(T value) {
    if (call(value)) return null;
    return "Value '$value' is not one of the allowed values: ${allowedValues.join(', ')}.";
  }

  @override
  bool operator ==(Object other) =>
      other is OneOfValidator<T> &&
      allowedValues.length == other.allowedValues.length &&
      allowedValues.containsAll(other.allowedValues);

  @override
  int get hashCode => allowedValues.fold(0, (hash, val) => hash ^ val.hashCode);

  @override
  String toString() => 'OneOfValidator(${allowedValues.join(', ')})';
}
