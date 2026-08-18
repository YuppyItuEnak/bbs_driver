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

class EditReimbursePage extends StatelessWidget {
  final String reimburseId;
  const EditReimbursePage({super.key, required this.reimburseId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReimburseProvider(),
      child: _EditReimburseContent(reimburseId: reimburseId),
    );
  }
}

class _EditReimburseContent extends StatefulWidget {
  final String reimburseId;
  const _EditReimburseContent({required this.reimburseId});

  @override
  State<_EditReimburseContent> createState() => _EditReimburseContentState();
}

class _EditReimburseContentState extends State<_EditReimburseContent> {
  final _dateController = TextEditingController();
  final _amountController = TextEditingController();
  final _startKmController = TextEditingController();
  final _endKmController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedType = "Driver";
  File? _pickedFotoAwal;
  File? _pickedFotoAkhir;
  String? _fotoAwalUrl;
  String? _fotoAkhirUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetail();
    });
  }

  Future<void> _loadDetail() async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<ReimburseProvider>();
    if (auth.token == null) return;

    await provider.getDetail(auth.token!, widget.reimburseId);
    if (provider.selected == null || !mounted) return;

    final item = provider.selected!;
    setState(() {
      _dateController.text = DateFormat('dd/MM/yyyy').format(item.date);
      _amountController.text =
          item.total != null ? item.total!.toStringAsFixed(0) : '0';
      _startKmController.text = item.kmAwal.toString();
      _endKmController.text = item.kmAkhir.toString();
      _noteController.text = item.note ?? '';
      _selectedType = "Driver";
      _fotoAwalUrl = item.fotoAwal != null && item.fotoAwal!.isNotEmpty
          ? '${ApiConstants.baseUrl2}/${item.fotoAwal}'
          : null;
      _fotoAkhirUrl = item.fotoAkhir != null && item.fotoAkhir!.isNotEmpty
          ? '${ApiConstants.baseUrl2}/${item.fotoAkhir}'
          : null;
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _startKmController.dispose();
    _endKmController.dispose();
    _noteController.dispose();
    super.dispose();
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
    setState(() {
      onPick(pickedFile != null ? File(pickedFile.path) : null);
    });
  }

  bool _validateForm() {
    final kmAwal = _parseNumber(_startKmController.text);
    final kmAkhir = _parseNumber(_endKmController.text);
    final totalAmount = _parseNumber(_amountController.text);

    if (totalAmount <= 0) {
      _showError('Jumlah reimburse wajib diisi dan tidak boleh 0.');
      return false;
    }
    if (kmAwal <= 0) {
      _showError('KM awal wajib diisi.');
      return false;
    }
    if (_pickedFotoAwal == null &&
        (_fotoAwalUrl == null || _fotoAwalUrl!.isEmpty)) {
      _showError('Foto KM awal wajib diisi.');
      return false;
    }
    if (kmAkhir <= 0) {
      _showError('KM akhir wajib diisi.');
      return false;
    }
    if (_pickedFotoAkhir == null &&
        (_fotoAkhirUrl == null || _fotoAkhirUrl!.isEmpty)) {
      _showError('Foto KM akhir wajib diisi.');
      return false;
    }
    if (kmAkhir < kmAwal) {
      _showError('KM akhir tidak boleh kurang dari KM awal.');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _submit() {
    if (!_validateForm()) return;
    _showConfirmDialog();
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
                    onPressed: () => Navigator.pop(dialogContext),
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
                      Navigator.pop(dialogContext);
                      await _doUpdate();
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

  double _parseNumber(String text) {
    // Handle Indonesian format: "50.000" → 50000, "1.250.000" → 1250000
    final cleaned = text.replaceAll('.', '');
    return double.tryParse(cleaned) ?? 0;
  }

  /// Strip baseUrl2 prefix from full URL to get relative path for API.
  /// e.g. "https://server.qqltech.com:7180/uploads/file.jpg" → "uploads/file.jpg"
  String? _toRelativePath(String? fullUrl) {
    if (fullUrl == null || fullUrl.isEmpty) return null;
    final prefix = '${ApiConstants.baseUrl2}/';
    if (fullUrl.startsWith(prefix)) {
      return fullUrl.substring(prefix.length);
    }
    return fullUrl;
  }

  Future<void> _doUpdate() async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<ReimburseProvider>();

    if (auth.token == null || auth.user?.id == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Autentikasi gagal, silakan login ulang.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final date = DateFormat('dd/MM/yyyy').parse(_dateController.text);
    final existingItem = provider.selected!;

    final updatedReimburse = ReimburseCreateModel(
      salesId: auth.user!.id!,
      type: _selectedType,
      date: date,
      unitBusinessId: existingItem.unitBusinessId ?? auth.unitBusinessId ?? "",
      total: _parseNumber(_amountController.text),
      kmAwal: _parseNumber(_startKmController.text),
      kmAkhir: _parseNumber(_endKmController.text),
      note: _noteController.text,
      fotoAwal: _pickedFotoAwal != null
          ? ""
          : (_toRelativePath(existingItem.fotoAwal) ?? ""),
      fotoAkhir: _pickedFotoAkhir != null
          ? ""
          : (_toRelativePath(existingItem.fotoAkhir) ?? ""),
      approvalCount: existingItem.approvalCount ?? 0,
      approvedCount: existingItem.approvedCount ?? 0,
      approvalLevel: existingItem.currentApprovalLevel ?? 1,
      status: "DRAFT",
    );

    final success = await provider.update(
      auth.token!,
      widget.reimburseId,
      updatedReimburse,
      _pickedFotoAwal,
      _pickedFotoAkhir,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memperbarui reimburse: ${provider.error ?? "Terjadi kesalahan"}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final approvalSuccess = await provider.requestApproval(
      token: auth.token!,
      reimburseId: widget.reimburseId,
      userId: auth.user!.id,
    );

    if (!mounted) return;

    if (approvalSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reimburse berhasil diajukan untuk approval!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengajukan approval: ${provider.error ?? "Terjadi kesalahan"}',
          ),
          backgroundColor: Colors.red,
        ),
      );
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
          title: const Text(
            'Edit Reimburse',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ),
        body: Consumer<ReimburseProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.selected == null) {
              return const Center(child: CircularProgressIndicator());
            }

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
                          onTap: () => _selectDate(context),
                        ),
                        const SizedBox(height: 20),

                        _buildLabel("Deskripsi*"),
                        _buildDropdown(),
                        const SizedBox(height: 20),

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
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPhotoUpload(
                                "Foto KM awal",
                                _pickedFotoAwal,
                                (file) => _pickedFotoAwal = file,
                                imageUrl: _fotoAwalUrl,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildPhotoUpload(
                                "Foto KM akhir",
                                _pickedFotoAkhir,
                                (file) => _pickedFotoAkhir = file,
                                imageUrl: _fotoAkhirUrl,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildLabel("Catatan"),
                        _buildTextField(
                          controller: _noteController,
                          hint: "",
                          maxLines: 4,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Submit button
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
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: onTap != null,
      onTap: onTap,
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
          items: ["Driver"].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
          onChanged: null,
        ),
      ),
    );
  }

  Widget _buildPhotoUpload(
    String? subLabel,
    File? currentImage,
    Function(File?) onImagePicked, {
    double height = 140,
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
          onTap: () => _pickImage(ImageSource.camera, onImagePicked),
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFF),
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
}
