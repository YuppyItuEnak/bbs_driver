import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DoCheckoutPage extends StatefulWidget {
  const DoCheckoutPage({super.key});

  @override
  State<DoCheckoutPage> createState() => _DoCheckoutPageState();
}

class _DoCheckoutPageState extends State<DoCheckoutPage> {
  final Color primaryYellow = const Color(0xFFFAAD14);
  final Color greyText = const Color(0xFF8C8C8C);
  final Color darkText = const Color(0xFF262626);
  final Color disabledGrey = const Color(0xFFBFBFBF);
  final Color redCheckout = const Color(0xFFFF4D4F);

  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Fungsi untuk memilih sumber foto (Kamera atau Galeri)
  Future<void> _showPicker(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(
      source: source,
      imageQuality: 50,
    );

    if (photo != null) {
      setState(() {
        _image = File(photo.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryYellow),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Check Out",
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Bagian Atas: Area Kamera/Galeri
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () =>
                            _showPicker(context), // Panggil pemilih sumber
                        child: Container(
                          width: double.infinity,
                          color: const Color(0xFFF5F5F5),
                          child: _image != null
                              ? Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.file(
                                        _image!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    // Tombol hapus foto jika ingin ganti
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.black54,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                          onPressed: () =>
                                              setState(() => _image = null),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt_rounded,
                                        size: 80,
                                        color: disabledGrey,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "Ambil atau Pilih Foto Bukti",
                                        style: TextStyle(color: greyText),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),

                    // Bagian Bawah: Informasi Detail
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  "Tanggal",
                                  "04/04/2023 12:00 WIB",
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem("Durasi", "48 Menit"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoItem(
                            "Alamat",
                            "Jl. Candi Lontar II No. 48\nSurabaya",
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  "Longitude",
                                  "-7.9376453",
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem("Latitude", "8.3987652"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _image == null
                                  ? null
                                  : () {
                                      // Logika Check Out
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _image != null
                                    ? redCheckout
                                    : disabledGrey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "Check Out",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: greyText, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
