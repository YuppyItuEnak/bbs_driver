import 'package:bbs_driver/core/constants/api_constants.dart';
import 'package:bbs_driver/core/constants/app_colors.dart';
import 'package:bbs_driver/data/models/reimburse/reimburse_add_model.dart';
import 'package:bbs_driver/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_driver/features/home/presentation/pages/home_page.dart';
import 'package:bbs_driver/features/reimburse/presentation/providers/reimburse_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

enum FormMode { create, update, fullEdit }

class AddReimbursePage extends StatelessWidget {
  final String? reimburseId;
  final bool isEdit;
  const AddReimbursePage({super.key, this.reimburseId, this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReimburseProvider(),
      child: _AddReimburseContent(reimburseId: reimburseId, isEdit: isEdit),
    );
  }
}

class _AddReimburseContent extends StatefulWidget {
  final String? reimburseId;
  final bool isEdit;
  const _AddReimburseContent({this.reimburseId, required this.isEdit});

  @override
  State<_AddReimburseContent> createState() => _AddReimburseContentState();
}

class _AddReimburseContentState extends State<_AddReimburseContent> {
  final _dateController = TextEditingController();
  final _amountController = TextEditingController();
  final _startKmController = TextEditingController();
  final _endKmController = TextEditingController();
  final _noteController = TextEditingController();

  double _calculatedTotal = 0.0;

  String _selectedType = "Bensin";
  File? _pickedFotoAwal;
  File? _pickedFotoAkhir;
  File? _pickedAttachment;
  String? _fotoAwalUrl;
  String? _fotoAkhirUrl;
  FormMode _formMode = FormMode.create;

  // ReadOnly flags for conditional editing
  bool _isStartKmReadOnly = false;
  bool _isEndKmReadOnly = false;
  bool _isNoteReadOnly = false;
  bool _isFotoAwalReadOnly = false;
  bool _isFotoAkhirReadOnly = false;

  @override
  void initState() {
    super.initState();
    _startKmController.addListener(_calculateReimbursement);
    _endKmController.addListener(_calculateReimbursement);

    _calculateReimbursement();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  Future<void> _initializeForm() async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<ReimburseProvider>();

    if (auth.token != null && auth.user!.id != null) {
      // Check if there's existing reimburse data for today
      await provider.checkReimburseToday(
        token: auth.token!,
        salesId: auth.user!.id!,
      );

      final checkData = provider.reimburseCheck;

      if (checkData != null) {
        // Load existing data
        await provider.getDetail(auth.token!, checkData.id);
        if (provider.selected != null) {
          final item = provider.selected!;
          setState(() {
            _dateController.text = DateFormat('dd/MM/yyyy').format(item.date);
            _amountController.text = item.total.toString();
            _startKmController.text = item.kmAwal.toString();
            _endKmController.text = item.kmAkhir.toString();
            _noteController.text = item.note ?? '';
            _selectedType = item.type;
            _fotoAwalUrl = item.fotoAwal != null && item.fotoAwal!.isNotEmpty
                ? '${ApiConstants.baseUrl2}/${item.fotoAwal}'
                : null;
            _fotoAkhirUrl = item.fotoAkhir != null && item.fotoAkhir!.isNotEmpty
                ? '${ApiConstants.baseUrl2}/${item.fotoAkhir}'
                : null;
          });
        }

        // Determine form mode based on existing data
        if (checkData.kmAwal != null &&
            (checkData.kmAkhir == null || checkData.kmAkhir == 0)) {
          setState(() {
            _formMode = FormMode.update;
            _setReadOnlyFlagsForUpdate();
          });
        } else if (checkData.kmAwal != null && checkData.kmAkhir != null) {
          // Condition 3: Complete data
          _formMode = FormMode.fullEdit;
          _setReadOnlyFlagsForFullEdit();
        }
      } else {
        // Condition 1: No existing data
        _formMode = FormMode.create;
        _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
        _setReadOnlyFlagsForCreate();
      }
    }
  }

  void _setReadOnlyFlagsForCreate() {
    _isStartKmReadOnly = false;
    _isEndKmReadOnly = true;
    _isNoteReadOnly = true;
    _isFotoAwalReadOnly = false;
    _isFotoAkhirReadOnly = true;
  }

  void _setReadOnlyFlagsForUpdate() {
    _isStartKmReadOnly = true;
    _isEndKmReadOnly = false;
    _isNoteReadOnly = false;
    _isFotoAwalReadOnly = true;
    _isFotoAkhirReadOnly = false;
  }

  void _setReadOnlyFlagsForFullEdit() {
    _isStartKmReadOnly = true;
    _isEndKmReadOnly = true;
    _isNoteReadOnly = true;
    _isFotoAwalReadOnly = true;
    _isFotoAkhirReadOnly = true;
  }

