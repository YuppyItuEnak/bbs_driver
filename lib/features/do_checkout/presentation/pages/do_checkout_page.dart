import 'dart:io';
import 'package:bbs_driver/data/models/delivery_order/delivery_order_model.dart';
import 'package:bbs_driver/data/models/delivery_order/surat_jalan_realisasi_model.dart';
import 'package:bbs_driver/data/services/delivery_order/do_repository.dart';
import 'package:bbs_driver/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_driver/features/deilvery_order/presentation/providers/do_provider.dart';
import 'package:bbs_driver/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

enum PageState { loading, checkIn, checkOut, error }

class DoCheckoutPage extends StatefulWidget {
  final List<String> doIds;
  final List<String> doCodes;
  final String customerName;
  const DoCheckoutPage({
    super.key,
    required this.doIds,
    required this.doCodes,
    required this.customerName,
  });

  @override
  State<DoCheckoutPage> createState() => _DoCheckoutPageState();
}

class _DoCheckoutPageState extends State<DoCheckoutPage> {
  // UI Constants
  final Color primaryYellow = const Color(0xFFFAAD14);
  final Color greyText = const Color(0xFF8C8C8C);
  final Color darkText = const Color(0xFF262626);
  final Color disabledGrey = const Color(0xFFBFBFBF);
  final Color redCheckout = const Color(0xFFFF4D4F);

  // Page State
  PageState _pageState = PageState.loading;
  String? _pageError;
  SjRealisasiModel? _sjRealisasi;

  // Form & Data State
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String _currentDateTime = '';
  String _latitude = '';
  String _longitude = '';
  String _address = '';
  String _duration = '';
  bool _isProcessing = false; // For both check-in and check-out
  bool _isFailed = false;
  final TextEditingController _failNoteCtrl = TextEditingController();

