/// Validates numeric input for prices and TDP.
class InputValidators {
  const InputValidators();

  String? validate(String value, {required bool isPrice}) {
    if (value.isEmpty) return null;

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (isPrice) {
      if (number < 0) return 'Price cannot be negative';
      if (number > 99999) return 'Price seems too high';
    } else {
      if (number < 0) return 'TDP cannot be negative';
      if (number > 1000) return 'TDP seems too high';
    }
    return null;
  }
}
