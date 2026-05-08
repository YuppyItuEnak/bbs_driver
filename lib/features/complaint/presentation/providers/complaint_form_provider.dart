import 'dart:io';

import 'package:bbs_driver/data/models/complaint/complaint_add_model.dart';
import 'package:bbs_driver/data/models/customer/customer_name_model.dart';
import 'package:bbs_driver/data/models/delivery_order/surat_jalan_model.dart';
import 'package:bbs_driver/data/models/general/m_gen_model.dart';
import 'package:bbs_driver/data/services/complaint/complaint_repository.dart';
import 'package:bbs_driver/data/services/customer/customer_repository.dart';
import 'package:bbs_driver/data/services/general/m_gen_repository.dart';
import 'package:bbs_driver/data/services/delivery_order/surat_jalan_repository.dart';
import 'package:bbs_driver/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ComplaintFormProvider extends ChangeNotifier {
  final CustomerRepository _customerRepo = CustomerRepository();
  final MGenRepository _mGenRepo = MGenRepository();
  final ComplainRepository _complainRepo = ComplainRepository();
  final SuratJalanRepository _suratJalanRepo = SuratJalanRepository();

  bool _isLoading = false;
  bool _isLoadingSuratJalan = false;
  String? _error;
  String? _suratJalanError;

  List<CustomerSimpleModel> _customers = [];
  List<MGenModel> _complaintTypes = [];
  List<SuratJalanModel> _suratJalan = [];
  SuratJalanModel? _selectedSuratJalan;
  String? _editingComplaintId;

  // Form Fields
  CustomerSimpleModel? _selectedCustomer;
  MGenModel? _selectedComplaintType;
  // String? _selectedInvoice; // OLD

  final TextEditingController contactPersonCtrl = TextEditingController();

  // Items
  List<ComplainCreateItemModel> _items = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingSuratJalan => _isLoadingSuratJalan;
  String? get error => _error;
  String? get suratJalanError => _suratJalanError;
  List<CustomerSimpleModel> get customers => _customers;
  List<MGenModel> get complaintTypes => _complaintTypes;
  List<SuratJalanModel> get suratJalan => _suratJalan;
  SuratJalanModel? get selectedSuratJalan => _selectedSuratJalan;

  CustomerSimpleModel? get selectedCustomer => _selectedCustomer;
  MGenModel? get selectedComplaintType => _selectedComplaintType;
  // String? get selectedInvoice => _selectedInvoice; // OLD
  List<ComplainCreateItemModel> get items => _items;
  String? get editingComplaintId => _editingComplaintId;

  bool get isEditMode => _editingComplaintId != null;

  Future<void> loadData({
    required String token,
    required String unitBusinessId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _customerRepo.fetchListCustomersName(
          token,
          search: '',
          unitBusinessId: unitBusinessId,
        ),
        _mGenRepo.fetchMGen("group=m_complain_type", token),
      ]);

      _customers = results[0] as List<CustomerSimpleModel>;
      _complaintTypes = results[1] as List<MGenModel>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadForEdit({
    required String token,
    required String complaintId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final detail = await _complainRepo.getDetailComplaint(
        token: token,
        id: complaintId,
      );

      _editingComplaintId = detail.id;

      _selectedCustomer = _customers.firstWhere(
        (c) => c.id == detail.customerId,
        orElse: () => _customers.isNotEmpty
            ? _customers.first
            : CustomerSimpleModel(id: '', name: ''),
      );

      _selectedComplaintType = _complaintTypes.firstWhere(
        (t) => t.id == detail.complainTypeId,
        orElse: () => _complaintTypes.isNotEmpty
            ? _complaintTypes.first
            : MGenModel(id: '', group: '', value1: ''),
      );

      contactPersonCtrl.text = detail.notes ?? '';

      // Load Surat Jalan list for selected customer using provided token.
      _suratJalan = [];
      _selectedSuratJalan = null;
      _suratJalanError = null;
      _isLoadingSuratJalan = true;
      notifyListeners();

      if ((_selectedCustomer?.id ?? '').isNotEmpty) {
        _suratJalan = await _suratJalanRepo.fetchSuratJalan(
          token: token,
          customerId: _selectedCustomer!.id!,
        );
        if (detail.sjId != null) {
          _selectedSuratJalan = _suratJalan.cast<SuratJalanModel?>().firstWhere(
            (e) => e?.id == detail.sjId,
            orElse: () => null,
          );
        }
      }

      // Prefill items
      _items = detail.items
          .map(
            (i) => ComplainCreateItemModel()
              ..itemId = i.itemId
              ..itemName = i.itemName
              ..qtyRef = i.qtyRef
              ..qtyReturn = i.qtyReturn
              ..uomUnit = i.uomUnit
              ..reasonId = i.reasonId
              ..soId = i.soId
              ..sjId = i.sjId
              ..imageUrls = i.images
                  .map((e) => e.imageUrl ?? '')
                  .where((u) => u.isNotEmpty)
                  .toList(),
          )
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isLoadingSuratJalan = false;
      notifyListeners();
    }
  }

  void resetForm() {
    _editingComplaintId = null;
    _error = null;
    _suratJalanError = null;
    _selectedCustomer = null;
    _selectedComplaintType = null;
    _selectedSuratJalan = null;
    _suratJalan = [];
    _items = [];
    contactPersonCtrl.clear();
    notifyListeners();
  }

  void setCustomer(BuildContext context, CustomerSimpleModel? val) async {
    _selectedCustomer = val;
    _suratJalan = [];
    _selectedSuratJalan = null;
    _suratJalanError = null;
    notifyListeners();

    if (val != null && val.id != null) {
      _isLoadingSuratJalan = true;
      notifyListeners();

      final auth = context.read<AuthProvider>();
      if (auth.token != null) {
        try {
          _suratJalan = await _suratJalanRepo.fetchSuratJalan(
            token: auth.token!,
            customerId: val.id!,
          );
        } catch (e) {
          _suratJalanError = e.toString();
        }
      } else {
        _suratJalanError = 'Authentication token is missing.';
      }

      _isLoadingSuratJalan = false;
      notifyListeners();
    }
  }

  void setComplaintType(MGenModel? val) {
    _selectedComplaintType = val;
    notifyListeners();
  }

  void setSuratJalan(SuratJalanModel? val) {
    _selectedSuratJalan = val;
    notifyListeners();
  }

  void addItem(ComplainCreateItemModel item) {
    _items.add(item);
    notifyListeners();
  }

  void addItems(List<ComplainCreateItemModel> newItems) {
    _items.addAll(newItems);
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void updateItemQuantities(
    int index, {
    int? newQtyReturn,
    int? newQtyReplaced,
  }) {
    if (newQtyReturn != null) {
      _items[index].qtyReturn = newQtyReturn;
    }
    if (newQtyReplaced != null) {
      _items[index].qtyReplaced = newQtyReplaced;
    }
    notifyListeners();
  }

  Future<void> pickImageForItem(int index) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      _items[index].imageFiles.add(File(image.path));
      notifyListeners();
    }
  }

  void removeImageFromItem(int itemIndex, int imageIndex) {
    _items[itemIndex].imageFiles.removeAt(imageIndex);
    notifyListeners();
  }

  Future<bool> submit({
    required String token,
    required String salesId,
    required String unitBusinessId,
  }) async {
    if (_selectedCustomer == null ||
        _selectedComplaintType == null ||
        _selectedSuratJalan == null) {
      _error = "Mohon lengkapi data";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final data = ComplainCreateModel()
        ..customerId = _selectedCustomer!.id
        ..customer = _selectedCustomer!.name
        ..complainTypeId = _selectedComplaintType!.id
        ..complainType = _selectedComplaintType!.value1
        ..salesId = salesId
        ..sales = salesId
        ..unitBusinessId = unitBusinessId
        ..unitBusiness = _selectedSuratJalan?.unitBussiness
        ..date = now
        ..status = 1
        ..notes = contactPersonCtrl.text
        ..items = _items
        ..refType = 'sj'
        ..sjId = _selectedSuratJalan!.id;

      if (_editingComplaintId != null && _editingComplaintId!.isNotEmpty) {
        data
          ..requestApprovalBy = salesId
          ..requestApprovalAt = now
          ..updatedBy = salesId;
        if (kDebugMode) {
          debugPrint(
            '[COMPLAIN_FORM] update id=$_editingComplaintId sj_id=${data.sjId} items=${data.items.length}',
          );
        }
        await _complainRepo.updateComplaintWithDetails(
          token: token,
          id: _editingComplaintId!,
          data: data,
        );
      } else {
        data
          ..requestApprovalBy = salesId
          ..requestApprovalAt = now
          ..createdBy = salesId
          ..updatedBy = salesId;
        if (kDebugMode) {
          debugPrint(
            '[COMPLAIN_FORM] create sj_id=${data.sjId} items=${data.items.length}',
          );
        }
        await _complainRepo.createComplaintWithDetails(
          token: token,
          data: data,
        );
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    contactPersonCtrl.dispose();
    super.dispose();
  }
}
