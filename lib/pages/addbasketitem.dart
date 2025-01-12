import '../models/dvecicolor.dart';
import '../models/dveciprefix.dart';

import '../services/helperservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../database/db_helper.dart';
import '../models/basket.dart';
import '../models/dvecisize.dart';
import '../models/itemmodel.dart';

import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/floating_button.dart';

import 'basketlist.dart';

class AddBasketItem extends StatefulWidget {
  const AddBasketItem({super.key});

  @override
  State<AddBasketItem> createState() => _AddBasketItemState();
}

class _AddBasketItemState extends State<AddBasketItem> {
  final DbHelper _dbHelper = DbHelper.instance;

  String itemCode = "X.000000.00.00.000";
  late ItemModel itemModel = HelperService().GetItemModel(itemCode);
  TextEditingController serialNumber = TextEditingController();
  TextEditingController mainCode = TextEditingController();
  TextEditingController sizeCode = TextEditingController();
  TextEditingController colorCode = TextEditingController();
  TextEditingController pageNumber = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController description = TextEditingController();

  late List<DveciColor>? colorItems = [];
  late List<DveciPrefix>? prefixItems = [];
  late List<DveciSize>? sizeItems = [];
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _loadPrefixes();
    _loadColors();
    _loadSizes();

    InitBasketLookup();
  }

  void InitBasketLookup() async {
    description.text = "";
    quantity.text = "1";
    serialNumber.text = itemModel.prefix;
    mainCode.text = itemModel.code;
    sizeCode.text = itemModel.size;
    colorCode.text = itemModel.color;
    pageNumber.text = itemModel.pageNumber;
    setState(() {});
  }

  Future<void> _loadPrefixes() async {
    prefixItems = await _dbHelper.getPrefixes();
    //setState(() {}); // Widget'ı yeniden oluştur
  }

  Future<void> _loadColors() async {
    colorItems = await _dbHelper.getColors();
    //setState(() {}); // Widget'ı yeniden oluştur
  }

  Future<void> _loadSizes() async {
    sizeItems = await _dbHelper.getSizes();
    //setState(() {}); // Widget'ı yeniden oluştur
  }

  void setItemModel() {
    itemModel = HelperService().GetItemModel(itemCode);
    setState(() {
      serialNumber.text = itemModel.prefix;
      mainCode.text = itemModel.code;
      sizeCode.text = itemModel.size;
      colorCode.text = itemModel.color;
      pageNumber.text = itemModel.pageNumber;
    });
  }

  void setPrefix(String prefix) {
    final splitted = itemCode.split('.');

    if (splitted.length == 5) {
      setState(() {
        itemCode =
            "$prefix.${splitted[1]}.${splitted[2]}.${splitted[3]}.${splitted[4]}";
        serialNumber.text = prefix;
      });
    }
  }

  void setMainCode(String maincode) {
    final splitted = itemCode.split('.');

    if (splitted.length == 5) {
      setState(() {
        itemCode =
            "${splitted[0]}.$maincode.${splitted[2]}.${splitted[3]}.${splitted[4]}";
        mainCode.text = maincode;
      });
    }
  }

  void setSize(String sizecode) {
    final splitted = itemCode.split('.');

    if (splitted.length == 5) {
      setState(() {
        itemCode =
            "${splitted[0]}.${splitted[1]}.$sizecode.${splitted[3]}.${splitted[4]}";
        sizeCode.text = sizecode;
      });
    }
  }

  void setColor(String colorcode) {
    final splitted = itemCode.split('.');

    if (splitted.length == 5) {
      setState(() {
        itemCode =
            "${splitted[0]}.${splitted[1]}.${splitted[2]}.$colorcode.${splitted[4]}";
        colorCode.text = colorcode;
      });
    }
  }

  void setPageNumber(String pagecode) {
    final splitted = itemCode.split('.');

    if (splitted.length == 5) {
      setState(() {
        itemCode =
            "${splitted[0]}.${splitted[1]}.${splitted[2]}.${splitted[3]}.$pagecode";
        pageNumber.text = pagecode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      drawer: drawerMenu(context, "D-Veci"),
      floatingActionButton: floatingButton(context),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      bottomNavigationBar: bottomWidget(context),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(itemModel.itemCode,
            style: const TextStyle(
                color: Color(0xFFB79C91),
                fontSize: 14,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: formKey,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text("SERIAL",
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0XFF1B5E20),
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      Container(
                                        width: 50,
                                        child: TextFormField(
                                          controller: serialNumber,
                                          readOnly: true,
                                          onTap: () {
                                            _showPrefixBottomSheet(context);
                                          },
                                          textAlign: TextAlign.center,
                                          maxLength: 2,
                                          validator: (value) {
                                            if (value != null) {
                                              if (value.isEmpty) {
                                                return 'Serial number required';
                                              }
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              isDense: true,
                                              filled: true,
                                              counterText: '',
                                              fillColor:
                                                  const Color(0xFFF4F5F7),
                                              alignLabelWithHint: true,
                                              hintText: "A",
                                              hintStyle: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0XFFC0C7D1)),
                                              border: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Color(0XFF726658),
                                                    width: 2),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 1,
                                                      vertical: 12)),
                                        ),
                                      ),
                                    ],
                                  )), //SERIAL
                              Container(
                                width: 8,
                                alignment: Alignment.center,
                                child: const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    ".",
                                    style: TextStyle(fontSize: 30),
                                  ),
                                ),
                              ),
                              Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text("MAIN CODE",
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0XFF6E7B89),
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      Container(
                                        width: 90,
                                        child: TextFormField(
                                          controller: mainCode,
                                          keyboardType: TextInputType.number,
                                          maxLength: 6,
                                          onChanged: (value) {
                                            setMainCode(value);
                                          },
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                              isDense: true,
                                              filled: true,
                                              counterText: '',
                                              fillColor:
                                                  const Color(0xFFF4F5F7),
                                              alignLabelWithHint: true,
                                              hintText: "000000",
                                              hintStyle: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0XFFC0C7D1)),
                                              border: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.amber,
                                                    width: 0),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 1,
                                                      vertical: 12)),
                                          validator: (value) {
                                            if (value != null) {
                                              if (value.isEmpty) {
                                                return 'Serial number required';
                                              }
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  )),
                              Container(
                                width: 8,
                                alignment: Alignment.center,
                                child: const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    ".",
                                    style: TextStyle(fontSize: 30),
                                  ),
                                ),
                              ),
                              Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text("SIZE",
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      Container(
                                        width: 60,
                                        child: TextFormField(
                                          controller: sizeCode,
                                          readOnly: true,
                                          maxLength: 3,
                                          keyboardType: TextInputType.number,
                                          onTap: () {
                                            _showSizeBottomSheet(context);
                                          },
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                              isDense: true,
                                              filled: true,
                                              counterText: '',
                                              fillColor:
                                                  const Color(0xFFF4F5F7),
                                              alignLabelWithHint: true,
                                              hintText: "000",
                                              hintStyle: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0XFFC0C7D1)),
                                              border: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.amber,
                                                    width: 0),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 1,
                                                      vertical: 12)),
                                          validator: (value) {
                                            if (value != null) {
                                              if (value.isEmpty) {
                                                return 'Size required';
                                              }
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  )),
                              Container(
                                width: 8,
                                alignment: Alignment.center,
                                child: const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    ".",
                                    style: TextStyle(fontSize: 30),
                                  ),
                                ),
                              ),
                              Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text("COLOR",
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0XFF7B1FA2),
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      Container(
                                        width: 50,
                                        child: TextFormField(
                                          controller: colorCode,
                                          readOnly: true,
                                          maxLength: 2,
                                          keyboardType: TextInputType.number,
                                          onTap: () {
                                            _showColorBottomSheet(context);
                                          },
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                              isDense: true,
                                              filled: true,
                                              counterText: '',
                                              fillColor:
                                                  const Color(0xFFF4F5F7),
                                              alignLabelWithHint: true,
                                              hintText: "00",
                                              hintStyle: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0XFFC0C7D1)),
                                              border: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.amber,
                                                    width: 0),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 1,
                                                      vertical: 12)),
                                          validator: (value) {
                                            if (value != null) {
                                              if (value.isEmpty) {
                                                return 'Color required';
                                              }
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  )),
                              Container(
                                width: 8,
                                alignment: Alignment.center,
                                child: const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    ".",
                                    style: TextStyle(fontSize: 30),
                                  ),
                                ),
                              ),
                              Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Text("PAGE",
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0XFF6E7B89),
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      Container(
                                        width: 60,
                                        child: TextFormField(
                                          controller: pageNumber,
                                          maxLength: 3,
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            setPageNumber(value);
                                          },
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                              isDense: true,
                                              filled: true,
                                              counterText: '',
                                              fillColor:
                                                  const Color(0xFFF4F5F7),
                                              alignLabelWithHint: true,
                                              hintText: "000",
                                              hintStyle: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0XFFC0C7D1)),
                                              border: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.amber,
                                                    width: 0),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 1,
                                                      vertical: 12)),
                                          validator: (value) {
                                            if (value != null) {
                                              if (value.isEmpty) {
                                                return 'Page number required';
                                              }
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 16.0,
                                ),

                                Container(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Quantity',
                                      fillColor: const Color(0xFFF4F5F7),
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    textAlign: TextAlign.right,
                                    textAlignVertical: TextAlignVertical.center,
                                    keyboardType: TextInputType.number,
                                    controller: quantity,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    validator: (value) {
                                      if (value != null) {
                                        if (value.isEmpty) {
                                          return 'Quantity';
                                        }
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      quantity.text = value;
                                    },
                                  ),
                                ),

                                const SizedBox(
                                  height: 16.0,
                                ),

                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Color(0XFFF4F5F7),
                                  ),
                                  child: TextFormField(
                                    controller: description,
                                    onChanged: (value) {},
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 6,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xFFF4F5F7),
                                      hintText: "Description",
                                      label: const Text(
                                        "Description",
                                        style:
                                            TextStyle(color: Color(0XFFC0C7D1)),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.edit_note_outlined,
                                        color: Colors.grey[600],
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ), //TextArea
                                const SizedBox(
                                  height: 16.0,
                                ),
                                // SizedBox(
                                //   width: double.infinity,
                                //   child: ElevatedButton(
                                //     style: ElevatedButton.styleFrom(
                                //         elevation: 1,
                                //         shape: const CircleBorder(
                                //             side: BorderSide(
                                //                 style: BorderStyle.solid,
                                //                 width: 6,
                                //                 color: Color(0xFFEAEFFF))),
                                //         padding: EdgeInsets.all(16),
                                //         backgroundColor: Color(0xFF6E7B89)),
                                //     onPressed: () async {
                                //       // CameraDescription _camera =
                                //       //     await GetCamera();
                                //       // Navigator.of(context).push(
                                //       //     MaterialPageRoute(builder: (context) {
                                //       //   return Takepicture(
                                //       //     camera: _camera,
                                //       //     itemCode: itemCode,
                                //       //   );
                                //       // }));
                                //     },
                                //     child: const Column(
                                //       children: [
                                //         Icon(
                                //           Icons.photo_camera_outlined,
                                //           color: Colors.white,
                                //           size: 36.0,
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ),
                                // const SizedBox(
                                //   height: 16.0,
                                // ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                            foregroundColor: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10),
                                            shape: StadiumBorder())
                                        .copyWith(
                                            elevation:
                                                ButtonStyleButton.allOrNull(
                                                    0.0)),
                                    onPressed: () async {
                                      final formIsValid =
                                          formKey.currentState?.validate();
                                      if (formIsValid == true) {
                                        addbasket(itemCode, description.text);

                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return const BasketList();
                                        }));
                                      }
                                    },
                                    child: const Text('ADD TO BASKET'),
                                  ),
                                ), //Button
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> addbasket(String itemCode, String description) async {
    final now = DateTime.now();
    int _quantity = int.parse((quantity.text));

    var basket = Basket(1, itemCode, description, _quantity, now);

    await _dbHelper.addBasket(basket);
  }

  void _showPrefixBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Select Code Prefix',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700]),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: prefixItems?.length ?? 0,
                itemBuilder: (context, index) {
                  return ListTile(
                    tileColor: Colors.transparent,
                    title: Text(
                      prefixItems![index].prefix,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              serialNumber.text == prefixItems![index].prefix
                                  ? FontWeight.w900
                                  : FontWeight.normal,
                          color: serialNumber.text == prefixItems![index].prefix
                              ? Colors.green[700]
                              : Colors.black),
                    ),
                    onTap: () {
                      serialNumber.text = prefixItems![index].prefix;
                      setPrefix(serialNumber.text);
                      Navigator.pop(context);
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    color: Colors.grey[200],
                    thickness: 1,
                    height: 1,
                  );
                },
              ),
            ),
          ]),
        );
      },
    );
  }

  void _showSizeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Select Size Number',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: sizeItems?.length ?? 0,
                itemBuilder: (context, index) {
                  return ListTile(
                    tileColor: Colors.transparent,
                    leading: Text(
                      '#${'00${sizeItems![index].id}'.substring(((sizeItems![index].id.toString()).length + 2) - 3)}',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    title: Text(sizeItems![index].code,
                        style: TextStyle(
                          fontSize: 16,
                        )),
                    onTap: () {
                      if (sizeItems![index].id <= 9) {
                        sizeCode.text = '0${sizeItems![index].id}';
                      } else {
                        sizeCode.text = '${sizeItems![index].id}';
                      }
                      setSize(sizeCode.text);
                      Navigator.pop(context);
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    color: Colors.grey[200],
                    thickness: 1,
                    height: 1,
                  );
                },
              ),
            ),
          ]),
        );
      },
    );
  }

  void _showColorBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Select Color',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: colorItems?.length ?? 0,
                itemBuilder: (context, index) {
                  return ListTile(
                    tileColor: Colors.transparent,
                    leading: Text(
                      colorItems![index].colorNumber!,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    title: Text(
                      colorItems![index].colorName!,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              colorCode.text == colorItems![index].colorNumber
                                  ? FontWeight.w900
                                  : FontWeight.normal,
                          color:
                              colorCode.text == colorItems![index].colorNumber
                                  ? Colors.deepPurple
                                  : Colors.black),
                    ),
                    onTap: () {
                      colorCode.text = colorItems![index].colorNumber!;
                      setColor(colorCode.text);
                      Navigator.pop(context);
                    },
                    trailing: Text(colorItems![index].manufactureType!),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    color: Colors.grey[200],
                    thickness: 1,
                    height: 1,
                  );
                },
              ),
            ),
          ]),
        );
      },
    );
  }
}
