class DveciPrefix {
  String prefix;

  DveciPrefix(this.prefix);

  DveciPrefix.fromMap(Map<String, dynamic> m) : this(m['prefix']);

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['prefix'] = prefix;
    return data;
  }
}
