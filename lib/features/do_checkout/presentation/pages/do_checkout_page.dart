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

class DoCheckoutPage extends StatefulWidget {
  final String doId;
  final String? checkInId;
  const DoCheckoutPage({super.key, required this.doId, this.checkInId});

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

  // Real data variables
  String _currentDateTime = '';
  String _latitude = '';
  String _longitude = '';
  String _address = '';
  String _checkInTime = '';
  String _duration = '';
  bool _isLoadingLocation = false;
  bool _isCheckingOut = false;

  @override
  void initState() {
    super.initState();
    _updateCurrentDateTime();
    _requestLocationPermission();
    _getCheckInData();
  }

  void _updateCurrentDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy HH:mm:ss \'WIB\'');
    setState(() {
      _currentDateTime = formatter.format(now.toLocal());
    });
  }

  void _getCheckInData() {
    final doProvider = context.read<DoProvider>();
    final checkInStatus = doProvider.checkInStatus;

    if (checkInStatus['has_open'] == true) {
      final data = checkInStatus['data'] as List;
      for (var item in data) {
        if (item['t_surat_jalan_id'] == widget.doId &&
            item['time_out'] == null) {
          setState(() {
            _checkInTime = item['time_in'] ?? '';
            _latitude = item['lat_in']?.toString() ?? '';
            _longitude = item['long_in']?.toString() ?? '';
            _address = item['address_in'] ?? '';
          });
          _calculateDuration(_checkInTime);
          break;
        }
      }
    }
  }

  void _calculateDuration(String checkInTime) {
    if (checkInTime.isEmpty) return;

    try {
      final checkIn = DateTime.parse(checkInTime).toLocal();
      final checkOut = DateTime.now();
      final difference = checkOut.difference(checkIn);

      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;

      setState(() {
        if (hours > 0) {
          _duration = '$hours Jam $minutes Menit';
        } else {
          _duration = '$minutes Menit';
        }
      });
    } catch (e) {
      setState(() {
        _duration = '-';
      });
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 180,
                  width: 180,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/success_confirm.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Check out berhasil!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                        (route) => false,
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
      status = await Permission.location.request();
      if (status.isGranted) {
        await _getCurrentLocation();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Izin lokasi diperlukan untuk check-out'),
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

  Future<void> _performCheckOut(
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

    // Get the checkInId - prefer the one passed via constructor, otherwise get from checkInStatus
    String checkInId = widget.checkInId ?? '';
    if (checkInId.isEmpty) {
      final checkInStatus = doProvider.checkInStatus;
      if (checkInStatus['has_open'] == true) {
        final data = checkInStatus['data'] as List;
        for (var item in data) {
          if (item['t_surat_jalan_id'] == widget.doId &&
              item['time_out'] == null) {
            checkInId = item['id'] ?? '';
            break;
          }
        }
      }
    }

    if (checkInId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data check-in tidak ditemukan')),
      );
      return;
    }

    setState(() {
      _isCheckingOut = true;
    });

    try {
      final now = DateTime.now().toUtc();
      final timeOut = now.toIso8601String();

      await doProvider.checkOut(
        token: authProvider.token!,
        checkInId: checkInId,
        doId: widget.doId,
        timeOut: timeOut,
        latOut: _latitude,
        longOut: _longitude,
        addressOut: _address,
        duration: _duration,
        photo: _image!,
      );

      _showSuccessDialog(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Check-out gagal: $e')));
    } finally {
      setState(() {
        _isCheckingOut = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DoProvider>(
      builder: (context, doProvider, child) {
        return Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
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
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            // Bagian Atas: Area Kamera/Galeri
                            Expanded(
                              flex: 3,
                              child: GestureDetector(
                                onTap: () => _showPicker(context),
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
                                                  onPressed: () => setState(
                                                    () => _image = null,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.camera_alt_rounded,
                                                size: 80,
                                                color: disabledGrey,
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                "Ambil atau Pilih Foto Bukti",
                                                style: TextStyle(
                                                  color: greyText,
                                                ),
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
                                          _currentDateTime.isNotEmpty
                                              ? _currentDateTime
                                              : "Memuat...",
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildInfoItem(
                                          "Durasi",
                                          _duration.isNotEmpty
                                              ? _duration
                                              : "Memuat...",
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoItem(
                                    "Alamat",
                                    _isLoadingLocation
                                        ? "Mencari lokasi..."
                                        : (_address.isNotEmpty
                                              ? _address
                                              : "Lokasi tidak ditemukan"),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInfoItem(
                                          "Longitude",
                                          _longitude.isNotEmpty
                                              ? _longitude
                                              : "Memuat...",
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildInfoItem(
                                          "Latitude",
                                          _latitude.isNotEmpty
                                              ? _latitude
                                              : "Memuat...",
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 40),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: _isCheckingOut
                                          ? null
                                          : () => _performCheckOut(
                                              context,
                                              doProvider,
                                              authProvider,
                                            ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _image != null
                                            ? redCheckout
                                            : disabledGrey,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        _isCheckingOut
                                            ? "Memproses..."
                                            : "Check Out",
                                        style: const TextStyle(
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
          },
        );
      },
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
