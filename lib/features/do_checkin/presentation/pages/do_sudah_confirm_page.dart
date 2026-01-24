import 'package:bbs_driver/data/models/delivery_order/delivery_order_model.dart';
import 'package:bbs_driver/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_driver/features/deilvery_order/presentation/pages/detail_do_page.dart';
import 'package:bbs_driver/features/deilvery_order/presentation/providers/do_provider.dart';
import 'package:bbs_driver/features/do_checkin/presentation/pages/do_checkin_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DoSudahConfirmPage extends StatefulWidget {
  const DoSudahConfirmPage({super.key});

  @override
  State<DoSudahConfirmPage> createState() => _DoSudahConfirmPageState();
}

class _DoSudahConfirmPageState extends State<DoSudahConfirmPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final doProvider = context.read<DoProvider>();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token.toString();
      final userID = authProvider.user?.id;
      final userId = userID.toString();

      doProvider.fetchListDOSudahConfirm(
        token: token,
        userId: userId,
        isRefresh: true,
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
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFB703)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "List DO",
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar (UI TETAP)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7F9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // Label
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Semua",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // LIST DO DARI PROVIDER
          Expanded(
            child: Consumer<DoProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(child: Text(provider.error!));
                }

                if (provider.doList.isEmpty) {
                  return const Center(
                    child: Text("Tidak ada DO yang sudah dikonfirmasi"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: provider.doList.length,
                  itemBuilder: (context, index) {
                    final doItem = provider.doList[index];
                    return _buildDoCard(doItem);
                  },
                );
              },
            ),
          ),

          // Tombol Lihat Rute (UI TETAP)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: implement map route
                },
                icon: const Icon(Icons.map_outlined, color: Colors.white),
                label: const Text(
                  "Lihat Rute",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= CARD =================

  Widget _buildDoCard(DeliveryOrderModel item) {

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DetailDoPage(isConfirmed: true, doId: '', token: '',),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.customer ?? '-',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              item.shipTo ?? '-',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text(
                //   "Berat ${item.jurnalAmount ?? '-'} KG",
                //   style: const TextStyle(
                //     fontWeight: FontWeight.w500,
                //     fontSize: 12,
                //     color: Colors.black54,
                //   ),
                // ),
                Text(
                  item.date ?? '-',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
