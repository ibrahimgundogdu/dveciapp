class BasketFile {
  int id;
  int basketId;
  String imageFile;

  BasketFile(this.id, this.basketId, this.imageFile);

  BasketFile.fromMap(Map<String, dynamic> m)
      : this(m['id'], m['basketId'], m['imageFile']);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map["id"] = id;
    map["basketId"] = basketId;
    map["imageFile"] = imageFile;

    return map;
  }
}
