import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// Import file widget yang baru dibuat
import '../widgets/checkin_item.dart';

class DoCheckinPage extends StatefulWidget {
  const DoCheckinPage({super.key});

  @override
  State<DoCheckinPage> createState() => _DoCheckinPageState();
}

class _DoCheckinPageState extends State<DoCheckinPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _getImage(ImageSource source) async {
    final XFile? selectedImage = await _picker.pickImage(
      source: source,
      imageQuality: 50,
    );

    if (selectedImage != null) {
      setState(() {
        _image = File(selectedImage.path);
      });
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri Foto'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      extendBodyBehindAppBar: _image != null,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: _image != null ? Colors.yellow : Colors.orange,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Check In",
          style: TextStyle(
            color: _image != null ? Colors.white : const Color(0xFF333333),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => _showPicker(context),
              child: Container(
                width: double.infinity,
                color: _image == null ? const Color(0xFFF5F5F5) : Colors.black,
                child: _image == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_rounded,
                            size: 100,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          const Text(
                            "Ketuk untuk Pilih Foto/Kamera",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    : Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckinItem.infoTile(
                  label: "Tanggal",
                  value: "04/04/2023 11:20 WIB",
                ),
                const SizedBox(height: 20),
                CheckinItem.infoTile(
                  label: "Alamat",
                  value: "Jl. Candi Lontar II No. 48 Surabaya",
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CheckinItem.infoTile(
                        label: "Longitude",
                        value: "-7.9376453",
                      ),
                    ),
                    Expanded(
                      child: CheckinItem.infoTile(
                        label: "Latitude",
                        value: "8.3987652",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),

                // Menggunakan Widget Tombol dari file eksternal
                CheckinItem.actionButton(
                  isActive: _image != null,
                  onPressed: () {
                    // Logika submit Anda di sini
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
