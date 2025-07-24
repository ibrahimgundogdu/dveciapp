class BasketFile {
  int id;
  int basketId;
  String imageFile;
  String imageName;
  String mimetype;

  BasketFile(
      this.id, this.basketId, this.imageFile, this.imageName, this.mimetype);

  BasketFile.fromMap(Map<String, dynamic> m)
      : this(m['id'], m['basketId'], m['imageFile'], m['imageName'],
            m['mimetype']);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    map["id"] = id;
    map["basketId"] = basketId;
    map["imageFile"] = imageFile;
    map["imageName"] = imageName;
    map["mimetype"] = mimetype;

    return map;
  }
}
