import 'package:bbs_driver/features/deilvery_order/presentation/providers/do_provider.dart';
import 'package:bbs_driver/features/do_checkin/presentation/pages/do_checkin_page.dart';
import 'package:bbs_driver/features/do_checkout/presentation/pages/do_checkout_page.dart';
import 'package:bbs_driver/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailDoPage extends StatefulWidget {
  final bool isConfirmed;
  final String doId;
  final String token;

  const DetailDoPage({
    super.key,
    this.isConfirmed = true,
    required this.doId,
    required this.token,
  });

  @override
  State<DetailDoPage> createState() => _DetailDoPageState();
}

class _DetailDoPageState extends State<DetailDoPage> {
  bool _hasCheckedIn = false;
  bool _isButtonDisabled = false;

  bool _hasOpenCheckInForCurrentDo(DoProvider provider) {
    final checkInStatus = provider.checkInStatus;
    final data = checkInStatus['data'] as List;

    final currentDeliveryPlanId = provider.detailDO?.deliveryPlanId;
    for (var item in data) {
      final apiDeliveryPlanId = item['delivery_plan_id']?.toString();
      final apiDoId = item['t_surat_jalan_id']?.toString();

      final matchesDeliveryPlan = currentDeliveryPlanId != null &&
          apiDeliveryPlanId == currentDeliveryPlanId;
      final matchesDoId = apiDoId == widget.doId.toString();

      if ((matchesDeliveryPlan || matchesDoId) && item['time_out'] == null) {
        return true;
      }
    }
    return false;
  }

  bool _isButtonDisabledCheck(DoProvider provider) {
    final checkInStatus = provider.checkInStatus;
    final data = checkInStatus['data'] as List;

    final currentDeliveryPlanId = provider.detailDO?.deliveryPlanId;
    for (var item in data) {
      if (item['time_out'] == null) {
        final apiDeliveryPlanId = item['delivery_plan_id']?.toString();
        final apiDoId = item['t_surat_jalan_id']?.toString();

        // Disable if there's an open check-in for a different delivery plan (or different DO on legacy payload)
        if (currentDeliveryPlanId != null && apiDeliveryPlanId != null) {
          if (apiDeliveryPlanId != currentDeliveryPlanId) return true;
        } else if (apiDoId != null && apiDoId != widget.doId.toString()) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final provider = context.read<DoProvider>();
      final userId = context.read<AuthProvider>().user?.id;
      provider.fetchDetailDo(token: widget.token, doId: widget.doId);
      provider.checkOpenTimeIn(token: widget.token, userId: userId).then((_) {
        if (mounted) {
          setState(() {
            _hasCheckedIn = _hasOpenCheckInForCurrentDo(provider);
            _isButtonDisabled = _isButtonDisabledCheck(provider);
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DoProvider>(
      builder: (context, provider, _) {
        // Update hasCheckedIn and isButtonDisabled when provider data changes
        final hasCheckedIn = _hasOpenCheckInForCurrentDo(provider);
        final isButtonDisabled = _isButtonDisabledCheck(provider);
        if (hasCheckedIn != _hasCheckedIn && mounted) {
          setState(() {
            _hasCheckedIn = hasCheckedIn;
          });
        }
        if (isButtonDisabled != _isButtonDisabled && mounted) {
          setState(() {
            _isButtonDisabled = isButtonDisabled;
          });
        }

        // --- LOADING ---
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // --- ERROR ---
        if (provider.error != null) {
          return Center(
            child: Text(
              provider.error!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final model = provider.detailDO;

        if (model == null) {
          return const Center(child: Text("Data tidak ditemukan"));
        }

        final details = model.details;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.orange),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Detail DO",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER INFO ---
                      _buildInfoRow("No. DO", model.code),
                      _buildInfoRow("Tanggal", model.date),
                      _buildInfoRow("Customer", model.customer ?? "-"),
                      _buildInfoRow("Alamat", model.shipTo ?? "-"),
                      const SizedBox(height: 30),
                      // --- CARD BARANG ---
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header Card
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    model.salesOrder!.code,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    model.deliveryArea ?? "",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // --- LIST ITEM ---
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: details.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final detail = details[index];
                                final item = detail.item;
                                return _buildItemRow(
                                  item?.name ?? "-",
                                  "${detail.qty} ${detail.uomUnit}",
                                  item?.code ?? "",
                                  "${detail.weight} KG",
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // --- BUTTON BOTTOM ---
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isButtonDisabled
                        ? null
                        : (_hasCheckedIn
                              ? () {
                                  final doProvider = context.read<DoProvider>();
                                  final deliveryPlanId =
                                      doProvider.detailDO?.deliveryPlanId;
                                  if (deliveryPlanId == null ||
                                      deliveryPlanId.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Delivery plan ID tidak ditemukan pada DO.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DoCheckoutPage(
                                            doIds: [widget.doId],
                                            doCodes: [
                                              doProvider.detailDO?.code ??
                                                  widget.doId,
                                            ],
                                            customerName:
                                                doProvider.detailDO?.customer ??
                                                '-',
                                            deliveryPlanId: deliveryPlanId,
                                          ),
                                    ),
                                  );
                                }
                              : () {
                                  final doProvider = context.read<DoProvider>();
                                  final deliveryPlanId =
                                      doProvider.detailDO?.deliveryPlanId;
                                  if (deliveryPlanId == null ||
                                      deliveryPlanId.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Delivery plan ID tidak ditemukan pada DO.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DoCheckinPage(
                                        doIds: [widget.doId],
                                        doCodes: [
                                          doProvider.detailDO?.code ??
                                              widget.doId,
                                        ],
                                        customerName:
                                            doProvider.detailDO?.customer ??
                                            '-',
                                        deliveryPlanId: deliveryPlanId,
                                      ),
                                    ),
                                  );
                                }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isButtonDisabled
                          ? Colors.grey
                          : (_hasCheckedIn
                                ? const Color(0xFFFF9800)
                                : const Color(0xFF4CAF50)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _hasCheckedIn ? "Check Out" : "Check In",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= HELPER WIDGET =================

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(String title, String qty, String code, String weight) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                code,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                qty,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                "Tonase : $weight",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
