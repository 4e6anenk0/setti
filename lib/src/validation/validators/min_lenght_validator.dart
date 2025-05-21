import 'base_validator.dart';

class MinLengthValidator extends Validator<String> {
  final int minLength;

  MinLengthValidator(this.minLength);

  @override
  bool call(String value) => value.length >= minLength;

  @override
  bool operator ==(Object other) =>
      other is MinLengthValidator && other.minLength == minLength;

  @override
  int get hashCode => minLength.hashCode;
}
