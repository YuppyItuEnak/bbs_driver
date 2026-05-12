import 'package:bbs_driver/data/models/delivery_order/delivery_order_model.dart';
import 'package:bbs_driver/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_driver/features/deilvery_order/presentation/pages/rute_harian_page.dart';
import 'package:bbs_driver/features/deilvery_order/presentation/providers/do_provider.dart';
import 'package:bbs_driver/features/do_checkout/presentation/pages/do_checkout_page.dart';
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
    print("Navigasi ke halaman DO Sudah Dikonfirmasi");

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final doProvider = context.read<DoProvider>();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token.toString();
      final userID = authProvider.user?.id;
      final userId = userID.toString();

      await doProvider.fetchListDOSudahConfirm(
        token: token,
        userId: userId,
        isRefresh: true,
      );

      // Log data yang sudah di-fetch
      if (context.mounted) {
        final fetchedData = context.read<DoProvider>().doList;
        print(
          "Data DO terkonfirmasi berhasil di-fetch: ${fetchedData.length} data",
        );
        for (var item in fetchedData) {
          print(
            "  - DO: ${item.code}, Customer: ${item.customer}, Status: ${item.status}",
          );
        }
      }

      doProvider.checkOpenTimeIn(token: token, userId: userId);
      doProvider.refreshHasConfirmedDo(token: token, userId: userId);
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

                final groups = _groupByCustomer(provider.doList);
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return _buildCustomerGroupCard(group);
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
                  final token = context.read<AuthProvider>().token.toString();
                  context.read<DoProvider>().fetchTodayTracking(token: token);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RuteHarianPage(token: token),
                    ),
                  );
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

  List<_CustomerDoGroup> _groupByCustomer(List<DeliveryOrderModel> list) {
    final map = <String, List<DeliveryOrderModel>>{};
    for (final item in list) {
      final key = item.customerId ?? (item.customer ?? item.id);
      map.putIfAbsent(key, () => <DeliveryOrderModel>[]).add(item);
    }
    return map.entries
        .map(
          (e) => _CustomerDoGroup(
            customerKey: e.key,
            customerName: e.value.first.customer ?? '-',
            shipTo: e.value.first.shipTo ?? '-',
            items: e.value,
          ),
        )
        .toList();
  }

  Widget _buildCustomerGroupCard(_CustomerDoGroup group) {
    return GestureDetector(
      onTap: () {
        final token = context.read<AuthProvider>().token;
        if (token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication token not found.')),
          );
          return;
        }

        final doProvider = context.read<DoProvider>();
        final deliveryPlanId = group.items.first.deliveryPlanId;

        // Aturan baru: Cukup periksa apakah ada DP Realisasi yang aktif secara umum.
        final bool canVisitCustomer = doProvider.homeActionState == 'check_out';

        final doIds = group.items.map((e) => e.id).toList();
        final doCodes = group.items.map((e) => e.code).toList();

        if (canVisitCustomer) {
          if (deliveryPlanId == null || deliveryPlanId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Delivery plan ID tidak ditemukan')),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DoCheckoutPage(
                doIds: doIds,
                doCodes: doCodes,
                customerName: group.customerName,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Anda harus Check In perjalanan terlebih dahulu di halaman Home.',
              ),
            ),
          );
          return;
        }
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
              group.customerName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              group.shipTo,
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
                  'Total DO: ${group.items.length}',
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

class _CustomerDoGroup {
  final String customerKey;
  final String customerName;
  final String shipTo;
  final List<DeliveryOrderModel> items;

  _CustomerDoGroup({
    required this.customerKey,
    required this.customerName,
    required this.shipTo,
    required this.items,
  });
}

// NOTE: Customer card now navigates directly to Check-in/Check-out (no intermediate DO list page).
