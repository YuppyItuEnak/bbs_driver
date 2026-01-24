import 'package:bbs_driver/features/deilvery_order/presentation/providers/do_provider.dart';
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
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<DoProvider>().fetchDetailDo(
            token: widget.token,
            doId: widget.doId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
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
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<DoProvider>(
        builder: (context, provider, _) {
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

          return Column(
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
                                        fontWeight: FontWeight.bold),
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
                    onPressed: widget.isConfirmed
                        ? () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const DoCheckinPage(),
                            //   ),
                            // );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isConfirmed
                          ? const Color(0xFF4CAF50)
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.isConfirmed ? "Check In" : "Kembali",
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
          );
        },
      ),
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

  Widget _buildItemRow(
    String title,
    String qty,
    String code,
    String weight,
  ) {
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
