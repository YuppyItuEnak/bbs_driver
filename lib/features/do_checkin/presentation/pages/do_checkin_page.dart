import 'dart:io';
import 'package:bbs_driver/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_driver/features/deilvery_order/presentation/providers/do_provider.dart';
import 'package:bbs_driver/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
// Import file widget yang baru dibuat
import '../widgets/checkin_item.dart';

class DoCheckinPage extends StatefulWidget {
  final String doId;
  const DoCheckinPage({super.key, required this.doId});

  @override
  State<DoCheckinPage> createState() => _DoCheckinPageState();
}

class _DoCheckinPageState extends State<DoCheckinPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Real data variables
  String _currentDateTime = '';
  String _latitude = '';
  String _longitude = '';
  String _address = '';
  bool _isLoadingLocation = false;
  bool _isCheckingIn = false;

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User harus menekan tombol untuk keluar
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Dialog mengecil sesuai isi
              children: [
                // Ilustrasi (Ganti dengan Image.asset jika sudah ada filenya)
                Container(
                  height: 180,
                  width: 180,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/success_illustration.png',
                      ), // Sesuaikan path asset Anda
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Placeholder jika file gambar belum ada:
                  // child: const Icon(Icons.check_circle_outline, size: 100, color: Color(0xFFFFB703)),
                ),
                const SizedBox(height: 20),

                // Teks Berhasil
                const Text(
                  "Check in berhasil!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 30),

                // Tombol KEMBALI
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const HomePage(startAsCheckedIn: true),
                        ),
                        (route) =>
                            false, // Menghapus semua tumpukan halaman sebelumnya
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB703),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "KEMBALI",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () async {
                  await _requestCameraPermission();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;

    if (status.isGranted) {
      await _getImage(ImageSource.camera);
    } else if (status.isDenied) {
      // Request permission
      status = await Permission.camera.request();
      if (status.isGranted) {
        await _getImage(ImageSource.camera);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Izin kamera diperlukan untuk mengambil foto'),
            action: SnackBarAction(
              label: 'Coba Lagi',
              onPressed: () => _requestCameraPermission(),
            ),
          ),
        );
      }
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Izin kamera ditolak permanen. Buka pengaturan aplikasi',
          ),
          action: SnackBarAction(
            label: 'Pengaturan',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }
  }

  Future<void> _requestLocationPermission() async {
    PermissionStatus status = await Permission.location.status;

    if (status.isGranted) {
      await _getCurrentLocation();
    } else if (status.isDenied) {
      // Request permission
      status = await Permission.location.request();
      if (status.isGranted) {
        await _getCurrentLocation();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Izin lokasi diperlukan untuk check-in'),
            action: SnackBarAction(
              label: 'Coba Lagi',
              onPressed: () => _requestLocationPermission(),
            ),
          ),
        );
      }
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Izin lokasi ditolak permanen. Buka pengaturan aplikasi',
          ),
          action: SnackBarAction(
            label: 'Pengaturan',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }
  }

  void _updateCurrentDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy HH:mm:ss \'WIB\'');
    setState(() {
      _currentDateTime = formatter.format(now.toLocal());
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
      });

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _address =
              '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
        });
      }
    } catch (e) {
      setState(() {
        _address = 'Gagal mendapatkan lokasi';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error mendapatkan lokasi: $e')));
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _performCheckIn(
    BuildContext context,
    DoProvider doProvider,
    AuthProvider authProvider,
  ) async {
    if (_image == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Foto wajib diambil')));
      return;
    }

    if (_latitude.isEmpty || _longitude.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lokasi belum didapatkan')));
      return;
    }

    setState(() {
      _isCheckingIn = true;
    });

    try {
      final now = DateTime.now().toUtc();
      final timeIn = now.toIso8601String();

      await doProvider.checkIn(
        token: authProvider.token!,
        doId: widget.doId,
        timeIn: timeIn,
        latIn: _latitude,
        longIn: _longitude,
        addressIn: _address,
        photo: _image!,
      );

      _showSuccessDialog(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Check-in gagal: $e')));
    } finally {
      setState(() {
        _isCheckingIn = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _updateCurrentDateTime();
    _requestLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DoProvider>(
      builder: (context, doProvider, child) {
        return Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
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
                    color: _image != null
                        ? Colors.white
                        : const Color(0xFF333333),
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
                        color: _image == null
                            ? const Color(0xFFF5F5F5)
                            : Colors.black,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 30,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckinItem.infoTile(
                          label: "Tanggal",
                          value: _currentDateTime.isNotEmpty
                              ? _currentDateTime
                              : "Memuat...",
                        ),
                        const SizedBox(height: 20),
                        CheckinItem.infoTile(
                          label: "Alamat",
                          value: _isLoadingLocation
                              ? "Mencari lokasi..."
                              : (_address.isNotEmpty
                                    ? _address
                                    : "Lokasi tidak ditemukan"),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: CheckinItem.infoTile(
                                label: "Longitude",
                                value: _longitude.isNotEmpty
                                    ? _longitude
                                    : "Memuat...",
                              ),
                            ),
                            Expanded(
                              child: CheckinItem.infoTile(
                                label: "Latitude",
                                value: _latitude.isNotEmpty
                                    ? _latitude
                                    : "Memuat...",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 35),

                        // Menggunakan Widget Tombol dari file eksternal
                        CheckinItem.actionButton(
                          isActive: _image != null && !_isCheckingIn,
                          onPressed: _isCheckingIn
                              ? null
                              : () => _performCheckIn(
                                  context,
                                  doProvider,
                                  authProvider,
                                ),
                          text: "Check In",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
