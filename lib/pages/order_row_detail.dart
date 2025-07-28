import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../database/db_helper.dart';
import '../models/saleorder.dart';
import '../models/saleorderrow.dart';
import '../models/saleorderdocument.dart';
import 'full_screen_image_page.dart';

const Color primaryColor = Color(0xFFB79C91);
const Color accentColor = Color(0xFF8F7A70);
const Color backgroundColor = Colors.white;
const Color cardBackgroundColor = Color(0xFFF9F5F3);
const Color textColor = Colors.black87;
const Color hintColor = Colors.grey;

class OrderDetailRowEditPage extends StatefulWidget {
  final String orderUid;
  final String orderRowUid;

  const OrderDetailRowEditPage({
    super.key,
    required this.orderUid,
    required this.orderRowUid,
  });

  @override
  State<OrderDetailRowEditPage> createState() => _OrderDetailRowEditPageState();
}

class _OrderDetailRowEditPageState extends State<OrderDetailRowEditPage> {
  final DbHelper _dbHelper = DbHelper.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  SaleOrder? _currentOrder;
  SaleOrderRow? _currentRow;

  final ImagePicker _picker = ImagePicker();
  List<SaleOrderDocument>? _rowDocuments = [];
  final List<XFile> pickedFiles = [];

  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadRowDetails();
  }

  Future<void> _loadRowDetails() async {
    setState(() => _isLoading = true);
    try {
      _currentOrder = await _dbHelper.getOrder(widget.orderUid);

      if (_currentOrder == null) {
        throw Exception("Order not Found.");
      }

      _currentRow = await _dbHelper.getOrderRow(widget.orderRowUid);
      if (_currentRow == null) {
        throw Exception("Order Item not Found.");
      }

      _rowDocuments = await _dbHelper.getOrderRowDocuments(
          widget.orderUid, widget.orderRowUid);
      if (_rowDocuments != null) {
        for (var itemFile in _rowDocuments!) {
          if (itemFile.pathName!.isNotEmpty) {
            try {
              final xfile = XFile(itemFile.pathName!);
              if (!pickedFiles.any((file) => file.path == xfile.path)) {
                pickedFiles.add(xfile);
              }
            } catch (e) {
              // Hata durumunda yapılacak işlemler
            }
          }
        }
      }

      _quantityController.text = _currentRow!.quantity.toString();
      _descriptionController.text = _currentRow!.description;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error While Item Loading: $e',
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.redAccent),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? imageFile =
          await _picker.pickImage(source: source, imageQuality: 85);
      if (imageFile != null) {
        await _saveImageToDocuments(imageFile);

        setState(() {
          if (!pickedFiles.any((file) => file.path == imageFile.path)) {
            pickedFiles.add(imageFile);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'This file is already attached or an existing file with the same name..')),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('The file could not be selected: $e')));
      }
    }
  }

  Future<void> _saveImageToDocuments(XFile imageFile) async {
    try {
      await _dbHelper.addOrderRowXFileuid(
          widget.orderUid, widget.orderRowUid, imageFile);
    } catch (e) {
      //
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final newQuantity =
        double.tryParse(_quantityController.text.replaceAll(',', '.'));
    if (newQuantity == null || newQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid quantity.',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _dbHelper.updateOrderRow(
          widget.orderRowUid, newQuantity, _descriptionController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Order item has successfully updated!'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error during the update: $e',
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildFileAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pickedFiles.isNotEmpty)
          Container(
            height: 110,
            margin: const EdgeInsets.only(bottom: 10, top: 0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300)),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: pickedFiles.length,
              itemBuilder: (context, index) {
                final file = pickedFiles[index];
                final String imagePath = file.path;
                final String uniqueHeroTag = 'imageHero_$imagePath';

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => FullScreenImagePage(
                                    filePath: imagePath,
                                    heroTag: uniqueHeroTag,
                                  )));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.grey.shade400, width: 0.5)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Hero(
                              tag: uniqueHeroTag,
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
                label: const Text("Camera"),
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
                label: const Text("Gallery"),
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

  Future removeBasketXFileItem(XFile item) async {
    await _dbHelper.removeOrderXFile(widget.orderUid, item);
    if (!mounted) return;

    setState(() {
      pickedFiles.removeWhere((file) => file.path == item.path);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Item removed!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeFile(XFile fileToRemove) async {
    await removeBasketXFileItem(fileToRemove);

    setState(() {
      pickedFiles.removeWhere((file) => file.path == fileToRemove.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "EDIT ORDER ITEM",
          style: TextStyle(
              color: primaryColor, fontSize: 15, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: backgroundColor,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Center(
                      child: Text(
                        _currentRow!.qrCode,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity *',
                        labelStyle: const TextStyle(color: accentColor),
                        hintText: 'Input Item Quantity',
                        hintStyle:
                            TextStyle(color: hintColor.withValues(alpha: 0.7)),
                        filled: true,
                        fillColor: cardBackgroundColor,
                        prefixIcon: Icon(
                            Icons.production_quantity_limits_outlined,
                            color: primaryColor.withValues(alpha: 0.8)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: primaryColor.withValues(alpha: 0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: primaryColor, width: 1.5),
                        ),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Quantity cannot be left empty.';
                        }
                        final n = double.tryParse(value.replaceAll(',', '.'));
                        if (n == null || n <= 0) {
                          return 'Please enter a valid quantity.';
                        }
                        return null;
                      },
                      style: const TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Item Description (Optional)',
                        labelStyle: const TextStyle(color: accentColor),
                        hintText: 'You can add a special note to this line',
                        hintStyle:
                            TextStyle(color: hintColor.withValues(alpha: 0.7)),
                        filled: true,
                        fillColor: cardBackgroundColor,
                        prefixIcon: Icon(Icons.description_outlined,
                            color: primaryColor.withValues(alpha: 0.8)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: primaryColor.withValues(alpha: 0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: primaryColor, width: 1.5),
                        ),
                      ),
                      maxLines: 8,
                      style: const TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 30),
                    _buildFileAttachmentSection(),
                    const SizedBox(height: 20),
                    if (_currentOrder != null &&
                        _currentOrder?.orderStatusId == 0)
                      ElevatedButton.icon(
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.0))
                            : const Icon(Icons.save_alt_outlined,
                                color: Colors.white),
                        label: Text(
                          _isSaving ? 'SAVING...' : 'UPDATE ITEM',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        onPressed: _isSaving ? null : _saveChanges,
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
