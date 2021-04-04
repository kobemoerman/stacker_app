extension ListExt on List {
  List getOccurences() {
    if (this == null) throw 'List is null';

    List tmp = [];

    this.forEach((element) {
      if (!tmp.contains(element)) tmp.add(element);
    });

    return tmp;
  }
}
