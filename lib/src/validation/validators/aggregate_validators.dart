import 'base_validator.dart';

class AndValidator<T> extends Validator<T> {
  final List<Validator<T>> validators;

  const AndValidator(this.validators);

  @override
  bool call(T value) => validators.every((v) => v.call(value));

  @override
  String? explain(T value) {
    final failed = validators
        .where((v) => !v.call(value))
        .map((v) => v.explain(value) ?? v.toString())
        .toList();

    if (failed.isEmpty) return null;

    return "Validation failed for value '$value'. Failed checks:\n- ${failed.join('\n- ')}";
  }

  @override
  String toString() => 'AndValidator(${validators.join(', ')})';

  @override
  bool operator ==(Object other) =>
      other is AndValidator<T> &&
      validators.length == other.validators.length &&
      validators.every((v) => other.validators.contains(v));

  @override
  int get hashCode => validators.fold(0, (h, v) => h ^ v.hashCode);
}

class OrValidator<T> extends Validator<T> {
  final List<Validator<T>> validators;

  const OrValidator(this.validators);

  @override
  bool call(T value) => validators.any((v) => v.call(value));

  @override
  String? explain(T value) {
    if (call(value)) return null;

    final reasons =
        validators.map((v) => v.explain(value) ?? v.toString()).toList();

    return "Validation failed for value '$value'. None of the following conditions passed:\n- ${reasons.join('\n- ')}";
  }

  @override
  String toString() => 'OrValidator(${validators.join(', ')})';

  @override
  bool operator ==(Object other) =>
      other is OrValidator<T> &&
      validators.length == other.validators.length &&
      validators.every((v) => other.validators.contains(v));

  @override
  int get hashCode => validators.fold(0, (h, v) => h ^ v.hashCode);
}

class NotValidator<T> extends Validator<T> {
  final Validator<T> validator;

  const NotValidator(this.validator);

  @override
  bool call(T value) => !validator.call(value);

  @override
  String? explain(T value) {
    if (call(value)) return null;
    return "Validation failed for value '$value'. It should NOT satisfy:\n- ${validator.explain(value) ?? validator.toString()}";
  }

  @override
  String toString() => 'NotValidator($validator)';

  @override
  bool operator ==(Object other) =>
      other is NotValidator<T> && validator == other.validator;

  @override
  int get hashCode => validator.hashCode;
}
