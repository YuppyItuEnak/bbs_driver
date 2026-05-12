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

class DpCheckinPage extends StatefulWidget {
  const DpCheckinPage({super.key});

  @override
  State<DpCheckinPage> createState() => _DpCheckinPageState();
}

class _DpCheckinPageState extends State<DpCheckinPage> {
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color greyText = const Color(0xFF8C8C8C);
  final Color darkText = const Color(0xFF262626);

  File? _image;
  final ImagePicker _picker = ImagePicker();

  String _currentDateTime = '';
  String _latitude = '';
  String _longitude = '';
  String _address = '';
  bool _isLoadingLocation = false;
  bool _isCheckingIn = false;

  @override
  void initState() {
    super.initState();
    _updateCurrentDateTime();
    _requestLocationPermission();
  }

  void _updateCurrentDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy HH:mm:ss \'WIB\'');
    setState(() {
      _currentDateTime = formatter.format(now.toLocal());
    });
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
                  if (mounted) Navigator.of(context).pop();
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
      return;
    }
    status = await Permission.camera.request();
    if (status.isGranted) {
      await _getImage(ImageSource.camera);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Izin kamera diperlukan untuk mengambil foto'),
      ),
    );
  }

  Future<void> _requestLocationPermission() async {
    PermissionStatus status = await Permission.location.status;
    if (status.isGranted) {
      await _getCurrentLocation();
      return;
    }
    status = await Permission.location.request();
    if (status.isGranted) {
      await _getCurrentLocation();
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Izin lokasi diperlukan untuk check-in')),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
      });

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _address =
              '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
        });
      }
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

    final userId = authProvider.user?.id;
    final token = authProvider.token;
    if (userId == null || token == null) return;

    setState(() => _isCheckingIn = true);
    try {
      final now = DateTime.now().toUtc();
      final timeIn = now.toIso8601String();

      await doProvider.checkInDeliveryPlanOnly(
        token: token,
          deliveryPlanId: '',
        userId: userId,
        timeIn: timeIn,
        latIn: _latitude,
        longIn: _longitude,
        addressIn: _address,
        photo: _image!,
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(startAsCheckedIn: true),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Check-in gagal: $e')));
    } finally {
      if (mounted) setState(() => _isCheckingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DoProvider>(
      builder: (context, doProvider, _) {
        return Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: primaryGreen),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  "Check In",
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
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: GestureDetector(
                                onTap: () => _showPicker(context),
                                child: Container(
                                  width: double.infinity,
                                  color: const Color(0xFFF5F5F5),
                                  child: _image == null
                                      ? const Center(
                                          child: Icon(
                                            Icons.camera_alt_rounded,
                                            size: 80,
                                            color: Colors.grey,
                                          ),
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
                                  _infoTile("Tanggal", _currentDateTime),
                                  const SizedBox(height: 20),
                                  _infoTile(
                                    "Alamat",
                                    _isLoadingLocation
                                        ? "Mencari lokasi..."
                                        : (_address.isNotEmpty
                                              ? _address
                                              : "-"),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _infoTile(
                                          "Longitude",
                                          _longitude.isNotEmpty
                                              ? _longitude
                                              : "-",
                                        ),
                                      ),
                                      Expanded(
                                        child: _infoTile(
                                          "Latitude",
                                          _latitude.isNotEmpty
                                              ? _latitude
                                              : "-",
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 35),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: _isCheckingIn
                                          ? null
                                          : () => _performCheckIn(
                                              context,
                                              doProvider,
                                              authProvider,
                                            ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryGreen,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "Check In",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Check-in ini hanya untuk Delivery Plan Realisasi.",
                                    style: TextStyle(
                                      color: greyText,
                                      fontSize: 11,
                                    ),
                                  ),
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
          },
        );
      },
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }
}
