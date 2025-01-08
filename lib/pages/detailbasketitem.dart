import '../models/dvecicolor.dart';
import '../pages/takepicture.dart';
import '../services/helperservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../database/db_helper.dart';
import '../services/cameraservice.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/floating_button.dart';
import 'addbasket.dart';

class DetailBasketItem extends StatefulWidget {
  final String itemCode;
  const DetailBasketItem({Key? key, required this.itemCode}) : super(key: key);

  @override
  State<DetailBasketItem> createState() => _DetailBasketItemState();
}

class _DetailBasketItemState extends State<DetailBasketItem> {
  TextEditingController serialNumber = TextEditingController();
  TextEditingController mainCode = TextEditingController();
  TextEditingController sizeCode = TextEditingController();
  TextEditingController colorCode = TextEditingController();
  TextEditingController pageNumber = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController description = TextEditingController();
  final DbHelper _dbHelper = DbHelper.instance;
  final HelperService _service = HelperService();

  List<DveciColor>? colorItems;

  @override
  void initState() {
    super.initState();
  }

  String defaultDescription = "";
  int quantityNumber = 1;
  String itemColorCode = "FREE NİKEL";
  String itemSizeCode = "1";
  int itemPageNumber = 1;
  List<int> quantityItems = <int>[
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20
  ];

  List<String> sizeItems = <String>[
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12",
    "13",
    "14",
    "15",
    "16",
    "17",
    "18",
    "19",
    "20"
  ];

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var itemModel = HelperService().GetItemModel(widget.itemCode);
    _dbHelper.getColors().then((value) {
      colorItems = value;
    });

    debugPrint("Color items : ${colorItems?.length}");
    serialNumber.text = itemModel.prefix;
    mainCode.text = itemModel.code;
    sizeCode.text = itemModel.size;
    colorCode.text = itemModel.color;
    pageNumber.text = itemModel.pageNumber;

    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        drawer: drawerMenu(context, "D-Veci"),
        floatingActionButton: floatingButton(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            itemModel.itemCode,
            style: const TextStyle(
                color: Color(0xFFB79C91),
                fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
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
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text("SERIAL",
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Color(0XFF6E7B89))),
                                      ),
                                    ),
                                    Container(
                                      width: 40,
                                      child: TextFormField(
                                        controller: serialNumber,
                                        onChanged: (value) {},
                                        textAlign: TextAlign.center,
                                        validator: (value) {
                                          if (value != null) {
                                            if (value.isEmpty) {
                                              return 'Serial number required';
                                            }
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: const Color(0xFFF4F5F7),
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
                                        ),
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
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text("MAIN CODE",
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Color(0XFF6E7B89))),
                                      ),
                                    ),
                                    Container(
                                      width: 90,
                                      child: TextFormField(
                                        controller: mainCode,
                                        onChanged: (value) {},
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: const Color(0xFFF4F5F7),
                                          alignLabelWithHint: true,
                                          hintText: "000000",
                                          hintStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0XFFC0C7D1)),
                                          border: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.amber, width: 0),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
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
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text("SIZE",
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Color(0XFF6E7B89))),
                                      ),
                                    ),
                                    Container(
                                      width: 50,
                                      child: TextFormField(
                                        controller: sizeCode,
                                        onChanged: (value) {},
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: const Color(0xFFF4F5F7),
                                          alignLabelWithHint: true,
                                          hintText: "00",
                                          hintStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0XFFC0C7D1)),
                                          border: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.amber, width: 0),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
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
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text("COLOR",
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Color(0XFF6E7B89))),
                                      ),
                                    ),
                                    Container(
                                      width: 50,
                                      child: TextFormField(
                                        controller: colorCode,
                                        onChanged: (value) {},
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: const Color(0xFFF4F5F7),
                                          alignLabelWithHint: true,
                                          hintText: "00",
                                          hintStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0XFFC0C7D1)),
                                          border: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.amber, width: 0),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
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
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text("PAGE",
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Color(0XFF6E7B89))),
                                      ),
                                    ),
                                    Container(
                                      width: 60,
                                      child: TextFormField(
                                        controller: pageNumber,
                                        onChanged: (value) {},
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: const Color(0xFFF4F5F7),
                                          alignLabelWithHint: true,
                                          hintText: "000",
                                          hintStyle: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0XFFC0C7D1)),
                                          border: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.amber, width: 0),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
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
                          ],
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Color(0XFFF4F5F7),
                                ),
                                child: DropdownButtonFormField<int>(
                                  value: quantityNumber,
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.all(6),
                                      prefixIcon:
                                          Icon(Icons.shopping_cart_outlined),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none)),
                                  hint: const Text('Please choose quantity'),
                                  items: quantityItems.map((int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(value.toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      quantityNumber = value as int;
                                    });
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
                                child: DropdownButtonFormField<String>(
                                  value: itemSizeCode,
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.all(6),
                                      prefixIcon:
                                          Icon(Icons.straighten_outlined),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none)),
                                  hint: Text('Please choose size'),
                                  items: sizeItems.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      itemSizeCode = value ?? "";
                                    });
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
                                child: DropdownButtonFormField(
                                  value: itemColorCode,
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.all(6),
                                      prefixIcon: Icon(Icons.palette_outlined),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none)),
                                  hint: Text('Choose color'),
                                  items: colorItems?.map((DveciColor e) {
                                    return DropdownMenuItem<String>(
                                        value: e.colorNumber,
                                        child: Text(
                                          e.colorName ?? "FREE NİKEL",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ));
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      itemColorCode = value.toString();
                                    });
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
                                  maxLines: 2,
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
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value != null) {
                                      if (value.isEmpty) {
                                        return 'Phone number required';
                                      } else if (value.length < 11) {
                                        return 'Complete phone number';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ), //TextArea
                              const SizedBox(
                                height: 16.0,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      elevation: 1,
                                      shape: const CircleBorder(
                                          side: BorderSide(
                                              style: BorderStyle.solid,
                                              width: 6,
                                              color: Color(0xFFEAEFFF))),
                                      padding: EdgeInsets.all(16),
                                      backgroundColor: Color(0xFF6E7B89)),
                                  onPressed: () async {
                                    // CameraDescription _camera =
                                    //     await GetCamera();
                                    // Navigator.of(context).push(
                                    //     MaterialPageRoute(builder: (context) {
                                    //   return Takepicture(
                                    //     camera: _camera,
                                    //     itemCode: widget.itemCode,
                                    //   );
                                    // }));
                                  },
                                  child: const Column(
                                    children: [
                                      Icon(
                                        Icons.photo_camera_outlined,
                                        color: Colors.white,
                                        size: 36.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 16.0,
                              ),
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
                                              vertical: 16),
                                          shape: StadiumBorder())
                                      .copyWith(
                                          elevation:
                                              ButtonStyleButton.allOrNull(0.0)),
                                  onPressed: () async {
                                    final formIsValid =
                                        formKey.currentState?.validate();
                                    if (formIsValid == true) {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return const DetailBasketItem(
                                          itemCode: "A.000000.00.00.000",
                                        );
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
        bottomNavigationBar: bottomWidget(context));
  }

  Future<List<DveciColor>> _getColors() async {
    return await _dbHelper.getColors();
  }
}