  @override
  void dispose() {
    _startKmController.removeListener(_calculateReimbursement);
    _endKmController.removeListener(_calculateReimbursement);
    _dateController.dispose();
    _amountController.dispose();
    _startKmController.dispose();
    _endKmController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _calculateReimbursement() {
    final startKm = _parseNumber(_startKmController.text);
    final endKm = _parseNumber(_endKmController.text);

    if (endKm > startKm) {
      final selisih = endKm - startKm;
      _calculatedTotal = (selisih / 30) * 10000;

      _amountController.text = NumberFormat(
        '#,##0.##',
        'id_ID',
      ).format(_calculatedTotal);
    } else {
      _calculatedTotal = 0.0;
      _amountController.text = "0";
    }
  }

  double _parseNumber(String text) {
    if (text.isEmpty) return 0;

    return double.tryParse(text) ?? 0;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Future<void> _pickImage(ImageSource source, Function(File?) onPick) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        onPick(File(pickedFile.path));
      });
    } else {
      setState(() {
        onPick(null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF5D5FEF);

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: Colors.black),
          title: Text(
            widget.isEdit ? 'Edit Reimburse' : 'Tambah Reimburse',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ),
        body: Consumer<ReimburseProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Tanggal*"),
                        _buildTextField(
                          controller: _dateController,
                          hint: "dd/MM/yyyy",
                          icon: Icons.calendar_today_outlined,
                          readOnly: false,
                          onTap: () => _selectDate(context),
                        ),
                        const SizedBox(height: 20),

                        _buildLabel("Deskripsi*"),
                        _buildDropdown(),
                        const SizedBox(height: 20),

                        // Form Dinamis berdasarkan Tipe
                        if (_selectedType == "Bensin") ...[
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel("Kilometer Awal*"),
                                    _buildTextField(
                                      controller: _startKmController,
                                      hint: "11.250",
                                      readOnly: _isStartKmReadOnly,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel("Kilometer Akhir*"),
                                    _buildTextField(
                                      controller: _endKmController,
                                      hint: "12.500",
                                      readOnly: _isEndKmReadOnly,
                                      onChanged: (_) =>
                                          _calculateReimbursement(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildLabel("Jumlah Reimburse (Rp)"),
                          _buildTextField(
                            controller: _amountController,
                            hint: "50.000",
                            readOnly: true,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildPhotoUpload(
                                  "Foto KM awal",
                                  _pickedFotoAwal,
                                  (file) => _pickedFotoAwal = file,
                                  readOnly: _isFotoAwalReadOnly,
                                  imageUrl: _fotoAwalUrl,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildPhotoUpload(
                                  "Foto KM akhir",
                                  _pickedFotoAkhir,
                                  (file) => _pickedFotoAkhir = file,
                                  readOnly: _isFotoAkhirReadOnly,
                                  imageUrl: _fotoAkhirUrl,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          _buildLabel("Jumlah Reimburse"),
                          _buildTextField(
                            controller: _amountController,
                            hint: "5.000",
                          ),
                          const SizedBox(height: 20),
                          _buildLabel("Attachment"),
                          _buildPhotoUpload(
                            null,
                            _pickedAttachment,
                            (file) => _pickedAttachment = file,
                            height: 180,
                            readOnly: false,
                          ),
                        ],

                        const SizedBox(height: 20),
                        _buildLabel("Catatan"),
                        _buildTextField(
                          controller: _noteController,
                          hint: "",
                          maxLines: 4,
                          readOnly: _isNoteReadOnly,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Bottom Buttons Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: _formMode == FormMode.fullEdit
                      ? const SizedBox.shrink() // No buttons for complete data
                      : Row(
                          children: [
                            if (_formMode == FormMode.create) ...[
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: provider.isLoading
                                      ? null
                                      : () => _showConfirmDialog(
                                          context,
                                          provider,
                                          false,
                                        ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                        color: Color(0xFF5D5FEF),
                                      ),
                                    ),
                                  ),
                                  child: provider.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF5D5FEF),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          "Simpan",
                                          style: TextStyle(
                                            color: Color(0xFF5D5FEF),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                ),
                              ),
                            ] else if (_formMode == FormMode.update) ...[
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: provider.isLoading
                                      ? null
                                      : () => _showConfirmDialog(
                                          context,
                                          provider,
                                          true,
                                        ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryPurple,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: provider.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          "Ajukan",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13),
      keyboardType: hint.contains("Kilometer") || hint.contains("Jumlah")
          ? TextInputType.number
          : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        suffixIcon: icon != null
            ? Icon(icon, color: Colors.black87, size: 18)
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF5D5FEF)),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
          items: ["Bensin"].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedType = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPhotoUpload(
    String? subLabel,
    File? currentImage,
    Function(File?) onImagePicked, {
    double height = 140,
    bool readOnly = false,
    String? imageUrl,
  }) {
    final hasImage =
        currentImage != null || (imageUrl != null && imageUrl.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              subLabel,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        InkWell(
          onTap: readOnly
              ? null
              : () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Camera'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.camera, onImagePicked);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.image),
                              title: const Text('Gallery'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.gallery, onImagePicked);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFF), // Light blue-ish grey background
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
              image: hasImage
                  ? DecorationImage(
                      image: currentImage != null
                          ? FileImage(currentImage)
                          : NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: !hasImage
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.grey.shade300,
                        size: 36,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  void _showConfirmDialog(
    BuildContext context,
    ReimburseProvider provider,
    bool isApproval,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Apakah Anda yakin?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              "Pastikan data yang input benar",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Batal",
                      style: TextStyle(color: Color(0xFF5D5FEF), fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context); // Close the dialog

                      final auth = context.read<AuthProvider>();
                      if (auth.token == null || auth.user!.id == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Autentikasi gagal, silakan login ulang.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      DateTime? date;
                      try {
                        date = DateFormat(
                          'dd/MM/yyyy',
                        ).parse(_dateController.text);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Format tanggal tidak valid.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final newReimburse = ReimburseCreateModel(
                        salesId: auth.user!.id!,
                        type: _selectedType,
                        date: date!,
                        unitBusinessId: "",
                        total: _calculatedTotal,
                        kmAwal: double.tryParse(_startKmController.text) ?? 0,
                        kmAkhir: double.tryParse(_endKmController.text) ?? 0,
                        note: _noteController.text,
                        fotoAwal: "",
                        fotoAkhir: "",
                        approvalCount: 0,
                        approvedCount: 0,
                        approvalLevel: 1,
                        status: isApproval ? "DRAFT" : "DRAFT",
                      );

                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);

                      bool operationSuccess = false;
                      String? reimburseIdForApproval;

                      if (widget.isEdit) {
                        final existingItem = provider.selected!;
                        final updatedReimburse = ReimburseCreateModel(
                          salesId: newReimburse.salesId,
                          type: newReimburse.type,
                          date: newReimburse.date,
                          unitBusinessId: newReimburse.unitBusinessId,
                          total: (newReimburse.total! / 30) * 10000,
                          kmAwal: newReimburse.kmAwal,
                          kmAkhir: newReimburse.kmAkhir,
                          note: newReimburse.note,
                          fotoAwal: _pickedFotoAwal != null
                              ? ""
                              : existingItem.fotoAwal ?? "",
                          fotoAkhir: "",
                          approvalCount: newReimburse.approvalCount,
                          approvedCount: newReimburse.approvedCount,
                          approvalLevel: newReimburse.approvalLevel,
                          status: newReimburse.status,
                        );

                        operationSuccess = await provider.update(
                          auth.token!,
                          widget.reimburseId!,
                          updatedReimburse,
                          _pickedFotoAwal,
                          _pickedFotoAkhir,
                        );
                        if (operationSuccess) {
                          reimburseIdForApproval = widget.reimburseId!;
                        }
                      } else {
                        final createdReimburse = await provider.create(
                          auth.token!,
                          newReimburse,
                          _pickedFotoAwal,
                          _pickedFotoAkhir,
                        );
                        if (createdReimburse != null) {
                          operationSuccess = true;
                          reimburseIdForApproval = createdReimburse.id!;
                        }
                      }

                      if (operationSuccess && reimburseIdForApproval != null) {
                        if (isApproval) {
                          final approvalSuccess = await provider
                              .requestApproval(
                                token: auth.token!,
                                reimburseId: reimburseIdForApproval,
                                userId: auth.user!.id,
                              );

                          if (approvalSuccess) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Reimburse berhasil diajukan untuk approval!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );

                            navigator.pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const HomePage(),
                              ),
                              (_) => false,
                            );
                          } else {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Gagal mengajukan approval reimburse: ${provider.error ?? "Terjadi kesalahan"}',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else {
                          // Not for approval, just save/update
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                widget.isEdit
                                    ? 'Reimburse berhasil diperbarui!'
                                    : 'Reimburse berhasil disimpan sebagai draft!',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );

                          navigator.pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const HomePage()),
                            (_) => false,
                          );
                        }
                      } else if (context.mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Gagal ${widget.isEdit ? 'memperbarui' : 'menyimpan'} reimburse: ${provider.error ?? "Terjadi kesalahan"}',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D5FEF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Iya",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
