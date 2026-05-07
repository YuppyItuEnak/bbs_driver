import 'package:bbs_driver/data/models/delivery_order/delivery_order_model.dart';
import 'package:bbs_driver/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_driver/features/deilvery_order/presentation/pages/detail_do_page.dart';
import 'package:bbs_driver/features/home/presentation/pages/home_page.dart';
import 'package:bbs_driver/features/deilvery_order/presentation/providers/do_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DoBelumConfirmPage extends StatefulWidget {
  const DoBelumConfirmPage({super.key});

  @override
  State<DoBelumConfirmPage> createState() => _DoBelumConfirmPageState();
}

class _DoBelumConfirmPageState extends State<DoBelumConfirmPage> {
  final Map<String, bool> _selectedMap = {};
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchData();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token != null) {
        context.read<DoProvider>().fetchDoMasuk(token: token);
      }
    }
  }

  Future<void> _fetchData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token != null && mounted) {
      context.read<DoProvider>().fetchDoMasuk(token: token, isRefresh: true);
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 150,
                  width: 150,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/success_confirm.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Konfirmasi berhasil!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB703),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      "Selesai",
                      style: TextStyle(color: Colors.white),
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

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.help_outline_rounded,
                  size: 64,
                  color: Color(0xFFFFB703),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Konfirmasi DO",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Apakah Anda yakin ingin mengonfirmasi\nDelivery Order yang dipilih?",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batal"),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final selectedIds = _selectedMap.entries
                              .where((entry) => entry.value)
                              .map((entry) => entry.key)
                              .toList();

                          if (selectedIds.isEmpty) {
                            Navigator.pop(context); // close dialog
                            return;
                          }

                          final doProvider = context.read<DoProvider>();
                          final authProvider = context.read<AuthProvider>();
                          final token = authProvider.token;
                          final userId = authProvider.user?.id;

                          if (token == null || userId == null) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Authentication error."),
                              ),
                            );
                            return;
                          }

                          // Enforce: DO yang dikonfirmasi harus 1 delivery_plan_id yang sama
                          final selectedDo = doProvider.doList
                              .where((d) => selectedIds.contains(d.id))
                              .toList();
                          final uniqueDeliveryPlanIds = selectedDo
                              .map((d) => d.deliveryPlanId)
                              .whereType<String>()
                              .toSet();
                          if (uniqueDeliveryPlanIds.length > 1) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Konfirmasi DO gagal: delivery plan berbeda.",
                                ),
                              ),
                            );
                            return;
                          }
                          final dpId = uniqueDeliveryPlanIds.isEmpty
                              ? null
                              : uniqueDeliveryPlanIds.first;
                          if (dpId == null || dpId.isEmpty) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Konfirmasi DO gagal: delivery plan tidak ditemukan.",
                                ),
                              ),
                            );
                            return;
                          }

                          final isDpCheckedOut = await doProvider
                              .isDeliveryPlanCheckedOutToday(
                                token: token,
                                userId: userId,
                                deliveryPlanId: dpId,
                              );
                          if (isDpCheckedOut) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Delivery plan sudah check-out hari ini. Tidak bisa tambah DO untuk delivery plan yang sama.",
                                ),
                              ),
                            );
                            return;
                          }

                          // New rule:
                          // - If user confirms a DO under a delivery plan, all DO under that DP are confirmed.
                          final allDoInDp = doProvider.doList
                              .where((d) => d.deliveryPlanId == dpId)
                              .map((d) => d.id)
                              .toList();

                          try {
                            await doProvider.confirmDo(
                              token: token,
                              doIds: allDoInDp,
                              userId: userId,
                            );
                            Navigator.pop(context); // pop the confirmation dialog
                            _showSuccessDialog(context);
                          } catch (e) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text("Failed to confirm DOs: ${e.toString()}"),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB703),
                        ),
                        child: const Text("Ya, Proses"),
                      ),
                    ),
                  ],
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
          "List DO Masuk",
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Consumer<DoProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          final doList = provider.doList;
          final searchQuery = _searchController.text.toLowerCase();
          final filteredDoList = doList.where((item) {
            final code = item.code.toLowerCase();
            final customer = item.customer?.toLowerCase() ?? '';
            final shipTo = item.shipTo?.toLowerCase() ?? '';
            final nopol = item.nopol?.toLowerCase() ?? '';

            return code.contains(searchQuery) ||
                customer.contains(searchQuery) ||
                shipTo.contains(searchQuery) ||
                nopol.contains(searchQuery);
          }).toList();

          return Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Cari DO...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(height: 10),

              /// HEADER
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Semua",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          for (var item in filteredDoList) {
                            _selectedMap[item.id] = true;
                          }
                        });
                      },
                      child: const Text(
                        "Select All",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              /// LIST
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount:
                      filteredDoList.length + (provider.isFetchingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == filteredDoList.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final item = filteredDoList[index];
                    final isSelected = _selectedMap[item.id] ?? false;

                    return _buildDoCard(item, isSelected);
                  },
                ),
              ),

              /// BUTTON
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      final hasSelection = _selectedMap.values.any(
                        (e) => e == true,
                      );

                      if (hasSelection) {
                        _showConfirmDialog(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Pilih minimal satu DO terlebih dahulu",
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB703),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Konfirmasi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  Widget _buildDoCard(DeliveryOrderModel item, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// CHECKBOX
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 10),
            child: InkWell(
              onTap: () {
                setState(() {
                  final next = !isSelected;
                  final dpId = item.deliveryPlanId;
                  if (dpId != null && dpId.isNotEmpty) {
                    final sameDp = context
                        .read<DoProvider>()
                        .doList
                        .where((d) => d.deliveryPlanId == dpId);
                    for (final d in sameDp) {
                      _selectedMap[d.id] = next;
                    }
                  } else {
                    _selectedMap[item.id] = next;
                  }
                });
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0084FF)
                        : Colors.grey.shade300,
                  ),
                  color: isSelected
                      ? const Color(0xFF0084FF)
                      : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
          ),

          /// CARD
          Expanded(
            child: GestureDetector(
              onTap: () {
                final token = context.read<AuthProvider>().token;

                if (token == null || token.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Token tidak ditemukan')),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailDoPage(
                      isConfirmed: false,
                      doId: item.id,
                      token: token,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.code,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          item.date,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(item.customer ?? '-'),
                    const SizedBox(height: 4),
                    Text(
                      item.shipTo ?? '-',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Nopol: ${item.nopol ?? '-'}",
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
