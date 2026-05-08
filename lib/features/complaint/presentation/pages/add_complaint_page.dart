import 'package:bbs_driver/core/constants/app_colors.dart';
import 'package:bbs_driver/data/models/complaint/complaint_add_model.dart';
import 'package:bbs_driver/data/models/delivery_order/delivery_order_model.dart';
import 'package:bbs_driver/data/models/m_gen_model.dart';
import 'package:bbs_driver/data/services/complaint/complaint_repository.dart';
import 'package:bbs_driver/data/services/delivery_order/do_repository.dart';
import 'package:bbs_driver/data/services/delivery_order/surat_jalan_repository.dart';
import 'package:bbs_driver/data/services/m_gen_repository.dart';
import 'package:bbs_driver/features/complaint/presentation/pages/return_item_selected_page.dart';
import 'package:bbs_driver/features/complaint/presentation/providers/return_item_provider.dart';
import 'package:bbs_driver/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_driver/features/deilvery_order/presentation/providers/do_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class AddComplaintPage extends StatefulWidget {
  const AddComplaintPage({super.key});

  @override
  State<AddComplaintPage> createState() => _AddComplaintPageState();
}

class _AddComplaintPageState extends State<AddComplaintPage> {
  final _doRepo = DoRepository();
  final _complainRepo = ComplainRepository();
  final _mGenRepo = MGenRepository();
  final _sjRepo = SuratJalanRepository();

  bool _isLoading = true;
  String? _error;

  List<DeliveryOrderModel> _doOptions = [];
  final Set<String> _selectedDoIds = {};

  List<MGenModel> _complainTypes = [];
  MGenModel? _selectedType;

  final Map<String, TextEditingController> _qtyReturnCtrls = {};
  final Map<String, List<ComplainCreateItemModel>> _itemsByDoId = {};
  final TextEditingController _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    for (final c in _qtyReturnCtrls.values) {
      c.dispose();
    }
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final doProvider = context.read<DoProvider>();

