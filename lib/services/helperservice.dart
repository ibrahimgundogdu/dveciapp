import '../models/itemmodel.dart';

class HelperService {
  ItemModel getItemModel(String code) {
    final splitted = code.split('.');
    if (splitted.length == 5) {
      return ItemModel(code, splitted[0], splitted[1], splitted[2], splitted[3],
          splitted[4]);
    } else {
      return ItemModel("A.00000.00.00.000", "A", "00000", "00", "00", "000");
    }
  }
}
