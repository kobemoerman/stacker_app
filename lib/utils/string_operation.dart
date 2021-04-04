extension StringFormat on String {
  String formatCard() {
    var reg = RegExp('^[a-zA-Z][\.]', multiLine: true);
    var matches = this.replaceAllMapped(reg, (match) => '\t\t' + match[0]);

    return matches;
  }

  String formatStrinToDB() {
    var reg = RegExp('[\']+');

    return this.replaceAll(reg, '\'\'');
  }

  String formatDBToString() {
    return this.replaceAll('\'\'', '\'');
  }

  Iterable<String> formatTable() {
    var string = this.replaceAll('_', ' ');

    if (this.endsWith('.csv')) {
      string = string.replaceAll('.csv', '');
    }

    return RegExp('[A-Z]+[^A-Z]*').allMatches(string).map((m) => m.group(0));
  }
}