    final token = auth.token;
    final userId = auth.user?.id;
    if (token == null || userId == null) {
      setState(() {
        _isLoading = false;
        _error = 'Authentication error.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _doRepo.getTodayHistoryForComplaint(token: token, userId: userId),
        _mGenRepo.fetchMGen("group=m_complain_type", token),
      ]);

      final doList = results[0] as List<DeliveryOrderModel>;
      final types = results[1] as List<MGenModel>;

      // Rule:
      // - Jika ada customer sedang proses (open check-in), otomatis filter DO dari customer tersebut.
      // - Jika tidak ada open check-in (semua complete), tampilkan semua DO (hari ini belum tersedia filter di API list).
      List<DeliveryOrderModel> filtered = doList;
      String? openCustomerId;

      final checkInStatus = doProvider.checkInStatus;
      if (checkInStatus['has_open'] == true) {
        final data = (checkInStatus['data'] as List?) ?? [];
        final open = data.cast<dynamic>().firstWhere(
          (e) => e['time_out'] == null,
          orElse: () => null,
        );
        if (open != null) {
          final openDpId = open['delivery_plan_id']?.toString();
          if (openDpId != null && openDpId.isNotEmpty) {
            // Derive open customer_id from DO(s) in the open delivery plan.
            final openPlanDos = doList
                .where((d) => d.deliveryPlanId == openDpId)
                .toList();
            openCustomerId = openPlanDos
                .map((d) => d.customerId)
                .whereType<String>()
                .firstWhere((id) => id.isNotEmpty, orElse: () => '');
            if (openCustomerId != null && openCustomerId!.isNotEmpty) {
              // Then include ALL DO for that customer (can be more than 1 DO).
              filtered = doList
                  .where((d) => d.customerId == openCustomerId)
                  .toList();
            } else if (openPlanDos.isNotEmpty) {
              filtered = openPlanDos;
            }
          }
        }
      }

      setState(() {
        _doOptions = filtered;
        _complainTypes = types;
        _selectedType = _complainTypes.isNotEmpty ? _complainTypes.first : null;
        // Auto-pick all DO for customer that is currently in-process (open check-in),
        // so user only needs to input return qty.
        if (openCustomerId != null && openCustomerId!.isNotEmpty) {
          _selectedDoIds
            ..clear()
            ..addAll(filtered.map((d) => d.id));
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  List<_ComplaintItemRow> _buildItemRows(List<DeliveryOrderModel> selectedDos) {
    final rows = <_ComplaintItemRow>[];
    for (final doItem in selectedDos) {
      final items =
          _itemsByDoId[doItem.id] ?? const <ComplainCreateItemModel>[];
      for (final it in items) {
        final itemId = it.itemId ?? '';
        if (itemId.isEmpty) continue;
        final key = '${doItem.id}_$itemId';
        _qtyReturnCtrls.putIfAbsent(
          key,
          () => TextEditingController(text: '1'),
        );
        rows.add(
          _ComplaintItemRow(
            keyId: key,
            doId: doItem.id,
            item: it,
            qtyReturnCtrl: _qtyReturnCtrls[key]!,
          ),
        );
      }
    }
    return rows;
  }

  int _parseInt(String text) => int.tryParse(text.trim()) ?? 0;

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final token = auth.token;
    final userId = auth.user?.id;
    final userName = auth.user?.name ?? auth.user?.username;
    final unitBusinessId = auth.unitBusinessId;

    if (token == null || userId == null) return;

    if (_selectedDoIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 surat jalan (DO).')),
      );
      return;
    }

    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tipe komplain belum dipilih.')),
      );
      return;
    }

    final selectedDos = _doOptions
        .where((d) => _selectedDoIds.contains(d.id))
        .toList();
    if (selectedDos.isEmpty) return;

    // Create 1 complaint per DO (SJ), karena model hanya punya 1 sj_id.
    setState(() => _isLoading = true);
    try {
      for (final doItem in selectedDos) {
        if (kDebugMode) {
          debugPrint(
            '[COMPLAIN_UI] saving for sj_id=${doItem.id} code=${doItem.code}',
          );
        }
        final sj = await _sjRepo.fetchSuratJalanDetail(
          token: token,
          id: doItem.id,
        );

        final items = <ComplainCreateItemModel>[];
        final selectedItems = _itemsByDoId[doItem.id] ?? const [];
        for (final it in selectedItems) {
          final itemId = it.itemId ?? '';
          if (itemId.isEmpty) continue;
          final key = '${doItem.id}_$itemId';
          final qtyReturn = _parseInt(_qtyReturnCtrls[key]?.text ?? '0');
          final qtyRef = it.qtyRef ?? 0;
          if (qtyReturn <= 0) continue;
          if (qtyRef > 0 && qtyReturn > qtyRef) continue;

          items.add(
            ComplainCreateItemModel()
              ..itemId = it.itemId
              ..itemName = it.itemName
              ..qtyRef = it.qtyRef
              ..qtyReturn = qtyReturn
              ..uomUnit = it.uomUnit
              ..sjId = doItem.id,
          );
        }

        if (items.isEmpty) continue;

        final payload = ComplainCreateModel()
          ..unitBusinessId = sj.unitBussinessId ?? unitBusinessId
          ..unitBusiness = sj.unitBussiness
          ..customerId = sj.customerId ?? doItem.customerId
          ..customer = sj.customer ?? doItem.customer
          ..refType = 'sj'
          ..complainTypeId = _selectedType!.id
          ..complainType = _selectedType!.value1
          ..salesId = userId
          ..sales = userName
          ..sjId = doItem.id
          ..notes = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim()
          ..status = 1
          ..date = DateTime.now()
          ..requestApprovalBy = userId
          ..requestApprovalAt = DateTime.now()
          ..createdBy = userId
          ..updatedBy = userId
          ..items = items;

        if (kDebugMode) {
          debugPrint(
            '[COMPLAIN_UI] payload_ready sj_id=${payload.sjId} items=${payload.items.length}',
          );
        }
        await _complainRepo.createComplaintWithDetails(
          token: token,
          data: payload,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan komplain: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDos = _doOptions
        .where((d) => _selectedDoIds.contains(d.id))
        .toList();
    final rows = _buildItemRows(selectedDos);

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: Colors.black),
          title: const Text(
            'Komplain',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text('Error: $_error'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Surat Jalan (Delivery Order)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._doOptions.map((d) {
                      final selected = _selectedDoIds.contains(d.id);
                      return CheckboxListTile(
                        value: selected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedDoIds.add(d.id);
                              _itemsByDoId.putIfAbsent(
                                d.id,
                                () => <ComplainCreateItemModel>[],
                              );
                            } else {
                              _selectedDoIds.remove(d.id);
                              _itemsByDoId.remove(d.id);
                            }
                          });
                        },
                        title: Text(d.code),
                        subtitle: Text(d.customer ?? '-'),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      );
                    }),
                    const SizedBox(height: 12),
                    const Text(
                      'Tipe',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<MGenModel>(
                          value: _selectedType,
                          isExpanded: true,
                          items: _complainTypes
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t.value1 ?? '-'),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedType = val),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Catatan (opsional)',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Item Retur',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (selectedDos.isEmpty)
                      const Text(
                        'Pilih surat jalan (DO) terlebih dulu.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    else ...[
                      ...selectedDos.map((doItem) {
                        final addedIds = (_itemsByDoId[doItem.id] ?? [])
                            .map((e) => e.itemId)
                            .whereType<String>()
                            .toList();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final result =
                                    await Navigator.push<
                                      List<ComplainCreateItemModel>
                                    >(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChangeNotifierProvider(
                                          create: (_) => ReturnItemProvider(),
                                          child: ReturnItemSelectedPage(
                                            sjId: doItem.id,
                                            addedItemIds: addedIds,
                                          ),
                                        ),
                                      ),
                                    );
                                if (result == null || !mounted) return;
                                setState(() {
                                  final list = _itemsByDoId.putIfAbsent(
                                    doItem.id,
                                    () => <ComplainCreateItemModel>[],
                                  );
                                  for (final it in result) {
                                    final id = it.itemId;
                                    if (id == null || id.isEmpty) continue;
                                    if (list.any((e) => e.itemId == id)) {
                                      continue;
                                    }
                                    it.sjId = doItem.id;
                                    list.add(it);
                                  }
                                });
                              },
                              icon: const Icon(Icons.add),
                              label: Text('Tambah Barang (${doItem.code})'),
                            ),
                          ),
                        );
                      }),
                      if (rows.isEmpty)
                        const Text(
                          'Belum ada barang dipilih. Klik "Tambah Barang" untuk memilih item dari DO.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      else
                        ...rows.map(_buildItemRow),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildItemRow(_ComplaintItemRow row) {
    final item = row.item;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.itemName ?? '-',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'Qty SJ: ${item.qtyRef ?? 0} ${item.uomUnit ?? ""}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: row.qtyReturnCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Qty Retur',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplaintItemRow {
  final String keyId;
  final String doId;
  final ComplainCreateItemModel item;
  final TextEditingController qtyReturnCtrl;

  _ComplaintItemRow({
    required this.keyId,
    required this.doId,
    required this.item,
    required this.qtyReturnCtrl,
  });
}
