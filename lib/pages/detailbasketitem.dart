import 'dart:io';

import '../models/basketfile.dart';
import 'package:image_picker/image_picker.dart';

import '../models/basket.dart';
import '../models/dvecicolor.dart';
import '../models/dveciprefix.dart';
import '../models/dvecisize.dart';
import '../models/itemmodel.dart';
import '../services/helperservice.dart';
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';
import 'basketlist.dart';

class DetailBasketItem extends StatefulWidget {
  final int itemId;

  const DetailBasketItem({super.key, required this.itemId});

  @override
  State<DetailBasketItem> createState() => _DetailBasketItemState();
}

class _DetailBasketItemState extends State<DetailBasketItem> {
  final DbHelper _dbHelper = DbHelper.instance;
  Basket? basketItem;
  ItemModel? itemModel;
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _pickedFiles = [];

  String itemCode = "X.000000.00.00.000";
  String _appBarTitle = "";

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
  late List<BasketFile>? basketItemFiles = [];
  final formKey = GlobalKey<FormState>();

  Future<void> initBasketItem() async {
    basketItem = await _dbHelper.getBasketItem(widget.itemId);
    basketItemFiles = await _dbHelper.getBasketFiles(widget.itemId);

    if (basketItemFiles != null) {
      for (var basketFile in basketItemFiles!) {
        if (basketFile.imageFile.isNotEmpty) {
          try {
            final xfile = XFile(basketFile.imageFile);
            if (!_pickedFiles.any((file) => file.path == xfile.path)) {
              _pickedFiles.add(xfile);
            }
          } catch (e) {
            // Hata durumunda yapılacak işlemler
          }
        }
      }
    }

    if (basketItem != null) {
      itemCode = basketItem!.qrCode;
      itemModel = HelperService().getItemModel(basketItem!.qrCode);
      description.text = basketItem!.description;
      quantity.text = basketItem!.quantity.toString();
      serialNumber.text = itemModel!.prefix;
      mainCode.text = itemModel!.code;
      sizeCode.text = itemModel!.size;
      colorCode.text = itemModel!.color;
      pageNumber.text = itemModel!.pageNumber;
      _appBarTitle = '#${basketItem!.id}   -  ${basketItem!.qrCode}';
    } else {
      _appBarTitle = 'Öğe Bulunamadı';
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    _loadInitialDataAndBasketItem();
  }

  Future<void> _loadInitialDataAndBasketItem() async {
    await Future.wait([
      _loadPrefixes(),
      _loadColors(),
      _loadSizes(),
    ]);

    await initBasketItem();
  }

  Future<void> _loadPrefixes() async {
    prefixItems = await _dbHelper.getPrefixes();
  }

  Future<void> _loadColors() async {
    colorItems = await _dbHelper.getColors();
  }

  Future<void> _loadSizes() async {
    sizeItems = await _dbHelper.getSizes();
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

  // File? _storedImage;
  // final picker = ImagePicker();

  // Future<void> _takePicture() async {
  //   final imageFile = await picker.pickImage(
  //     source: ImageSource.camera,
  //   );
  //   setState(() {
  //     _storedImage = File(imageFile?.path ?? "");
  //   });
  //   await _saveImageToDocuments();
  // }
  //
  // Future<void> _selectPicture() async {
  //   final imageFile = await picker.pickImage(
  //     source: ImageSource.gallery,
  //   );
  //   setState(() {
  //     _storedImage = File(imageFile?.path ?? "");
  //   });
  //   await _saveImageToDocuments();
  // }

  Future<void> _saveImageToDocuments(XFile imageFile) async {
    try {
      await _dbHelper.addBasketXFile(widget.itemId, imageFile);
      basketItemFiles = await _dbHelper.getBasketFiles(widget.itemId);
    } catch (e) {
      // Hata durumunda yapılacak işlemler
    }
  }

  // Future<void> _showDeleteConfirmationDialogItem(XFile item) async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // Kullanıcı butonlara tıklamalı
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Delete Confirmation'),
  //         content: const SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               Text('Do you want to delete item?'),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               setState(() {});
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('Delete'),
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Diyaloğu kapat
  //               removeBasketFileItem(item); // Silme işlemini gerçekleştir
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future removeBasketXFileItem(XFile item) async {
    await _dbHelper.removeBasketXFile(widget.itemId, item);
    if (!mounted) return;

    setState(() {
      _pickedFiles.removeWhere((file) => file.path == item.path);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Item removed!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? imageFile = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );

      if (imageFile != null) {
        setState(() {
          if (!_pickedFiles.any((file) => file.path == imageFile.path)) {
            _pickedFiles.add(imageFile);
          }
        });

        _saveImageToDocuments(imageFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('The file could not be selected: $e')),
        );
      }
    }
  }

  void _removeFile(XFile fileToRemove) async {
    await removeBasketXFileItem(fileToRemove);

    setState(() {
      _pickedFiles.removeWhere((file) => file.path == fileToRemove.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (basketItem == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        drawer: drawerMenu(context, "D-Veci"),
        bottomNavigationBar: bottomWidget(context, 3),
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            _appBarTitle,
            style: const TextStyle(
                color: Color(0xFFB79C91),
                fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.black54,
                size: 24,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
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
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Text("SERIAL",
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0XFF1B5E20),
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          SizedBox(
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0XFFC0C7D1)),
                                                  border: OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Color(
                                                                0XFF726658),
                                                            width: 2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
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
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Text("MAIN CODE",
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0XFF6E7B89),
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          SizedBox(
                                            width: 90,
                                            child: TextFormField(
                                              controller: mainCode,
                                              keyboardType:
                                                  TextInputType.number,
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0XFFC0C7D1)),
                                                  border: OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.amber,
                                                            width: 0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
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
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Text("SIZE",
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.red,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          SizedBox(
                                            width: 60,
                                            child: TextFormField(
                                              controller: sizeCode,
                                              readOnly: true,
                                              maxLength: 3,
                                              keyboardType:
                                                  TextInputType.number,
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0XFFC0C7D1)),
                                                  border: OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.amber,
                                                            width: 0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
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
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Text("COLOR",
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0XFF7B1FA2),
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          SizedBox(
                                            width: 50,
                                            child: TextFormField(
                                              controller: colorCode,
                                              readOnly: true,
                                              maxLength: 2,
                                              keyboardType:
                                                  TextInputType.number,
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0XFFC0C7D1)),
                                                  border: OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.amber,
                                                            width: 0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
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
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Text("PAGE",
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0XFF6E7B89),
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          SizedBox(
                                            width: 60,
                                            child: TextFormField(
                                              controller: pageNumber,
                                              maxLength: 3,
                                              keyboardType:
                                                  TextInputType.number,
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0XFFC0C7D1)),
                                                  border: OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.amber,
                                                            width: 0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
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

                                    TextFormField(
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color(0xFFF4F5F7),
                                        //hintText: "Quantity",
                                        label: const Text(
                                          "Quantity",
                                          style: TextStyle(
                                              color: Color(0XFFC0C7D1)),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      textAlign: TextAlign.right,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      keyboardType: TextInputType.number,
                                      controller: quantity,
                                      style: const TextStyle(
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

                                    const SizedBox(
                                      height: 16.0,
                                    ),

                                    TextFormField(
                                      controller: description,
                                      onChanged: (value) {},
                                      keyboardType: TextInputType.multiline,
                                      maxLines: 5,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color(0xFFF4F5F7),
                                        label: const Text(
                                          "Description",
                                          style: TextStyle(
                                              color: Color(0XFFC0C7D1)),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ), //TextArea
                                    const SizedBox(
                                      height: 16.0,
                                    ),

                                    _buildFileAttachmentSection(),
                                    const SizedBox(
                                      height: 16.0,
                                    ),
                                    SizedBox(
                                      height: 50,
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                                foregroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                backgroundColor:
                                                    Colors.deepOrange,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10),
                                                shape: const StadiumBorder())
                                            .copyWith(
                                                elevation:
                                                    ButtonStyleButton.allOrNull(
                                                        0.0)),
                                        onPressed: () async {
                                          final formIsValid =
                                              formKey.currentState?.validate();
                                          if (formIsValid == true) {
                                            int itemQuantity =
                                                int.parse((quantity.text));

                                            basketItem!.qrCode = itemCode;
                                            basketItem!.quantity = itemQuantity;
                                            basketItem!.description =
                                                description.text;
                                            basketItem!.recordDate =
                                                DateTime.now();

                                            updateBasket(basketItem!);

                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return const BasketList();
                                            }));
                                          }
                                        },
                                        child: const Text('SAVE CHANGES'),
                                      ),
                                    ),
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
            )));
  }

  Future<void> updateBasket(Basket item) async {
    await _dbHelper.updateBasket(item);
  }

  Widget _buildFileAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_pickedFiles.isNotEmpty)
          Container(
            height: 110,
            margin: const EdgeInsets.only(bottom: 10, top: 0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300)),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _pickedFiles.length,
              itemBuilder: (context, index) {
                final file = _pickedFiles[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.grey.shade400, width: 0.5)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            File(file.path),
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                    width: 90,
                                    height: 90,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.broken_image_outlined,
                                        color: Colors.grey[400])),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _removeFile(file),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 18),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt_outlined, size: 20),
                label: const Text("Kamera"),
                onPressed: () => _pickImage(ImageSource.camera),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.7)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(fontSize: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.photo_library_outlined, size: 20),
                label: const Text("Galeri"),
                onPressed: () => _pickImage(ImageSource.gallery),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepOrange,
                    side: BorderSide(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(fontSize: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showPrefixBottomSheet(BuildContext context) {
    showModalBottomSheet(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Column(children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
        ]);
      },
    );
  }

  void _showSizeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Select Size Number',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
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
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  title: Text(sizeItems![index].code),
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
        ]);
      },
    );
  }

  void _showColorBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(children: [
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
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  title: Text(colorItems![index].colorName!),
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
        ]);
      },
    );
  }
}
