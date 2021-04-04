DateTime convertToDate({string}) {
  assert(string is String);

  final list = string.split('-');

  return DateTime(int.parse(list[0]), int.parse(list[1]), int.parse(list[2]));
}

extension DateOperation on DateTime {
  bool compareDays({days, date, equals = false}) {
    assert(days is int && days != null);
    assert(date is DateTime && date != null);

    if (equals) {
      return this.difference(date).inDays == days;
    } else {
      return this.difference(date).inDays <= days;
    }
  }

  String convertToString() {
    return '${this.year}-${this.month}-${this.day}';
  }
}