  final DoRepository _doRepo = DoRepository();
  bool _isLoadingDos = false;
  String? _doLoadError;
  List<DeliveryOrderModel> _doDetails = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePage();
      _loadDoDetails();
    });
  }

  @override
  void dispose() {
    _failNoteCtrl.dispose();
    super.dispose();
  }

  Future<void> _initializePage() async {
    _updateCurrentDateTime();
    await _requestAndSetLocation();

    final doProvider = context.read<DoProvider>();
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;

    if (token == null) {
      _setPageError('Sesi Anda telah berakhir, silakan login kembali.');
      return;
    }

    try {
      final openRealisasi = await doProvider.getOpenSjRealisasi(
        token: token,
        doIds: widget.doIds,
      );

      if (!mounted) return;

      if (openRealisasi != null) {
        // An open check-in exists, switch to Check-Out mode
        setState(() {
          _sjRealisasi = openRealisasi;
          _pageState = PageState.checkOut;
          _latitude = openRealisasi.latIn;
          _longitude = openRealisasi.longIn;
          _address = openRealisasi.addressIn ?? 'Alamat tidak tercatat';
        });
        _calculateDuration(openRealisasi.timeIn);
      } else {
        // No open check-in, switch to Check-In mode
        setState(() {
          _pageState = PageState.checkIn;
        });
      }
    } catch (e) {
      _setPageError('Gagal memuat data kunjungan: ${e.toString()}');
    }
  }

  void _setPageError(String error) {
    if (!mounted) return;
    setState(() {
      _pageState = PageState.error;
      _pageError = error;
    });
  }

  Future<void> _loadDoDetails() async {
    final auth = context.read<AuthProvider>();
    final token = auth.token;
    if (token == null) return;

    setState(() {
      _isLoadingDos = true;
      _doLoadError = null;
    });

    try {
      final results = await Future.wait(
        widget.doIds.map((id) => _doRepo.getDetailDo(token: token, doId: id)),
      );
      if (!mounted) return;
      setState(() {
        _doDetails = results;
        _isLoadingDos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingDos = false;
        _doLoadError = e.toString();
      });
    }
  }

  void _updateCurrentDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy HH:mm:ss \'WIB\'');
    if (mounted) {
      setState(() {
        _currentDateTime = formatter.format(now.toLocal());
      });
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

      if (mounted) {
        setState(() {
          if (hours > 0) {
            _duration = '$hours Jam $minutes Menit';
          } else {
            _duration = '$minutes Menit';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _duration = '-';
        });
      }
    }
  }

  Future<void> _getImage(ImageSource source) async {
    // Request permission first
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      final XFile? selectedImage = await _picker.pickImage(
        source: source,
        imageQuality: 50,
        maxWidth: 1080,
        maxHeight: 1920,
      );

      if (selectedImage != null) {
        if (mounted) {
          setState(() {
            _image = File(selectedImage.path);
          });
        }
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Izin ${source == ImageSource.camera ? 'kamera' : 'galeri'} ditolak permanen.',
            ),
            action: SnackBarAction(
              label: 'Pengaturan',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Izin ${source == ImageSource.camera ? 'kamera' : 'galeri'} diperlukan.',
            ),
          ),
        );
      }
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
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _requestAndSetLocation() async {
    if (!mounted) return;
    setState(() {
      _isProcessing = true;
    });

    // Check service status
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Layanan lokasi tidak aktif.')),
        );
      }
      setState(() => _isProcessing = false);
      return;
    }

    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak.')));
        }
        setState(() => _isProcessing = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Izin lokasi ditolak permanen, buka pengaturan aplikasi.',
            ),
          ),
        );
      }
      setState(() => _isProcessing = false);
      return;
    }

    // Get location
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
      });

      // Get address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        if (mounted) {
          setState(() {
            _address =
                '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mendapatkan lokasi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _performCheckIn(
    BuildContext context,
    DoProvider doProvider,
    AuthProvider authProvider,
  ) async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto bukti wajib diambil.')),
      );
      return;
    }
    if (_latitude.isEmpty || _longitude.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lokasi belum didapatkan.')));
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final token = authProvider.token;
      final userId = authProvider.user?.id;
      if (token == null || userId == null) {
        throw Exception('Sesi tidak valid, silakan login ulang.');
      }

      final now = DateTime.now().toUtc().toIso8601String();

      // Start SJ Realisasi (Check-In) - kolektif untuk semua DO dalam group
      // Catatan: startCustomerCheckin di DoProvider saat ini memulai SJ per-DO,
      // dan akan membentuk t_surat_jalan_realisasi untuk masing-masing DO.
      for (final doId in widget.doIds) {
        await doProvider.startCustomerCheckin(
          token: token,
          doId: doId,
          userId: userId,
          timeIn: now,
          latIn: _latitude,
          longIn: _longitude,
          addressIn: _address,
          photo: _image!,
        );
      }

      if (!mounted) return;

      // Ambil salah satu realisasi open untuk set durasi & mode check-out
      // (untuk duration UI saja; checkout akan menutup SJ realisasi per DO)
      final open = await doProvider.getOpenSjRealisasi(
        token: token,
        doIds: widget.doIds,
      );

      setState(() {
        _sjRealisasi = open;
        _pageState = PageState.checkOut;
        _isProcessing = false;
      });

      if (open != null) {
        _calculateDuration(open.timeIn);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Check-in gagal: $e')));
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _performCheckOut(
    BuildContext context,
    DoProvider doProvider,
    AuthProvider authProvider,
  ) async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto bukti wajib diambil.')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final token = authProvider.token;
      final userId = authProvider.user?.id;
      if (token == null || userId == null) {
        throw Exception('Sesi tidak valid, silakan login ulang.');
      }
      if (_sjRealisasi == null) {
        throw Exception('Data check-in tidak ditemukan.');
      }

      final now = DateTime.now().toUtc().toIso8601String();

      // Complete customer checkout
      await doProvider.completeCustomerCheckout(
        token: token,
        // sjRealisasiId: _sjRealisasi!.id,
        doIds: widget.doIds,
        userId: userId,
        timeOut: now,
        latOut: _latitude,
        longOut: _longitude,
        addressOut: _address,
        duration: _duration,
        photo: _image!,
        isFailed: _isFailed,
        note: _isFailed ? _failNoteCtrl.text : null,
      );

      if (mounted) {
        _showSuccessDialog(context, "Check out berhasil!");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Check-out gagal: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String message) {
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
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                  _pageState == PageState.checkIn
                      ? "Check In Kunjungan"
                      : "Check Out Kunjungan",
                  style: TextStyle(
                    color: darkText,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
              ),
              body: _buildBody(doProvider, authProvider),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(DoProvider doProvider, AuthProvider authProvider) {
    switch (_pageState) {
      case PageState.loading:
        return const Center(child: CircularProgressIndicator());
      case PageState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              _pageError ?? 'Terjadi kesalahan yang tidak diketahui.',
              textAlign: TextAlign.center,
              style: TextStyle(color: redCheckout),
            ),
          ),
        );
      case PageState.checkIn:
      case PageState.checkOut:
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(flex: 3, child: _buildPhotoSection()),
                      _buildInfoAndActionSection(doProvider, authProvider),
                    ],
                  ),
                ),
              ),
            );
          },
        );
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.customerName,
            style: TextStyle(
              color: darkText,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.doCodes.isEmpty ? '-' : widget.doCodes.join(', '),
            style: TextStyle(color: greyText, fontSize: 12),
          ),
          const SizedBox(height: 10),
          _buildDoItemsSection(),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        width: double.infinity,
        color: const Color(0xFFF5F5F5),
        child: _image != null
            ? Stack(
                children: [
                  Positioned.fill(
                    child: Image.file(_image!, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(() => _image = null),
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
                    Text("Ambil Foto Bukti", style: TextStyle(color: greyText)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoAndActionSection(
    DoProvider doProvider,
    AuthProvider authProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_pageState == PageState.checkOut) ...[
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Checkout'),
                    selected: !_isFailed,
                    onSelected: _isProcessing
                        ? null
                        : (_) => setState(() => _isFailed = false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Gagal'),
                    selected: _isFailed,
                    onSelected: _isProcessing
                        ? null
                        : (_) => setState(() => _isFailed = true),
                  ),
                ),
              ],
            ),
            if (_isFailed) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _failNoteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Catatan Gagal',
                  hintText: 'Masukkan alasan kegagalan...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
            const SizedBox(height: 20),
          ],
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'Waktu',
            value: _currentDateTime,
          ),
          const SizedBox(height: 12),
          if (_pageState == PageState.checkOut) ...[
            _buildInfoRow(
              icon: Icons.timer_outlined,
              label: 'Durasi',
              value: _duration,
            ),
            const SizedBox(height: 12),
          ],
          _buildInfoRow(
            icon: Icons.location_on,
            label: 'Lokasi',
            value: _address.isNotEmpty ? _address : 'Mendapatkan lokasi...',
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : () {
                      if (_pageState == PageState.checkIn) {
                        _performCheckIn(context, doProvider, authProvider);
                      } else {
                        _performCheckOut(context, doProvider, authProvider);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _pageState == PageState.checkIn
                    ? primaryYellow
                    : redCheckout,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _pageState == PageState.checkIn
                          ? 'CHECK IN'
                          : 'CHECK OUT',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: greyText, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: greyText, fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: darkText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoItemsSection() {
    if (_isLoadingDos) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_doLoadError != null) {
      return Text(
        'Gagal memuat detail DO: $_doLoadError',
        style: TextStyle(color: redCheckout),
      );
    }
    if (_doDetails.isEmpty) {
      return const Text('Tidak ada detail DO yang ditemukan.');
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _doDetails.expand((doItem) {
          return [
            Text(
              "DO: ${doItem.code}",
              style: TextStyle(fontWeight: FontWeight.bold, color: darkText),
            ),
            const SizedBox(height: 4),
            ...doItem.details.map((detail) {
              return Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2, bottom: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        detail.item!.name,
                        style: TextStyle(color: greyText, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${detail.qty}',
                      style: TextStyle(color: greyText, fontSize: 12),
                    ),
                  ],
                ),
              );
            }).toList(),
            if (_doDetails.length > 1 && doItem != _doDetails.last)
              const Divider(height: 16),
          ];
        }).toList(),
      ),
    );
  }
}
