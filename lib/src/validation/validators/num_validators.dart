import 'base_validator.dart';

class MinValueValidator<T extends num> extends NumValidator<T> {
  final T min;

  const MinValueValidator(this.min);

  @override
  bool call(T value) => value >= min;

  @override
  String? explain(T value) {
    if (call(value)) return null;
    return 'The value $value is less than the minimum allowed value of $min.';
  }

  @override
  bool operator ==(Object other) =>
      other is MinValueValidator<T> && other.min == min;

  @override
  int get hashCode => min.hashCode;
}

class MaxValueValidator<T extends num> extends NumValidator<T> {
  final T max;

  const MaxValueValidator(this.max);

  @override
  bool call(T value) => value <= max;

  @override
  String? explain(T value) {
    if (call(value)) return null;
    return 'Validation failed: $value exceeds the maximum allowed value of $max.';
  }

  @override
  bool operator ==(Object other) =>
      other is MaxValueValidator<T> && other.max == max;

  @override
  int get hashCode => max.hashCode;
}

class OnlyPositiveValidator<T extends num> extends NumValidator<T> {
  const OnlyPositiveValidator();

  @override
  bool call(T value) => value > 0;

  @override
  String? explain(T value) {
    if (call(value)) return null;
    return 'Validation failed: $value is not positive.';
  }

  @override
  bool operator ==(Object other) => other is OnlyPositiveValidator<T>;

  @override
  int get hashCode => runtimeType.hashCode;
}

class OnlyNegativeValidator<T extends num> extends NumValidator<T> {
  const OnlyNegativeValidator();

  @override
  bool call(T value) => value < 0;

  @override
  String? explain(T value) {
    if (call(value)) return null;
    return 'Validation failed: $value is not negative.';
  }

  @override
  bool operator ==(Object other) => other is OnlyNegativeValidator<T>;

  @override
  int get hashCode => runtimeType.hashCode;
}

class NonZeroValidator<T extends num> extends NumValidator<T> {
  const NonZeroValidator();

  @override
  bool call(T value) => value != 0;

  @override
  String? explain(T value) {
    if (call(value)) return null;
    return 'Value is zero.';
  }

  @override
  bool operator ==(Object other) => other is NonZeroValidator<T>;

  @override
  int get hashCode => runtimeType.hashCode;
}

class DivisibleByValidator extends NumValidator<int> {
  final int divisor;

  const DivisibleByValidator(this.divisor);

  @override
  bool call(int value) => value % divisor == 0;

  @override
  String? explain(int value) {
    if (call(value)) return null;
    return 'The value $value is not divisible by $divisor.';
  }

  @override
  bool operator ==(Object other) =>
      other is DivisibleByValidator && other.divisor == divisor;

  @override
  int get hashCode => divisor.hashCode;
}

class RangeValidator<T extends num> extends NumValidator<T> {
  final T min;
  final T max;

  const RangeValidator({required this.min, required this.max});

  @override
  bool call(T value) => value >= min && value <= max;

  @override
  String? explain(T value) {
    if (call(value)) return null;
    return 'The value $value is outside the allowed range [$min, $max].';
  }

  @override
  bool operator ==(Object other) =>
      other is RangeValidator<T> && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(min, max);
}
